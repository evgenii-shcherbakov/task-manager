#!/bin/bash

rm -rf build
mkdir build
cd frontend || exit

echo Install dependencies...

sudo apt-get update -y
sudo apt-get install -y ninja-build libgtk-3-dev
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter config --enable-linux-desktop

echo Test code...

flutter test

echo Build linux version...

flutter build linux --dart-define=BACKEND_URL="$BACKEND_URL"

echo Move output linux files to build directory...

cp -R build/linux/* ../build
