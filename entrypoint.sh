#!/bin/sh
set -ex

prisma migrate deploy
exec node server.js
