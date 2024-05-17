#!/usr/bin/env bash
set -eou pipefail

# Creating a log file
echo "debian-amd64 config"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile
exec &> $logfile
set -x

echo "testing"

# Cleaning up
unset logfile
set +x
