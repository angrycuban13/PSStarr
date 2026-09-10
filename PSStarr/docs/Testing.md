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

Set PSSTARR_LOG_DISABLED to exactly 1 to disable automatic file logging.
This does not suppress the original PowerShell error. Unset it to restore logging.
Set PSSTARR_LOG_DIRECTORY to choose the directory for PSStarr.log; unset or
whitespace values use the platform default. The existing logger may fall back
to a temporary directory if it cannot create the requested directory.
These process environment controls are checked on each operational failure and
do not modify saved connections. Child processes inherit environment values.
Explicit internal log parameters take precedence over the environment directory.
ErrorAction SilentlyContinue is not a file-logging opt-out.
Choose a private directory: API keys are sanitized, but logs can contain server
URLs and other operational details. Logging failures do not replace the original error.
