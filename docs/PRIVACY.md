# Life privacy policy

Last updated: 2026-07-17

Life is an offline-first personal app. It does not require an account and does
not send personal data to a Life server. Tasks, meals, training, growth logs,
profile values, and backups remain on the device unless the user explicitly
chooses to share a backup through the operating system share sheet.

Photos used for meal, equipment, console, or progress analysis are temporary.
The app does not retain the image after the analysis/editing step. Progress
photo records retain only the user-approved estimate, date, trend, and
confidence.

Health Connect access is optional and read-only in the current app. When
permission is granted, Life reads steps and heart-rate samples to show them in
the relevant training screens. Manual entry remains available when permission
is denied or Health Connect is unavailable.

Voice capture is used to populate an editable meal name. The user chooses
whether to save the resulting meal log. When the user chooses barcode capture,
Life sends only the scanned barcode to the public Open Food Facts service to
look up an editable food estimate. Successful results are cached locally. If
the service is unavailable or the user is offline, manual entry remains
available; Life does not upload the meal diary or profile with the request.

The diagnostics report contains build/platform status, permissions, last-sync
time, and local row counts. It does not include task titles, meal names, notes,
profile values, workout contents, or other user-entered content. The report is
shared only when the user explicitly opens the system share sheet.

Plain JSON exports are readable backups. Encrypted backups use a password-based
PBKDF2 key and AES-256-GCM. Life does not know or recover the password. Anyone
who receives an exported backup may access its contents if it is not encrypted,
or if they have the encryption password.

The app uses local notifications only for reminders the user enables. It does
not use advertising identifiers, social features, leaderboards, or guilt-based
tracking.
