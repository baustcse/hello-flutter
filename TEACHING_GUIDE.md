# Demo Guide — BAUST Flutter Learning App

A classroom script for walking students through all six pages. Ordered easiest → hardest, so each
page adds exactly one new idea on top of the last.

**Total time:** ~50–60 min for the full set. Each page works as a standalone 8-minute demo if you're
short on time.

---

## Before class (10 minutes, do this once)

```bash
cd ~/Github/baust/hello-flutter
flutter pub get
flutter run        # leave it running the whole class
```

Checklist:

- [ ] App already running on a **real phone** mirrored to the projector, or `-d chrome` if mirroring fails
- [ ] Editor font size bumped up (14pt is invisible from the back row)
- [ ] Terminal visible somewhere — students need to see `r` reloading
- [ ] Airplane mode **off**, campus Wi-Fi tested — the Weather and Map pages need network
- [ ] Have `flutter run -d chrome` as a backup if the phone disconnects mid-class

> **Rehearse the hot reload once.** The single most persuasive moment in the whole class is changing a
> colour and having it appear on the phone in under a second. If it stutters the first time you try it
> live, you lose that.

---

## Opening frame (3 minutes, before any code)

Don't open the editor yet. Open the app, swipe through the drawer, let them see six working pages.
Then say roughly this:

> "Everything you just saw is one idea repeated. In Flutter, every single thing on screen is a
> **widget** — the text is a widget, the padding around the text is a widget, the card behind it is a
> widget, even the colour of the background is a widget. You build a screen by nesting widgets inside
> widgets. That's it. That's the whole framework. Today we'll look at six screens that each nest
> widgets a little differently."

Then write this on the board and leave it up all class:

```
Scaffold          ← the page frame (app bar, drawer, body)
 └─ Container     ← decoration: colour, gradient, padding
     └─ Column    ← stack children vertically
         └─ Text  ← the actual content
```

Every page you're about to show is a variation on that shape. Point back at the board each time.

---

## Page 1 — CSE 3100 (3 min) · *pure layout, no logic*

**Show:** the drawer → CSE 3100. A centred white card with a big icon, title, subtitle, one button.

**Open:** `lib/cse3100_page.dart` — it's only 101 lines, scroll the whole thing slowly.

**The one concept:** `StatelessWidget`. This page never changes, so it needs no memory. Point at
`build()` and say: *"Flutter calls this method, gets a widget tree back, draws it. Done. Nothing here
can change after it's drawn."*

**Trace the nesting out loud,** matching the board:
`Scaffold` → `Container` (the gradient) → `SafeArea` → `Center` → `Padding` → `Column` → `Container`
(the white card) → `Column` → `Icon` + `Text` + `Text`.

**Live edit — do this one:** change `fontSize: 48` to `fontSize: 80`, save, watch it jump on the
phone. Then change `colors: [Color(0xFFEEF2FF), ...]` to something loud like `Colors.orange`. Two
edits, two instant results. Students stop doubting the tooling right here.

**Ask them:** *"Why is `SafeArea` there? What breaks if I remove it?"* Then remove it and show the
text sliding under the phone's notch. A broken thing explains itself better than a working one.

---

## Page 2 — Flashcards (8 min) · *state enters the picture*

**Show:** tap "Next card" a few times. The card content changes, the counter updates.

**Open:** `lib/main.dart`, start at `class HomePage` (~line 210).

**The one concept:** `StatefulWidget` + `setState`. This is the single most important idea in the
course, so slow down here.

Explain the mechanism precisely, because students usually get a fuzzy version of it:

1. `_index` is a variable that *survives* between redraws — that's the "state"
2. `_next()` changes `_index` **inside** `setState()`
3. `setState()` doesn't redraw anything itself — it tells Flutter *"my data changed, please call
   `build()` again"*
4. `build()` runs fresh, reads the new `_index`, returns a new widget tree
5. Flutter compares old tree to new tree and repaints only what actually differs

**The deliberate break — this one teaches more than any explanation:** change `_next()` to

