# Changelog

## 2.0.0

- First release as a standalone repo, moved out of W40KRogueTraderSpeechMod with its history.
- Renamed from WindowsVoice to VoxBridge. The DLL is now `VoxBridge.dll`; consumers change their `DllImport` name to `"VoxBridge"`.
- API version 2: `addToSpeechQueue` takes UTF-16 text (`const wchar_t*`), new `stopSpeech`, new `getApiVersion`.
- Thread safety, COM lifetime and memory leak fixes.
- x64 only.
- Licensed under the PolyForm Strict License 1.0.0. See `LICENSE` and `NOTICE`.
