#!/usr/bin/env sh
set -eu

swift run forge verify-solutions core --constraints-only
swift run forge verify-solutions mantle --constraints-only
swift run forge verify-solutions crust --constraints-only
