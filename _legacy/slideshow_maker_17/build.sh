#!/usr/bin/env sh

set -e

cd "$(dirname "$0")"

mkdir -p out
../assemblers/ca65 ./src/main.asm -o ./out/main.o -g
../assemblers/ld65 -C ./src/lorom.cfg -o ./out/slideshow.sfc ./out/main.o
