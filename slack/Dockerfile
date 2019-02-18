FROM alpine:3.9

LABEL repository="http://github.com/agemooij/github-actions-checkruns"
LABEL homepage="http://github.com/agemooij/github-actions-checkruns"
LABEL maintainer="Age Mooij <age@scalapenos.com>"

LABEL com.github.actions.name="Check Runs: Notify Slack"
LABEL com.github.actions.description="Notifies a slack channel about failed check runs"
LABEL com.github.actions.icon="hash"
LABEL com.github.actions.color="black"

RUN apk --no-cache --update add \
    bash \
    ca-certificates \
    curl \
    jq

COPY send-slack-message.sh /send-slack-message.sh

ENTRYPOINT ["/send-slack-message.sh"]
