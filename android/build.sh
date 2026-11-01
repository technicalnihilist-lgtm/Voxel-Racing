#!/usr/bin/env bash
# Builds VoxelRacing.apk from index.html + the WebView wrapper in this folder.
# Usage: bash build.sh <index.html> <keystore.jks> <output.apk>
# The APK must be signed with the SAME key every time, otherwise existing
# installs cannot update over the previous version.
set -euo pipefail
ulimit -v unlimited 2>/dev/null || true

GAME="${1:?usage: build.sh <index.html> <keystore.jks> [out.apk]}"
KS="${2:?keystore required}"
OUT="${3:-VoxelRacing.apk}"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${APKBUILD_DIR:-/tmp/apkbuild}"
mkdir -p "$WORK" && cd "$WORK"

# ---------- toolchain (cached in $WORK) ----------
if [ ! -x "$WORK/jdk/bin/java" ]; then
  echo "== fetching JDK 17"
  curl -sL -o jdk.tar.gz "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse"
  mkdir -p jdk && tar xzf jdk.tar.gz -C jdk --strip-components=1
fi
export JAVA_HOME="$WORK/jdk"; export PATH="$JAVA_HOME/bin:$PATH"

SDK="$WORK/sdk"
if [ ! -f "$SDK/platforms/android-34/android.jar" ]; then
  echo "== fetching Android platform + build-tools"
  mkdir -p "$SDK/platforms" "$SDK/build-tools"
  curl -sL -o p.zip "https://dl.google.com/android/repository/platform-34-ext7_r03.zip"
  unzip -qo p.zip -d "$SDK/platforms"
  curl -sL -o b.zip "https://dl.google.com/android/repository/build-tools_r34-linux.zip"
  unzip -qo b.zip -d "$SDK/build-tools"
fi
BT="$SDK/build-tools/android-14"; JAR="$SDK/platforms/android-34/android.jar"

# ---------- assets: the game + a hook so the in-game Exit button quits the app ----------
mkdir -p assets
python3 - "$GAME" <<'PY'
import sys
src = open(sys.argv[1]).read()
shim = '<script>if(window.AndroidHost){window.close=function(){try{AndroidHost.exit()}catch(e){}}}</script>\n'
if 'AndroidHost.exit' not in src:
    src = src.replace('</body>', shim + '</body>')
open('assets/index.html', 'w').write(src)
PY

# ---------- compile + package + sign ----------
rm -rf compiled.zip base.apk unsigned.apk aligned.apk classes gen dexout "$OUT"
"$BT/aapt2" compile --dir "$HERE/res" -o compiled.zip
mkdir -p gen
"$BT/aapt2" link -o base.apk -I "$JAR" --manifest "$HERE/AndroidManifest.xml" -A assets --java gen compiled.zip
mkdir -p classes
javac -source 8 -target 8 -nowarn -bootclasspath "$JAR" -d classes \
  "$HERE/java/com/voxelracing/game/MainActivity.java" gen/com/voxelracing/game/R.java 2>&1 \
  | grep -vi "deprecat\|bootstrap" || true
mkdir -p dexout
"$BT/d8" --lib "$JAR" --min-api 21 --output dexout $(find classes -name "*.class")
python3 -c "
import zipfile, shutil
shutil.copy('base.apk', 'unsigned.apk')
z = zipfile.ZipFile('unsigned.apk', 'a', zipfile.ZIP_DEFLATED)
z.write('dexout/classes.dex', 'classes.dex'); z.close()"
"$BT/zipalign" -f -p 4 unsigned.apk aligned.apk
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
  --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
  --out "$OUT" aligned.apk
"$BT/apksigner" verify "$OUT"
ls -la "$OUT"
echo "BUILD OK: $OUT"
