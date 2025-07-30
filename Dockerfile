FROM registry.access.redhat.com/ubi9/ubi-minimal:9.6-1753762263

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
