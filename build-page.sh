#!/usr/bin/env bash
[ -d build ] && chmod -R 777 build && rm -rf build
mkdir -p build
nix-build
cp -RfL result/site/* build