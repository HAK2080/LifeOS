# Release and device QA checklist

This checklist is the final handoff between repository work and a publishable
Android release. It is intentionally explicit because signing credentials and
physical devices are not stored in source control.

## Automated gate

- [ ] `C:\flutter\bin\flutter.bat pub get`
- [ ] `C:\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs`
- [ ] `C:\flutter\bin\flutter.bat analyze`
- [ ] `C:\flutter\bin\flutter.bat test --concurrency=1`
- [ ] `C:\flutter\bin\flutter.bat build apk --release`
- [ ] For a publishable APK/AAB, set `LIFE_KEYSTORE_PATH`,
  `LIFE_KEYSTORE_PASSWORD`, `LIFE_KEY_ALIAS`, and `LIFE_KEY_PASSWORD` before
  building. Never commit those values or the keystore.

## Physical Android checks

- [ ] Fresh install opens on Today and shows all five tabs.
- [ ] Create, complete, restore, reorder, and reminder-test a task.
- [ ] Add a habit, set its schedule/reminder, log each completion state, and
  review it.
- [ ] Create a goal and verify habit/training/nutrition/cardio contributions.
- [ ] Log a strength session, finish it, reopen history, and verify progression.
- [ ] Run a Zone 2 session manually; with Health Connect permission, sync heart
  rate and verify average/time-in-range; deny permission and verify fallback.
- [ ] Sync steps, set/clear a walking target, and verify manual walking still
  works without Health Connect.
- [ ] Log nutrition manually and exercise Photo, Voice, and Barcode paths.
- [ ] Export JSON, restore it, export encrypted backup, and restore with the
  correct password; verify a wrong password does not alter data.
- [ ] Toggle notifications off and verify no newly scheduled reminder is sent.
- [ ] Confirm temporary camera files are removed after capture.
- [ ] Check TalkBack labels, text scaling, contrast, touch targets, rotation,
  and offline behaviour.

## Store handoff

- [ ] Replace the debug fallback with a credentialed signed build.
- [ ] Record the version name/code and archive the checksum outside the repo.
- [ ] Publish the privacy policy at the distribution URL and include the
  Health Connect data-use disclosure required by the target store.
