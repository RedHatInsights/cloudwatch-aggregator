from flask import Flask
import logging

app = Flask(__name__)
app.url_map.strict_slashes = False

from app import log
