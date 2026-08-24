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
  param([string]$Type, [string]$Key, [string]$Command, [string]$Action = "")
  $arguments = @("--silent", "--show-error", "--fail", "--insecure", "--request", "POST", "--data-urlencode", "type=$Type", "--data-urlencode", "key=$Key", "--data-urlencode", "cmd=$Command")
  if ($Action) { $arguments += @("--data-urlencode", "action=$Action") }
  $arguments += $apiUrl
  $content = & curl.exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "Panorama API request failed" }
  return ([xml]($content -join "`n"))
}

function Get-PanosJobId {
  param([xml]$Response)
  foreach ($xpath in @("/response/result/job", "/response/result/jobid", "/response/result/job-id")) {
    $node = $Response.SelectSingleNode($xpath)
    if ($node -and $node.InnerText) { return $node.InnerText }
  }
  $match = [regex]::Match($Response.OuterXml, "(?i)job(?:\s*id)?\s*[:=]?\s*(\d+)")
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

$keygenArguments = @("--silent", "--show-error", "--fail", "--insecure", "--request", "POST", "--data-urlencode", "type=keygen", "--data-urlencode", "user=$username", "--data-urlencode", "password=$password", $apiUrl)
$keygenContent = & curl.exe @keygenArguments
if ($LASTEXITCODE -ne 0) { throw "Panorama API key generation request failed" }
$key = ([xml]($keygenContent -join "`n")).response.result.key
if ([string]::IsNullOrWhiteSpace($key)) { throw "Panorama did not return an API key" }

function Is-PanosNoChanges {
  param([xml]$Response)
  $messageText = ($Response.SelectNodes("//msg") | ForEach-Object { $_.InnerText }) -join " "
  if ([string]::IsNullOrWhiteSpace($messageText)) { $messageText = $Response.OuterXml }
  return ($Response.response.status -eq "success" -and $messageText -match "(?i)no changes|same as the previous commit|no edits have been made")
}

$candidate = Invoke-PanosApi "commit" $key "<commit><description>$description</description><partial><device-group><entry name='$deviceGroup'/></device-group></partial></commit>"
$candidateJob = Get-PanosJobId $candidate
if ($candidateJob) {
  Wait-PanosJob $key $candidateJob "Panorama $deviceGroup candidate commit"
} elseif (Is-PanosNoChanges $candidate) {
  Write-Output "Panorama reports no new $deviceGroup candidate changes. Running forced Panorama commit."
  $forced = Invoke-PanosApi "commit" $key "<commit><description>$description (force)</description><force></force></commit>"
  $forcedJob = Get-PanosJobId $forced
  if ($forcedJob) {
    Wait-PanosJob $key $forcedJob "Panorama forced commit"
  } else {
    throw "Panorama forced commit failed or returned no job ID: $($forced.OuterXml)"
  }
} else {
  throw "Panorama candidate commit failed: $($candidate.OuterXml)"
}
