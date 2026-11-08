#!/usr/bin/env bash
# Встановлює Flutter у GitHub Codespaces і додає платформні папки (android/ios/web),
# не чіпаючи вже існуючі lib/, test/, pubspec.yaml.
set -euo pipefail

if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
grep -q 'flutter/bin' ~/.bashrc || echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

flutter config --enable-web --no-analytics
flutter precache --web

if [ ! -d web ]; then
  rm -rf /tmp/scaffold
  flutter create --project-name mobile_widgets_app --platforms=web,android,ios /tmp/scaffold
  cp -r /tmp/scaffold/android /tmp/scaffold/ios /tmp/scaffold/web .
  cp /tmp/scaffold/.metadata .
fi

flutter pub get
echo "Готово. Далі: flutter analyze && flutter test"
