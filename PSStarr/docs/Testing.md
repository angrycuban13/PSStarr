# Tests

Build the module before running Pester 5.7.1 against Tests.
Unit tests use fake credentials and mocked HTTP requests; they do not prove live compatibility.
Transport error tests construct PowerShell HTTP exceptions with 400, 401, 403,
404, 429, and 500 responses and varied error bodies. They test error handling,
not PowerShell's actual HTTP parsing.

## Opt-in integration tests

By default, live tests are skipped, even if credentials are present.
To enable them, set PSSTARR_RUN_INTEGRATION to exactly 1 in the current process.
Supply PSSTARR_RADARR_URL, PSSTARR_RADARR_API_KEY, PSSTARR_SONARR_URL, and
PSSTARR_SONARR_API_KEY through your secret manager or local environment.
Never commit credentials or include them in test output.

Run Invoke-Pester -Path ./Tests/Integration.Tests.ps1 -Output Normal.
Both applications are required once enabled; missing credentials fail the test.
Only GET system/status is requested. No saved connection is read or changed.
Use trusted HTTPS endpoints when accessing servers across a network.

## Logging policy

Keep automatic file logging limited to sanitized operational failures.
Do not automatically copy information, warning, verbose, or debug streams into
files. Successful requests remain unlogged. Logging failures must not recursively
log themselves.

A public logging opt-out and custom destination remain pending implementation:
consuming applications need control over duplicate logging and filesystem writes.
Do not interpret ErrorAction SilentlyContinue as a file-logging opt-out.
