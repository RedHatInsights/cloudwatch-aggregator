FROM registry.access.redhat.com/hi/python:3.13-builder

USER root

LABEL name="cloudwatch-aggregator" \
      summary="CloudWatch Aggregator - Batch Logging Service" \
      description="REST API service that manages batch logging to CloudWatch and Splunk from HTTP POST requests with JSON payloads in a non-blocking manner. Accepts log data via REST API and forwards to configured logging platforms." \
      io.k8s.description="REST API service that manages batch logging to CloudWatch and Splunk from HTTP POST requests with JSON payloads in a non-blocking manner. Accepts log data via REST API and forwards to configured logging platforms." \
      io.k8s.display-name="CloudWatch Aggregator" \
      io.openshift.tags="insights,logging,cloudwatch,splunk,api,redhat" \
      com.redhat.component="cloudwatch-aggregator" \
      version="1.0" \
      release="1" \
      vendor="Red Hat, Inc." \
      url="https://github.com/redhatinsights/cloudwatch-aggregator" \
      distribution-scope="private" \
      maintainer="platform-accessmanagement@redhat.com"

WORKDIR /usr/src/app

RUN microdnf install --disableplugin=subscription-manager --nodocs -y tar gzip which && \
    microdnf clean all

COPY Pipfile* /usr/src/app/
RUN pip install --upgrade pip && pip install pipenv
RUN pipenv install --system --deploy --ignore-pipfile

USER 1001

COPY . /usr/src/app/
CMD ["./run-server.sh"]
