# Android wrapper

Minimal WebView shell that packages `../index.html` as an installable APK.

```
bash build.sh ../index.html /path/to/keystore.jks VoxelRacing.apk
```

- `AndroidManifest.xml` — package `com.voxelracing.game`; bump `versionCode`/`versionName` for every release.
- `java/com/voxelracing/game/MainActivity.java` — fullscreen WebView, hardware accelerated, keeps the screen on, exposes `AndroidHost.exit()` so the in-game Exit button closes the app.
- `res/` — launcher icons (legacy + adaptive).
- `build.sh` — downloads a portable JDK 17 and the Android build-tools/platform, then compiles, aligns and signs.

The APK must always be signed with the **same keystore**, otherwise devices refuse to update an existing install.