```dart
void _next() {
  _index = (_index + 1) % kCards.length;   // setState removed on purpose
}
```

Hot reload, tap the button. **Nothing happens.** Let the silence sit for a few seconds. Then ask:
*"Did the variable change?"* (Yes.) *"Did the screen?"* (No.) *"So what does `setState` actually
do?"* Put it back.

**Also point out:** `kCards` is a `const List` of `InfoCardData` objects — data lives separate from
UI. And `InfoCard`, `CategoryBadge`, `AuthorRow` are **extracted widgets**: *"I could have written
all of this inline in one 200-line build method. Why didn't I?"* (Reuse, readability, and Flutter
only rebuilds the widgets that changed.)

---

## Page 3 — Navigation & the Drawer (4 min) · *more than one screen*

**Show:** open the drawer from several pages. Same drawer everywhere.

**Open:** `class AppDrawer` in `lib/main.dart` (~line 96).

**The one concept:** `Navigator` as a **stack of pages**. Use a physical metaphor — a stack of plates:

- `Navigator.push` → put a new plate on top (back button returns to the one underneath)
- `Navigator.pop` → take the top plate off
- `Navigator.pushReplacement` → swap the top plate, don't grow the stack

**Point out the deliberate choice:** this app uses `pushReplacement` in the drawer, so the back stack
doesn't pile up twenty pages deep as students tap around. Then explain the `Navigator.pop(context)`
on the line *before* it — that one closes the drawer itself.

**Also worth naming:** `_DrawerTile` is a private widget (leading underscore) that exists purely so
the same six lines of `ListTile` setup aren't written out five times. That's the DRY principle showing
up in UI code.

---

## Page 4 — CGPA Calculator (10 min) · *input, validation, and a list of state*

**Show:** change a grade, add a course, delete one, hit Calculate. Then deliberately type garbage
("abc") into a credits field and hit Calculate — the SnackBar warning appears.

**Open:** `lib/cgpa_calculator.dart`.

**The one concept:** reading **user input**, and managing a *list* of stateful rows rather than one
variable.

Walk these four pieces in order:

| Piece | What to say |
| --- | --- |
| `TextEditingController` | "A text field doesn't hand you its value — you attach a controller and ask the controller. `course.creditCtrl.text` is always a **String**, never a number." |
| `_CourseRow` | "Each row needs its own controller and its own grade. So I made a tiny class to hold them, and keep a `List<_CourseRow>`." |
| `ListView.builder` | "`itemCount` is `_courses.length + 1` — the extra one is the 'Add Course' button. It builds rows lazily, only what's on screen." |
| `dispose()` | "Controllers hold memory. Every controller you create, you must dispose. Forget this and you leak memory — a real bug, not a style rule." |

**Spend real time on `_calculate()`.** It's the best validation example in the project:

```dart
final credit = double.tryParse(c.creditCtrl.text);
```

Ask: *"Why `tryParse` and not `parse`?"* Answer: `parse` **throws** on bad input and crashes the app;
`tryParse` returns `null` so you can handle it gracefully. Then show the `ok = false` flag, the
`totalCredits == 0` guard, and the SnackBar. Land the lesson: **never trust what a user types.**

**Live edit:** change `_cgpa!.toStringAsFixed(2)` to `(3)` and point out that formatting is a
presentation decision, separate from the calculation.

---

## Page 5 — Study Timer (8 min) · *time, async, and cleanup*

**Show:** start the timer, switch modes mid-run, reset. Watch the progress ring fill.

**Open:** `lib/study_timer.dart`.

**The one concept:** `Timer.periodic` — code that runs *without* the user doing anything.

```dart
_timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
```

Say it plainly: *"Every page so far only changed when a finger touched the screen. This one changes
on its own. Once per second, `_tick()` runs, decrements `_remainingSec` inside `setState`, and the UI
redraws. Same `setState` you already know — just triggered by a clock instead of a tap."*

**The critical lesson here is `dispose()`.** Make it concrete:

