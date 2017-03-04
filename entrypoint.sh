#!/bin/bash

exec /tini -- daphne -b 0.0.0.0 --access-log - "$@" proj.asgi:channel_layer
