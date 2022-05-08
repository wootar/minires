#!/bin/sh
cd kernel
./build-kernel.sh || exit 1
cd ..
./alpine-build.sh || exit 1