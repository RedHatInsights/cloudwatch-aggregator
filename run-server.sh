#!/bin/sh

if [ "x$FLASK_ENV" = "xdevelopment" ]
then
  flask run --host=0.0.0.0 --reload
else
  gunicorn -w 4 -k gevent -b 0.0.0.0:$PUBLIC_PORT app:app
fi