> "If you navigate away and don't cancel this timer, it keeps firing forever — calling `setState` on a
> widget that no longer exists. You get a red error screen, and the phone battery drains in the
> background. `_timer?.cancel()` in `dispose()` is not optional."

**Also name:** `enum _TimerMode` — *"three modes, and the enum makes it impossible to typo a fourth
one. The compiler catches what a String never would."* Tie it back: `kDurations` and `kModeLabels` are
maps keyed by that enum.

---

## Page 6 — Weather Table (10 min) · *real data from the internet*

**Show:** the page loads, spinner appears briefly, table fills. Tap through cities. Scroll the table
sideways. Hit refresh.

**Then turn on airplane mode and hit refresh.** The error state appears with a "Try again" button.
Turn Wi-Fi back on, tap Try again, it recovers. Students remember this demo.

**Open:** `lib/weather_table_page.dart`.

**The one concept:** `async`/`await` and the three states of any network call.

Teach the three states explicitly — draw them on the board:

```
loading  →  success     ← the happy path students always code
         ↘  error       ← the path they always forget
```

Then show `FutureBuilder` and how each branch maps to one of those states:
`ConnectionState.waiting` → spinner, `snapshot.hasError` → `_ErrorView`, otherwise → the table.
*"Three states, three widgets. If your app only handles one of them, it isn't finished."*

**Walk `_fetchForecast()` line by line:**

- `Uri.https(...)` builds the URL safely instead of gluing strings together
- `await http.get(uri)` — *"`await` means: pause this function, let the UI keep running, resume when
  the reply arrives. The screen never freezes."*
- `.timeout(Duration(seconds: 15))` — *"a request that never answers is worse than one that fails"*
- `if (response.statusCode != 200) throw` — check before trusting
- `jsonDecode(response.body)` → a `Map<String, dynamic>`

**Then the interesting bit, `Forecast.fromJson`.** Show them the raw API shape — open
`api.open-meteo.com/v1/forecast?latitude=23.81&longitude=90.41&hourly=temperature_2m` in the browser
on the projector. The API returns **parallel arrays**, not a list of objects:

```json
"hourly": {
  "time":           ["...T00:00", "...T01:00", "...T02:00"],
  "temperature_2m": [27.3,        26.9,        26.4       ]
}
```

*"A table needs rows. The API gave me columns. So the loop in `fromJson` zips them by index — index 0
of every array is row 0."* This is the moment students understand that **parsing is a real step**, not
a formality. Point out `at<T>()` returning `null` for a short array: defensive parsing means a missing
field shows as `—` instead of crashing.

**Finally `DataTable`:** two nested `SingleChildScrollView`s, one vertical and one horizontal, because
six columns don't fit a phone. Mention `WidgetStateProperty` for the alternating row colours.

---

## Page 7 — Map (8 min) · *using someone else's package*

**Show:** pan and zoom with fingers. Tap the city chips. Tap the custom +/− buttons. Tap anywhere on
the map to drop a red pin. Watch the info card coordinates update live.

**Open:** `lib/map_page.dart`, but **open `pubspec.yaml` first.**

**The one concept:** packages. *"Nobody writes a map engine. You declare a dependency and pub.dev
hands you one."*

```yaml
flutter_map: ^8.0.0
latlong2: ^0.9.1
```

Explain the caret: `^8.0.0` means *"any 8.x, but not 9.0"* — because a major version bump is allowed
to break your code. Then show `flutter pub get` in the terminal and `pubspec.lock` — *"the lock file
records the exact versions, so your teammate's build matches yours."*

**Worth saying out loud:** this is OpenStreetMap, not Google Maps. Google Maps needs a Cloud project,
an API key, and a billing card. OSM needs nothing. *"When you're learning, choose the thing you can
start using in the next sixty seconds."* Also point at `_Attribution` — *"free data still has terms;
you credit the source."*

**Two patterns worth naming:**

