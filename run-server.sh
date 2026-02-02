#!/bin/sh

if [ "x$FLASK_ENV" = "xdevelopment" ]
then
  flask run --host=0.0.0.0 --reload
else
  # Use gevent workers for async I/O - allows handling many concurrent requests
  # Each worker can handle hundreds of concurrent connections
  gunicorn -w ${GUNICORN_WORKERS:-4} -k gevent --worker-connections ${GUNICORN_WORKER_CONNECTIONS:-1000} -b 0.0.0.0:$PUBLIC_PORT app:app
fi
