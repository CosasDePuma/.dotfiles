#!/bin/sh

# Upsate WPScan
wpscan --no-banner --update
# Run WPScan with some anonimity
wpscan --random-user-agent ${@}
