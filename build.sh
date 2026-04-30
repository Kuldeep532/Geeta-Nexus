#!/bin/bash

# Flutter SDK setup
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Project setup aur build
flutter pub get
flutter build web --release
