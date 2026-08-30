# Installing Flutter from the command line (macOS, Apple Silicon)

You already have Flutter at `/opt/homebrew/share/flutter` — that's a Homebrew cask install. Jump to
[§6 Upgrading](#6-upgrading-an-existing-install) if you just want a newer version. The rest of this
doc covers a clean install from scratch.

---

## 0. Prerequisites

```bash
# Xcode command line tools (gives you git, clang, make)
xcode-select --install

# Rosetta 2 — required on Apple Silicon for some Android/iOS tooling
sudo softwareupdate --install-rosetta --agree-to-license
```

Check your shell so you edit the right rc file:

```bash
echo $SHELL      # /bin/zsh on any modern macOS → use ~/.zshrc
```

---

## 1. Install the SDK

Pick **one** of the three methods below.

### Method A — Homebrew (simplest)

```bash
# Install Homebrew first if you don't have it:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask flutter
```

Lands in `/opt/homebrew/Caskroom/flutter/<version>/flutter`, symlinked onto your PATH
automatically. Upgrade with `brew upgrade --cask flutter`.

**Trade-off:** you're pinned to whatever version the cask ships, and `flutter upgrade` won't work
(the SDK isn't a git checkout you own). This is the most likely cause of the `ColorScheme.fromSeed`
error you hit — an older cask build.

### Method B — Official git clone (recommended for real work)

This is what Flutter's own docs assume, and it's the only method where `flutter upgrade` and
`flutter channel` work properly.

```bash
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Warm up the tool (downloads the Dart SDK on first run)
flutter --version
flutter precache
```

To save disk/time you can shallow-clone: `git clone --depth 1 -b stable https://github.com/flutter/flutter.git`
(but `flutter upgrade` then needs `git fetch --unshallow` first).

### Method C — Download the official zip

```bash
mkdir -p ~/development && cd ~/development
# Grab the current macOS arm64 stable URL from:
#   https://docs.flutter.dev/release/archive
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_<VERSION>-stable.zip
unzip flutter_macos_arm64_<VERSION>-stable.zip
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Replace `<VERSION>` with the actual current stable from the archive page — Flutter doesn't publish a
stable "latest" URL you can curl blindly.

### Verify

```bash
which flutter        # should point at your chosen install
flutter --version
flutter doctor
```

`flutter doctor` will list what's still missing. Work through it section by section below.

---

## 2. Android toolchain

Flutter needs the Android SDK, platform-tools, build-tools, and a JDK. Android Studio bundles all of
it and is by far the least painful route.

```bash
brew install --cask android-studio
```

Then open Android Studio once and let the setup wizard install the SDK. Or do it headlessly with
`sdkmanager` if you'd rather skip the IDE:

```bash
brew install --cask android-commandlinetools
brew install --cask temurin        # JDK 17

sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

Point Flutter at the SDK and accept the licenses:

```bash
flutter config --android-sdk ~/Library/Android/sdk
flutter doctor --android-licenses     # press y through every prompt
```

Put `adb` on your PATH (useful for wireless debugging):

```bash
echo 'export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
adb devices
```

If `flutter doctor` complains about `cmdline-tools component is missing`:

```bash
sdkmanager --install "cmdline-tools;latest"
```

---

## 3. iOS toolchain (only if you want to build for iPhone)

```bash
# Xcode itself — 10+ GB, App Store is usually faster than the CLI
mas install 497799835                      # requires: brew install mas
# or just install Xcode from the App Store

sudo xcodebuild -runFirstLaunch
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

# CocoaPods — needed for any plugin that has native iOS code
brew install cocoapods
```

---

## 4. Optional but handy

```bash
brew install --cask visual-studio-code
code --install-extension Dart-Code.flutter    # Dart + Flutter extensions
```

---

## 5. Final check

```bash
flutter doctor -v
```

You want green checkmarks for Flutter, Android toolchain, and (if relevant) Xcode. A red X on
"Android Studio" is harmless if you installed the SDK via `sdkmanager` and only use VS Code — Flutter
just needs the SDK, not the IDE.

---

## 6. Upgrading an existing install

**If installed via Homebrew:**

```bash
brew upgrade --cask flutter
flutter --version
```

**If installed via git clone:**

```bash
flutter upgrade                 # stays on your current channel
flutter channel stable          # switch channels if needed
flutter upgrade --force         # if the tool refuses due to local edits
```

**Switching from the Homebrew cask to a git install** (recommended if you keep hitting
version-related API errors):

```bash
brew uninstall --cask flutter
mkdir -p ~/development && cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
hash -r                         # clear the shell's cached path to the old binary
which flutter                   # confirm it's the new one
flutter doctor
```

After any upgrade, in your project:

```bash
cd ~/Github/baust/hello-flutter
flutter clean
flutter pub get
flutter run
```

### Multiple Flutter versions side by side

If you ever need per-project versions (different courses, different clients), use FVM:

```bash
brew tap leoafarias/fvm && brew install fvm
fvm install stable
fvm use stable                  # writes .fvmrc in the project
fvm flutter run                 # run any flutter command through fvm
```

---

## 7. Uninstalling

```bash
brew uninstall --cask flutter            # Homebrew install
rm -rf ~/development/flutter             # git/zip install
rm -rf ~/.pub-cache                      # downloaded packages
# then remove the PATH line you added from ~/.zshrc
```

---

## Troubleshooting quick reference

| Symptom | Fix |
| --- | --- |
| `flutter: command not found` | PATH line missing or shell not reloaded — `source ~/.zshrc`, then `which flutter` |
| `No named parameter with the name 'x'` | SDK is older than the API you're using — upgrade (§6) |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| `CocoaPods not installed` | `brew install cocoapods` then `cd ios && pod install` |
| `Waiting for another flutter command to release the startup lock` | `rm ~/development/flutter/bin/cache/lockfile` |
| Weird build errors after upgrading | `flutter clean && flutter pub get` |
| `which flutter` still shows the old path | `hash -r` (zsh caches command locations) |

Sources: [Flutter install docs — macOS](https://docs.flutter.dev/get-started/install/macos/mobile-android), [Flutter SDK archive](https://docs.flutter.dev/release/archive)
