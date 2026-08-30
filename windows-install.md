# Installing Flutter from the command line (Windows 10 / 11)

Everything below is run in **PowerShell**. Open it as a normal user unless a step says otherwise —
package-manager installs will prompt for elevation on their own.

---

## 0. Requirements

- 64-bit Windows 10 or 11
- ~10 GB free disk for Flutter + Android SDK (more like 25 GB with Android Studio)
- PowerShell 5.1 (ships with Windows) or newer

Quick check:

```powershell
$PSVersionTable.PSVersion
[Environment]::Is64BitOperatingSystem
```

---

## 1. Install a package manager (optional but makes everything easier)

Windows 10 1809+ and Windows 11 ship with **winget** already. Verify:

```powershell
winget --version
```

If it's missing, install "App Installer" from the Microsoft Store. Alternatively use Chocolatey:

```powershell
# Run PowerShell as Administrator for this one
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

---

## 2. Install Git

Flutter's own tooling shells out to git, so this is not optional.

```powershell
winget install --id Git.Git -e
# or: choco install git -y
```

Close and reopen PowerShell, then confirm:

```powershell
git --version
```

---

## 3. Install the Flutter SDK

Pick **one** method.

### Method A — Git clone (recommended)

This is the only method where `flutter upgrade` and `flutter channel` work properly.

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\dev"
Set-Location "$env:USERPROFILE\dev"
git clone https://github.com/flutter/flutter.git -b stable
```

> Avoid paths with spaces or non-ASCII characters, and don't put it under `C:\Program Files` —
> Flutter needs write access to its own directory and will fail with permission errors there.

### Method B — winget

```powershell
winget install --id Google.Flutter -e
```

Convenient, but you're pinned to whatever version the manifest ships and `flutter upgrade` may not
work cleanly. Fine for getting started, worth swapping to Method A later.

### Method C — Download the zip

```powershell
Set-Location "$env:USERPROFILE\Downloads"
# Get the current stable URL from https://docs.flutter.dev/release/archive
Invoke-WebRequest `
  -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_<VERSION>-stable.zip" `
  -OutFile "flutter.zip"

Expand-Archive -Path ".\flutter.zip" -DestinationPath "$env:USERPROFILE\dev\"
```

Replace `<VERSION>` with the actual current stable — there's no stable "latest" URL to download
blindly.

---

## 4. Add Flutter to PATH

The GUI route is Windows + Pause → **Advanced system settings → Environment Variables → Path → New**,
then add `%USERPROFILE%\dev\flutter\bin`.

To do it from PowerShell instead (user-level PATH, no admin needed):

```powershell
$flutterBin = "$env:USERPROFILE\dev\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$flutterBin;$userPath", "User")
    Write-Host "Added to PATH. Restart PowerShell."
}
```

**Close and reopen PowerShell** — environment changes don't apply to already-running shells. Then:

```powershell
Get-Command flutter | Select-Object Source
flutter --version
flutter precache
```

---

## 5. Android toolchain

### Android Studio (easiest — bundles the SDK, JDK, and platform tools)

```powershell
winget install --id Google.AndroidStudio -e
```

Launch it once and let the setup wizard download the SDK. Then open
**Settings → Languages & Frameworks → Android SDK → SDK Tools** and make sure these are ticked:

- Android SDK Platform, API 35
- Android SDK Command-line Tools
- Android SDK Build-Tools
- Android SDK Platform-Tools

### Command-line only (no IDE)

```powershell
winget install --id EclipseAdoptium.Temurin.17.JDK -e
winget install --id Google.AndroidStudio.CommandLineTools -e   # or download cmdline-tools manually
```

Then, with `sdkmanager` on your PATH:

```powershell
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "cmdline-tools;latest"
```

### Point Flutter at the SDK and accept licenses

```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
flutter doctor --android-licenses     # type y at every prompt
```

### Put adb on PATH (needed for wireless debugging)

```powershell
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$adbPath;$userPath", "User")
# restart PowerShell
adb devices
```

---

## 6. Windows desktop builds (optional)

Only needed if you want to run the app as a Windows desktop app rather than on a phone.

```powershell
winget install --id Microsoft.VisualStudio.2022.Community -e `
  --override "--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --passive"
```

The key piece is the **Desktop development with C++** workload. Then `flutter run -d windows`.

**iOS is not possible on Windows** — Apple requires macOS and Xcode for iOS builds. Your options are
a Mac, a cloud CI service (Codemagic, GitHub Actions macOS runners), or just targeting Android.

---

## 7. Editor

```powershell
winget install --id Microsoft.VisualStudioCode -e
code --install-extension Dart-Code.flutter
```

---

## 8. Verify everything

```powershell
flutter doctor -v
```

You want `[√]` on Flutter, Android toolchain, and (if you installed it) Visual Studio. A red X on
"Android Studio" is harmless if you installed the SDK via `sdkmanager` and use VS Code — Flutter
needs the SDK, not the IDE.

---

## 9. Running the flashcard app on a phone from Windows

Same as macOS, just PowerShell instead of Terminal:

```powershell
Set-Location "$env:USERPROFILE\path\to\hello-flutter"
flutter create . --project-name hello_flutter    # only if the scaffold doesn't exist yet
Copy-Item .\app_main.dart .\lib\main.dart -Force
flutter pub get
flutter devices
flutter run
```

**One Windows-specific gotcha:** some Android phones need the manufacturer's USB driver before
Windows will see them over ADB. If `flutter devices` comes up empty with the cable plugged in and USB
debugging on, install the [Google USB Driver](https://developer.android.com/studio/run/win-usb) via
SDK Manager, or your phone maker's OEM driver. macOS and Linux don't need this step, which is why
it catches people out.

Wireless debugging (Android 11+) avoids drivers entirely:

```powershell
adb pair <phone-ip>:<pairing-port>
adb connect <phone-ip>:<debug-port>
flutter run
```

---

## 10. Upgrading

```powershell
flutter upgrade                  # git installs
flutter channel stable
winget upgrade --id Google.Flutter -e    # winget installs
```

After upgrading, in your project:

```powershell
flutter clean
flutter pub get
flutter run
```

---

## Troubleshooting quick reference

| Symptom | Fix |
| --- | --- |
| `flutter` not recognized | PATH not set, or PowerShell not restarted after setting it |
| `Access is denied` during `flutter precache` | SDK is in a protected folder — move it to `%USERPROFILE%\dev\flutter` |
| `Waiting for another flutter command to release the startup lock` | Delete `flutter\bin\cache\lockfile` |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| Phone not in `flutter devices` | Install the OEM/Google USB driver, or use wireless debugging |
| `Unable to locate Android SDK` | `flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"` |
| Long-path build failures | Enable long paths: `New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force` (admin) |
| Antivirus makes builds crawl | Exclude the Flutter SDK folder and `%USERPROFILE%\.pub-cache` from real-time scanning |

Sources: [Flutter install docs — Windows](https://docs.flutter.dev/get-started/install/windows/mobile), [Flutter SDK archive](https://docs.flutter.dev/release/archive)
