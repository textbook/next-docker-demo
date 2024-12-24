#!/bin/sh
set -ex

exec /sbin/tini -- node server.js
