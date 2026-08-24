$ErrorActionPreference = "Stop"

$hostname = $env:PANOS_HOSTNAME
$username = $env:PANOS_USERNAME
$password = $env:PANOS_PASSWORD
$deviceGroup = if ($env:PANOS_DEVICE_GROUP) { $env:PANOS_DEVICE_GROUP } else { "DG1" }
$description = if ($env:PANOS_COMMIT_DESCRIPTION) { $env:PANOS_COMMIT_DESCRIPTION } else { "Terraform apply" }

if ([string]::IsNullOrWhiteSpace($hostname)) { throw "PANOS_HOSTNAME is required" }
if ([string]::IsNullOrWhiteSpace($username)) { throw "PANOS_USERNAME is required" }
if ([string]::IsNullOrWhiteSpace($password)) { throw "PANOS_PASSWORD is required" }

$apiUrl = "https://$hostname/api"

function Invoke-PanosApi {
  param(
    [string]$Type,
    [string]$Key,
    [string]$Command
  )

  $arguments = @(
    "--silent", "--show-error", "--fail", "--insecure", "--request", "POST",
    "--data-urlencode", "type=$Type",
    "--data-urlencode", "key=$Key",
    "--data-urlencode", "cmd=$Command",
    $apiUrl
  )
  $content = & curl.exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "Panorama API request failed" }
  return ([xml]($content -join "`n"))
}

function Get-PanosJobId {
  param([xml]$Response)
  foreach ($xpath in @("/response/result/job", "/response/result/jobid", "/response/result/job-id")) {
    $node = $Response.SelectSingleNode($xpath)
    if ($node -and -not [string]::IsNullOrWhiteSpace($node.InnerText)) { return $node.InnerText }
  }
  $match = [regex]::Match($Response.InnerText, "(?i)job(?:\s*id)?\s*[:=]?\s*(\d+)")
  if ($match.Success) { return $match.Groups[1].Value }
  return $null
}

function Wait-PanosJob {
  param([string]$Key, [string]$JobId, [string]$Description)
  for ($attempt = 1; $attempt -le 30; $attempt++) {
    Start-Sleep -Seconds 10
    $response = Invoke-PanosApi "op" $Key "<show><jobs><id>$JobId</id></jobs></show>"
    $job = $response.response.result.job
    Write-Output "$Description job $JobId status: $($job.status)"
    if ($job.status -eq "FIN") {
      if ($job.result -ne "OK") { throw "$Description failed: $($response.OuterXml)" }
      Write-Output "$Description job $JobId completed successfully."
      return
    }
  }
  throw "$Description job $JobId did not finish within 5 minutes"
}

$keygenArguments = @(
  "--silent", "--show-error", "--fail", "--insecure", "--request", "POST",
  "--data-urlencode", "type=keygen",
  "--data-urlencode", "user=$username",
  "--data-urlencode", "password=$password",
  $apiUrl
)
$keygenContent = & curl.exe @keygenArguments
if ($LASTEXITCODE -ne 0) { throw "Panorama API key generation request failed" }
$keygenResponse = [xml]($keygenContent -join "`n")
$key = $keygenResponse.response.result.key
if ([string]::IsNullOrWhiteSpace($key)) { throw "Panorama did not return an API key: $($keygenResponse.OuterXml)" }

$candidateCommand = "<commit><description>$description</description><partial><device-group><entry name='$deviceGroup'/></device-group></partial></commit>"
$candidateResponse = Invoke-PanosApi "commit" $key $candidateCommand
$candidateJobId = Get-PanosJobId $candidateResponse
$candidateMessage = $candidateResponse.InnerText
if ($candidateJobId) {
  Wait-PanosJob $key $candidateJobId "Panorama $deviceGroup candidate commit"
} elseif ($candidateResponse.response.code -eq "13" -or $candidateMessage -match "(?i)same as the previous commit|no edits have been made|no changes") {
  Write-Output "Panorama reports no new $deviceGroup candidate changes."
} else {
  throw "Panorama candidate commit failed or returned no job ID: $($candidateResponse.OuterXml)"
}

Write-Output "Starting full production push for Panorama $deviceGroup."
$pushCommand = "<commit-all><shared-policy><device-group><entry name='$deviceGroup'/></device-group></shared-policy></commit-all>"
$pushResponse = Invoke-PanosApi "commit" $key $pushCommand
$pushJobId = Get-PanosJobId $pushResponse
$pushMessage = $pushResponse.InnerText
if ($pushJobId) {
  Wait-PanosJob $key $pushJobId "Panorama $deviceGroup full production push"
} elseif ($pushResponse.response.code -eq "19" -or $pushMessage -match "(?i)no changes to commit|no changes") {
  Write-Output "Panorama reports that $deviceGroup is already synchronized with the managed firewalls."
} else {
  throw "Panorama production push failed or returned no job ID: $($pushResponse.OuterXml)"
}
