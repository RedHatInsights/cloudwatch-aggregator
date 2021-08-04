import os
import watchtower
import logging

from app import app

from flask import request
from boto3.session import Session

logging.basicConfig(level=os.getenv("LOG_LEVEL", logging.INFO))
logger = logging.getLogger(__name__)
boto3_session = Session(aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
                        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
                        region_name=os.getenv("AWS_REGION_NAME"))
logger.addHandler(watchtower.CloudWatchLogHandler(log_group="platform-dev", stream_name="3scale-dev", boto3_session=boto3_session))

@app.route("/log/", methods=["POST"])
def index(log_stream):
    logger.info(request.get_json())
    return {"status": "available"}, 202
