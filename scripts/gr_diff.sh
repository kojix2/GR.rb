#!/usr/bin/env bash

cd "$(dirname "$0")"

diff <(./gr_h.sh) <(./gr_ffi.sh)
