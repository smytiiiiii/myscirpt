#!/usr/bin/env bash
cd "$(dirname "$0")"
exec ./artifacts/run.sh +exec server.cfg
