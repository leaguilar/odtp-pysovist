#!/bin/bash
# Run pysovist on the component inputs. Settings arrive as environment variables
# (the parameters in odtp.yml). Results go to /odtp/odtp-output.
set -euo pipefail
export ODTP_INPUT=/odtp/odtp-input
export ODTP_OUTPUT=/odtp/odtp-output
pysovist odtp