1. **`MapController`** — *"Finger gestures move the map by themselves. But my +/− buttons are outside
   the map, so they need a handle to reach in and command it. `_mapController.move(center, zoom)`.
   That's the controller pattern — same idea as `TextEditingController` on the CGPA page."* Tie the two
   pages together; students love when two things turn out to be one thing.
2. **`Stack`** — *"`Column` puts children side by side. `Stack` puts them **on top of each other**,
   layered. That's how the buttons and info card float over the map."* `Positioned` sets where in the
   layer each one sits.

**Live edit:** add a new `MapPlace` to `kPlaces` — your campus, their hometown, anywhere — hot reload,
and a new chip appears that flies the map there. Best possible closing demo: one line of data, a new
feature.

---

## Closing (3 min)

Put the six pages back on the board as a ladder, and let them see they only learned six things:

| Page | The one new idea |
| --- | --- |
| CSE 3100 | Widgets nest. `StatelessWidget` never changes. |
| Flashcards | `setState` is how the screen learns that data changed. |
| Drawer | `Navigator` is a stack of pages. |
| CGPA | User input is always a String, and never trustworthy. |
| Timer | State can change on its own — and must be cleaned up. |
| Weather | Network calls have three outcomes, not one. |
| Map | Someone already built the hard part. |

Close with: *"Every Flutter app you will ever write is these seven ideas in a different arrangement."*

---

## Likely student questions

**"Why is everything so deeply nested? It looks horrible."**
Because composition beats configuration. A widget that only does padding is a widget you can put
anywhere. Add that `Ctrl/Cmd+Shift+P` → "Wrap with..." in VS Code does the nesting for you, and the
Flutter Outline panel makes the tree readable.

**"When do I use StatelessWidget vs StatefulWidget?"**
One question: *does anything on this screen change after it's drawn?* No → Stateless. Yes → Stateful.
Start Stateless; converting later is one refactor command.

**"Is `const` actually important or just a style thing?"**
Real. A `const` widget is built once and Flutter skips rebuilding it forever. On the Timer page
`build()` runs 60 times a minute — every `const` is 60 skipped rebuilds.

**"Why `double.tryParse` instead of just converting?"**
Show them: type `abc` with `parse` and the app crashes; with `tryParse` it shows a polite message.
Bad input is a certainty, not an edge case.

**"Can I use this for my project?"**
Yes — the drawer plus one file per page is a pattern that scales to a semester project. Each student
adds a page, one import and one `_DrawerTile`.

**"Does this run on iPhone too?"**
Same code, both platforms. But building for iPhone needs a Mac and Xcode — see `install.md`.

---

## If something breaks live

| Problem | Fix, fast |
| --- | --- |
| Hot reload does nothing | Press `R` (capital = full restart). Hot reload can't pick up changes to `main()` or top-level `const` data. |
| Red error screen | Read the **first** line only, out loud. Say "this is normal, let's read it" — modelling calm debugging teaches more than a flawless demo. |
| Phone disconnects | `flutter run -d chrome` and carry on. Have it ready. |
| Weather page won't load | Campus Wi-Fi. Switch to phone hotspot, or demo the error state instead and call it intentional. |
| Map tiles stay grey | Also network. Tiles are cached, so pre-load the map once before class and it'll survive. |
| Someone asks something you don't know | "Good question, I don't know — let's find out after class." Far better than improvising. They'll trust everything else you said more.|

---

## Suggested lab exercise

Give them twenty minutes and one of these:

1. **Easy** — add three flashcards to `kCards` with your own content.
2. **Easy** — add your hometown to `kPlaces` on the map page.
3. **Medium** — add a "Previous card" button to the Flashcards page. (Watch for the negative-modulo
   trap: `(_index - 1) % length` goes wrong at zero in Dart.)
4. **Medium** — add a column to the weather table. `apparent_temperature` is already supported by the
   API; they need to add it to the `hourly=` parameter, the model, and the table.
5. **Hard** — add a new page of their own, with a drawer entry. This is the real exercise; it proves
   they understood the structure rather than just the syntax.
