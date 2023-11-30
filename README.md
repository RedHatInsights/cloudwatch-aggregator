# CloudWatch Aggregator
Manage batch logging to CloudWatch and Splunk from an HTTP POST with JSON in a non-blocking manner

### Dependencies
You'll need to copy `.env.example` to `.env` and populate accordingly depending on which logging platform(s) you're using.
```
pipenv install
pipenv shell
```

### Build
```
# build only
./scripts/build
```

### Run
```
# build and run
./scripts/run
```

### Linting/pre-commit
Linting will run automatically with `black` in a pre-commit hook, but you'll need to run `pre-commit install` first.
You can also run it manually with `pre-commit run -a`.

Additionally, the pre-commit will update the `requirements.txt` file if the `Pipfile.lock` has been updated. The `requirements.txt` file is needed for Synk to run its security scans.

## Configuration
There are multiple logging platforms you can configure to send log events to via environment variables/deployment params:

### CloudWatch
|Environment Variable/Param   |Type: Description|
|-----------------------------|----------------------------------------------|
|`LOG_TO_CLOUDWATCH`          |`boolean`: whether or not to log to CloudWatch|
|`AWS_ACCESS_KEY_ID`          |`string`: AWS access key ID for CloudWatch|
|`AWS_SECRET_ACCESS_KEY`      |`string`: AWS secret access key for CloudWatch|
|`AWS_REGION_NAME`            |`string`: AWS region for CloudWatch|
|`AWS_LOG_GROUP`              |`string`: CloudWatch log group name|
|`CLOUD_WATCH_ALLOWED_STREAMS`|`string`: comma-separated list of allowable CloudWatch log streams|

### Splunk
|Environment Variable/Param   |Type: Description|
|-----------------------------|----------------------------------------------|
|`LOG_TO_SPLUNK`       |`boolean`: whether or not to log to Splunk|
|`SPLUNK_DEBUG`        |`boolean`: whether or not to enable debug logs for Splunk|
|`SPLUNK_HOST`         |`string`: Splunk host|
|`SPLUNK_PORT`         |`integer`: Splunk port|
|`SPLUNK_TOKEN`        |`string`: Splunk API token|
|`SPLUNK_INDEX`        |`string`: Splunk index name for logs|
|`SPLUNK_WAIT_ON_QUEUE`|`boolean`: ensures logs aren't dropped when queue fills if true|
|`SPLUNK_FORMAT_JSON`  |`boolean`: will convert from dict to JSON when true|
