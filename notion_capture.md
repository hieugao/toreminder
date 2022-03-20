# Notion Capture
A simple app that implements the first step of GTD — Capturing (or Quick Capture). It uses Notion Database (via Notion API) to store the "captures" through 2 ways:

- With Internet - create the captures as pages on Notion
- Without - stores the captures locally and when internet is available push it to Notion automatically in the background (without opening the app)

🚧 **Caveat:** Currently Background Sync doesn't work because I have [some problems](https://dontkillmyapp.com/xiaomi), so Manual Sync is used instead (have to open the app when the internet is available and it will "automatically" sync.

## To-dos
- [ ] Improve Offline mode: indicator (toast), etc
- [ ] Add another way to delete note beside `Dimissible`
- [ ] Handle offline (toast, etc)
- [ ] Add an Android app shortcut for quickly creating note