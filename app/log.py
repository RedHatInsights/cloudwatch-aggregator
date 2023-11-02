import os
import watchtower
import logging

from app import app, utils

from boto3.session import Session
from flask import abort, current_app, jsonify, make_response, request
from splunk_handler import SplunkHandler
from time import strftime
from app_common_python import LoadedConfig, isClowderEnabled

if isClowderEnabled():
    cfg = LoadedConfig

    AWS_LOG_GROUP = cfg.logging.cloudwatch.logGroup
    AWS_ACCESS_KEY_ID = cfg.logging.cloudwatch.accessKeyId
    AWS_SECRET_ACCESS_KEY = cfg.logging.cloudwatch.secretAccessKey
    AWS_REGION_NAME = cfg.logging.cloudwatch.region
else:
    AWS_LOG_GROUP = os.getenv("AWS_LOG_GROUP")
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AWS_REGION_NAME = os.getenv("AWS_REGION_NAME")


LOG_TO_CLOUDWATCH = utils.truthy_string(os.getenv("LOG_TO_CLOUDWATCH"))
LOG_TO_SPLUNK = utils.truthy_string(os.getenv("LOG_TO_SPLUNK"))

logging.basicConfig(level=os.getenv("LOG_LEVEL", logging.INFO))


class Cache:
    active_stream_handlers = {}
    allowed_streams = os.getenv("CLOUD_WATCH_ALLOWED_STREAMS", "").split(",")


@app.route("/ping")
def ping():
    return {"status": "available"}, 200


@app.route("/log/<log_stream>", methods=["POST"])
def log(log_stream):
    validate_log_stream(log_stream)
    logger = logging.getLogger(log_stream)
    add_log_handlers(log_stream, logger)
    logger.info(request.get_json(force=True))
    return {"status": "accepted"}, 202


def validate_log_stream(log_stream):
    if log_stream not in Cache.allowed_streams:
        abort(
            make_response(
                jsonify(message=f"{log_stream} is not a valid CloudWatch log stream."),
                403,
            )
        )


def add_log_handlers(log_stream, logger):
    if not Cache.active_stream_handlers.get(log_stream):
        Cache.active_stream_handlers[log_stream] = logger
        if LOG_TO_SPLUNK:
            add_splunk_handler(logger)
        if LOG_TO_CLOUDWATCH:
            add_cw_handler(log_stream, logger)


def add_splunk_handler(logger):
    logger.addHandler(
        SplunkHandler(
            host=os.getenv("SPLUNK_HOST"),
            port=os.getenv("SPLUNK_PORT"),
            token=os.getenv("SPLUNK_TOKEN"),
            index=os.getenv("SPLUNK_INDEX"),
            force_keep_ahead=utils.truthy_string(os.getenv("SPLUNK_WAIT_ON_QUEUE")),
            record_format=utils.truthy_string(os.getenv("SPLUNK_FORMAT_JSON")),
            debug=utils.truthy_string(os.getenv("SPLUNK_DEBUG")),
            sourcetype=os.getenv("SPLUNK_SOURCE_TYPE"),
        )
    )


def add_cw_handler(log_stream, logger):
    logger.addHandler(
        watchtower.CloudWatchLogHandler(
            log_group=AWS_LOG_GROUP,
            stream_name=log_stream,
            boto3_session=session(),
        )
    )


def session():
    return Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION_NAME,
    )


@app.after_request
def after_request(response):
    timestamp = strftime("[%Y-%b-%d %H:%M:%S]")
    current_app.logger.info(
        f"{timestamp} {request.remote_addr} {request.method} {request.full_path} {request.scheme} {response.status}"
    )
    return response
