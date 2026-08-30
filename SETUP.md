# Quick Info Flashcard — setup & run on a real phone

## 1. Create the Flutter scaffold (once)

The folder is empty, so generate the platform folders first. In Terminal:

```bash
cd ~/Github/baust/hello-flutter
flutter create . --project-name hello_flutter
```

(The `--project-name` flag is required because Dart package names can't contain a hyphen.)

## 2. Drop in the app code

`flutter create` writes its own demo `lib/main.dart`. Replace it with the one in this folder:

```bash
cp app_main.dart lib/main.dart
flutter pub get
```

## 3. Run it on your phone — no emulator needed

### Android (easiest)

1. On the phone: **Settings → About phone → tap "Build number" 7 times** to unlock Developer options.
2. **Settings → Developer options → enable "USB debugging"**.
3. Plug the phone into the Mac with a USB cable (a data cable, not charge-only).
4. On the phone, accept the **"Allow USB debugging?"** prompt (tick "Always allow").
5. Back in Terminal:

```bash
flutter devices        # your phone should be listed
flutter run            # or: flutter run -d <device-id>
```

First build takes a few minutes; after that press `r` in the terminal for hot reload, `R` for hot restart, `q` to quit.

#### Android over Wi-Fi (no cable, Android 11+)

1. Phone: **Developer options → Wireless debugging → on → "Pair device with pairing code"**.
2. On the Mac:

```bash
adb pair <phone-ip>:<pairing-port>   # enter the 6-digit code shown on the phone
adb connect <phone-ip>:<debug-port>  # the port on the main Wireless debugging screen
flutter run
```

(`adb` lives at `~/Library/Android/sdk/platform-tools/adb` if it's not on your PATH.)

### iPhone

Xcode is required for iOS — there's no way around it, but you still don't need a simulator:

1. Install Xcode from the App Store, then `sudo xcodebuild -runFirstLaunch`.
2. Connect the iPhone via USB, tap **Trust this computer**.
3. `open ios/Runner.xcworkspace` → select the **Runner** target → **Signing & Capabilities** → tick *Automatically manage signing* and pick your free personal Apple ID team. Change the Bundle Identifier to something unique like `com.rakib.helloflutter`.
4. On the iPhone: **Settings → Privacy & Security → Developer Mode → on** (it reboots).
5. `flutter run`
6. First launch will say "Untrusted Developer" — go to **Settings → General → VPN & Device Management** and trust your developer certificate.

Free Apple IDs give a 7-day signing window; re-run `flutter run` to refresh it.

### Zero-setup alternative

```bash
flutter run -d chrome
```

Runs the same app in a browser — handy for checking the layout quickly.

## 4. Building an APK to sideload

If you'd rather just install a file on the phone:

```bash
flutter build apk --release
```

The APK lands at `build/app/outputs/flutter-apk/app-release.apk` — transfer it to the phone and open it (allow "install from unknown sources").

## What the code demonstrates

| Concept | Where |
| --- | --- |
| `Center` | centres the card in `HomePage` |
| `Card` | the elevated white focus card, `InfoCard` |
| `Container` styling | gradient background + the badge pill (`BoxDecoration`, `BorderRadius`, `Border`) |
| `TextStyle` / `FontWeight` | badge, quote body, author name, reference |
| Alignment | `Column` with `crossAxisAlignment`, `Row` with `Expanded` in `AuthorRow` |
| `setState` | the "Next card" button cycles through the list |
