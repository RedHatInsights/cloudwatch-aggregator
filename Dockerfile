FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1791279563@sha256:5ed244b62bbf4095080144d9d35eb8fcd3d39a9801f94aadd63b9d10978a01ae

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

RUN microdnf install --disableplugin=subscription-manager --nodocs -y python3.12 python3.12-pip tar gzip which

# Create symlinks for python3 and pip3 pointing to Python 3.12 binaries
RUN ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/pip3.12 /usr/bin/pip3

COPY Pipfile* /usr/src/app/
RUN pip3 install --upgrade pip && pip3 install pipenv
RUN pipenv install --system --deploy --ignore-pipfile

COPY . /usr/src/app/
CMD ["./run-server.sh"]
