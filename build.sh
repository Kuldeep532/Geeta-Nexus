#!/bin/bash

# 1. Flutter download karein
git clone https://github.com/flutter/flutter.git -b stable

# 2. Path set karein
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Flutter ko initialize karein
flutter doctor

# 4. Web build karein
flutter build web --release
