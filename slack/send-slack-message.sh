#!/bin/bash
set -e
set -o pipefail

if [[ -z "$SLACK_BOT_TOKEN" ]]; then
  echo "Set the SLACK_BOT_TOKEN env variable."
  exit 1
fi

if [[ -z "$SLACK_CHANNEL" ]]; then
  echo "Set the SLACK_CHANNEL env variable."
  exit 1
fi

if [[ -z "$CHECK_RUN_NAME" ]]; then
  CHECK_RUN_NAME="*"
fi

SLACK_URI=https://slack.com/api/chat.postMessage
CONTENT_TYPE_HEADER="Content-type: application/json"
AUTH_HEADER="Authorization: Bearer ${SLACK_BOT_TOKEN}"

main(){
  status=$(jq --raw-output .check_run.status "$GITHUB_EVENT_PATH")
  conclusion=$(jq --raw-output .check_run.conclusion "$GITHUB_EVENT_PATH")
  name=$(jq --raw-output .check_run.name "$GITHUB_EVENT_PATH")
  report_uri=$(jq --raw-output .check_run.html_url "$GITHUB_EVENT_PATH")

  echo "DEBUG -> status: $status, conclusion: $conclusion, name: $name"
  echo "DEBUG -> report_uri: $report_uri"

  if [[ "$status" == "completed" ]] && [[ "$conclusion" == "failure" ]] && [[ "$name" == $CHECK_RUN_NAME ]]; then
    message=$(cat <<EOF
{
  "channel": "$SLACK_CHANNEL",
  "text": "",
  "attachments": [
    {
      "title": "Build failure on repository '$GITHUB_REPOSITORY'",
      "text": "The CI build for branch '$GITHUB_REF' failed!",
      "color": "danger",
      "mrkdwn_in": ["text", "title"],
      "actions": [
        {
          "type": "button",
          "text": "Build results",
          "style": "primary",
          "url": "$report_uri"
        }
      ]
    }
  ]
}
EOF
)

    echo "DEBUG -> Message to be sent:"
    echo "$message"

    echo "Posting message to Slack..."

    curl -X POST -sSL \
      -H "${AUTH_HEADER}" \
      -H "${CONTENT_TYPE_HEADER}" \
      -d "$message" \
      "${SLACK_URI}"
  fi
}

main "$@"
