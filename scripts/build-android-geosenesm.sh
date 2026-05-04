#!/usr/bin/env bash

set -euo pipefail

artifact_type="${1:-apk}"

case "$artifact_type" in
  apk|appbundle)
    ;;
  *)
    echo "Usage: $0 [apk|appbundle]"
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

cd "$repo_root"

export APP_TYPE="geosenesm"

dart run flutter_launcher_icons -f android_launcher_icons_geosenesm.yaml

flutter build "$artifact_type" --release --dart-define=APP_TYPE="$APP_TYPE"

if [ "$artifact_type" = "apk" ]; then
  source_path="build/app/outputs/flutter-apk/app-release.apk"
  target_path="build/app/outputs/flutter-apk/app-${APP_TYPE}-release.apk"
else
  source_path="build/app/outputs/bundle/release/app-release.aab"
  target_path="build/app/outputs/bundle/release/app-${APP_TYPE}-release.aab"
fi

cp "$source_path" "$target_path"
echo "Saved ${APP_TYPE} ${artifact_type} to $target_path"