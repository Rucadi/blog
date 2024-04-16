#!/usr/bin/env bash
rm -rf build
mkdir -p build
nix-build
cp -RL result/site/* build