FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /usr/src/app
COPY Pipfile* /usr/src/app/

RUN microdnf install --disableplugin=subscription-manager --nodocs -y python39 tar gzip

RUN pip3 install --upgrade pip
RUN pip3 install pipenv
RUN pipenv install --system --deploy --ignore-pipfile

COPY . /usr/src/app/
CMD ["./run-server.sh"]
