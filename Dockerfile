FROM registry.access.redhat.com/ubi8/ubi-minimal:8.7-1085

WORKDIR /usr/src/app
COPY Pipfile* /usr/src/app/

RUN microdnf install --nodocs -y python39 tar gzip

RUN pip3 install --upgrade pip && \
    pip3 install pipenv && \
    pipenv install --system --deploy --ignore-pipfile

COPY . /usr/src/app/
CMD ["./run-server.sh"]
