#!/usr/bin/env bash
set -euo pipefail

: "${PANOS_HOSTNAME:?PANOS_HOSTNAME is required}"
: "${PANOS_USERNAME:?PANOS_USERNAME is required}"
: "${PANOS_PASSWORD:?PANOS_PASSWORD is required}"
PANOS_DEVICE_GROUP="${PANOS_DEVICE_GROUP:-DG1}"
PANOS_COMMIT_DESCRIPTION="${PANOS_COMMIT_DESCRIPTION:-Terraform apply}"
API_URL="https://${PANOS_HOSTNAME}/api"

panos_api() {
	curl --silent --show-error --fail --insecure --request POST \
		--data-urlencode "type=$1" \
		--data-urlencode "key=$2" \
		--data-urlencode "cmd=$3" \
		"$API_URL"
}

get_job_id() {
	printf '%s' "$1" | sed -n \
		-e 's:.*<job>\([0-9][0-9]*\)</job>.*:\1:p' \
		-e 's:.*<jobid>\([0-9][0-9]*\)</jobid>.*:\1:p' \
		-e 's:.*<job-id>\([0-9][0-9]*\)</job-id>.*:\1:p' | head -n 1
}

wait_for_job() {
	local key="$1"
	local job_id="$2"
	local description="$3"
	local response status result

	for _ in $(seq 1 30); do
		sleep 10
		response="$(panos_api op "$key" "<show><jobs><id>${job_id}</id></jobs></show>")"
		status="$(printf '%s' "$response" | sed -n 's:.*<status>\([^<]*\)</status>.*:\1:p' | head -n 1)"
		result="$(printf '%s' "$response" | sed -n 's:.*<result>\([^<]*\)</result>.*:\1:p' | head -n 1)"
		echo "${description} job ${job_id} status: ${status}"
		if [ "$status" = "FIN" ]; then
			if [ "$result" != "OK" ]; then
				echo "${description} failed: ${response}" >&2
				return 1
			fi
			echo "${description} job ${job_id} completed successfully."
			return 0
		fi
	done

	echo "${description} job ${job_id} did not finish within 5 minutes." >&2
	return 1
}

keygen_response="$(curl --silent --show-error --fail --insecure --request POST \
	--data-urlencode "type=keygen" \
	--data-urlencode "user=${PANOS_USERNAME}" \
	--data-urlencode "password=${PANOS_PASSWORD}" \
	"$API_URL")"
key="$(printf '%s' "$keygen_response" | sed -n 's:.*<key>\([^<]*\)</key>.*:\1:p' | head -n 1)"
if [ -z "$key" ]; then
	echo "Panorama did not return an API key: ${keygen_response}" >&2
	exit 1
fi

candidate_command="<commit><description>${PANOS_COMMIT_DESCRIPTION}</description><partial><device-group><entry name='${PANOS_DEVICE_GROUP}'/></device-group></partial></commit>"
candidate_response="$(panos_api commit "$key" "$candidate_command")"
candidate_job_id="$(get_job_id "$candidate_response")"
candidate_code="$(printf '%s' "$candidate_response" | sed -n 's:.*<response[^>]*code="\([0-9]*\)".*:\1:p' | head -n 1)"

if [ -n "$candidate_job_id" ]; then
	wait_for_job "$key" "$candidate_job_id" "Panorama ${PANOS_DEVICE_GROUP} candidate commit"
elif [ "$candidate_code" = "13" ] || printf '%s' "$candidate_response" | grep -Eiq 'same as the previous commit|no edits have been made|no changes'; then
	echo "Panorama reports no new ${PANOS_DEVICE_GROUP} candidate changes."
else
	echo "Panorama candidate commit failed or returned no job ID: ${candidate_response}" >&2
	exit 1
fi

echo "Starting full production push for Panorama ${PANOS_DEVICE_GROUP}."
push_command="<commit-all><shared-policy><device-group><entry name='${PANOS_DEVICE_GROUP}'/></device-group></shared-policy></commit-all>"
push_response="$(panos_api commit "$key" "$push_command")"
push_job_id="$(get_job_id "$push_response")"
push_code="$(printf '%s' "$push_response" | sed -n 's:.*<response[^>]*code="\([0-9]*\)".*:\1:p' | head -n 1)"

if [ -n "$push_job_id" ]; then
	wait_for_job "$key" "$push_job_id" "Panorama ${PANOS_DEVICE_GROUP} full production push"
elif [ "$push_code" = "19" ] || printf '%s' "$push_response" | grep -Eiq 'no changes to commit|no changes'; then
	echo "Panorama reports that ${PANOS_DEVICE_GROUP} is already synchronized with the managed firewalls."
else
	echo "Panorama production push failed or returned no job ID: ${push_response}" >&2
	exit 1
fi
