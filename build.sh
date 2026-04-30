#!/bin/bash

# Flutter install check aur clone
if [ ! -d "flutter" ]; then 
    git clone https://github.com/flutter/flutter.git
fi

# Flutter doctor aur build process
./flutter/bin/flutter doctor
./flutter/bin/flutter build web --release
