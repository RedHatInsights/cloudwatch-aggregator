# CloudWatch Aggregator
Manage batch logging to CloudWatch from an HTTP POST with JSON in a non-blocking manner

### Dependencies
You'll need to copy `.env.example` to `.env` and populate accordingly.
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
