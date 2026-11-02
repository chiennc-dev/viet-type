# Privacy

VietType converts keystrokes locally in the active input session. It retains the current composition in memory to add or remove Vietnamese diacritics and clears that composition at commit, Escape, or a session boundary.

The app does not log typed text, send keystrokes to a server, collect telemetry, or run an update checker. Preferences store only the selected typing mode and spelling option. The installer writes the input method to the current user's Library and stores prior copies under Application Support/VietType/Backups. These backups contain app files, not typed text.

Opening the help/update link uses your browser and GitHub's normal website privacy behavior. Build scripts download no third-party source dependencies. Developer notarization scripts submit the compiled software to Apple, not user typing data.
