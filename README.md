# TrailMark10_1

## Assignment 1 - Pocket Sync

Yes, this one is mostly done in the code.

The watch and phone both start `WCSession` through `ConnectivityManager`. The watch can quick log an activity, and that gets sent to the phone with `transferUserInfo`. On the phone, it shows up in Journeys as a watch activity.

Voice memos use `transferFile`, which makes sense because the audio is an actual file. The memo info is sent with the file metadata. When the phone gets it, it moves the file into the media folder and adds the memo to the Journal.

| Payload | Transfer type | Why |
|---|---|---|
| Today's summary | `updateApplicationContext` | Only the newest summary matters. |
| Quick Log activity | `transferUserInfo` | It is a record that should be queued and delivered later if needed. |
| Voice memo | `transferFile` | It is an audio file, so file transfer is the right choice. |

I did not use `sendMessage` for these because it only works when the other device is reachable right then. If the phone is locked or in a pocket, it could fail. `sendMessage` would be better for something live where late delivery would not help.

The file receive code copies the file before jumping to the main actor because the system's temporary file can go away after the callback ends.

For resend, the same memo `id` and `fileName` are used, so the phone replaces the old copy instead of making a duplicate.
