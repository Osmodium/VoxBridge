# VoxBridge

Native Windows DLL that gives Unity mods text-to-speech through Microsoft SAPI 5.
Used by the SpeechMod family: [Warhammer 40K: Rogue Trader](https://github.com/Osmodium/W40KRogueTraderSpeechMod), [Pathfinder: Wrath of the Righteous](https://github.com/Osmodium/PathfinderTextToSpeechMod) and [Pathfinder: Kingmaker](https://github.com/Osmodium/KingmakerSpeechMod).

Formerly named WindowsVoice. Named after the vox, the voice-transmitter of the 40K universe.

## Download

Get `VoxBridge.dll` from [Releases](https://github.com/Osmodium/VoxBridge/releases).

- x64 only.
- The C runtime is linked statically, so users need no Visual C++ redistributable.
- Every release also has `VoxBridge.dll.sha256` and `VoxBridge.pdb`.

## Consumer contract (API version 1)

All exports are `extern "C"`, `__cdecl`, with undecorated names. The DLL file is `VoxBridge.dll`, so the `DllImport` name is `"VoxBridge"`.

| Export | Signature | Behaviour |
| --- | --- | --- |
| `initSpeech` | `void (int rate, int volume)` | Starts the speech thread. `rate` goes to `ISpVoice::SetRate`, `volume` to `ISpVoice::SetVolume`. |
| `addToSpeechQueue` | `void (const wchar_t* text)` | Queues UTF-16, NUL-terminated text. Spoken with `SPF_IS_XML`, so SAPI XML/SSML markup is allowed. |
| `clearSpeechQueue` | `void ()` | Drops queued text. |
| `stopSpeech` | `void ()` | Stops the current speech. |
| `destroySpeech` | `void ()` | Stops the speech thread and releases SAPI. Call once on shutdown. |
| `getStatusMessage` | `BSTR ()` | Last status or error message. The caller frees the BSTR. |
| `getVoicesAvailable` | `BSTR ()` | Installed voices, one per line: `<name>#<language>\n`. Natural voices have "Natural" in the language part. The caller frees the BSTR. |
| `getWordLength` | `UINT32 ()` | Length of the word being spoken, in characters of the input text. |
| `getWordPosition` | `UINT32 ()` | Position of the word being spoken, in characters of the input text. |
| `getSpeechState` | `UINT32 ()` | `0` uninitialized, `1` ready, `2` speaking, `3` terminated, `4` error. |
| `getApiVersion` | `UINT32 ()` | API version of this DLL. Currently `1`. |

.NET's `[return: MarshalAs(UnmanagedType.BStr)]` frees returned BSTRs for you.

### C# declarations

```csharp
[DllImport("VoxBridge")] static extern void initSpeech(int rate, int volume);
[DllImport("VoxBridge")] static extern void addToSpeechQueue([MarshalAs(UnmanagedType.LPWStr)] string text);
[DllImport("VoxBridge")] static extern void clearSpeechQueue();
[DllImport("VoxBridge")] static extern void stopSpeech();
[DllImport("VoxBridge")] static extern void destroySpeech();
[DllImport("VoxBridge")] [return: MarshalAs(UnmanagedType.BStr)] static extern string getStatusMessage();
[DllImport("VoxBridge")] [return: MarshalAs(UnmanagedType.BStr)] static extern string getVoicesAvailable();
[DllImport("VoxBridge")] static extern uint getWordLength();
[DllImport("VoxBridge")] static extern uint getWordPosition();
[DllImport("VoxBridge")] static extern uint getSpeechState();
[DllImport("VoxBridge")] static extern uint getApiVersion();
```

Check `getApiVersion()` at startup. The old `WindowsVoice.dll` has no `getApiVersion` export, so calling it there throws `EntryPointNotFoundException`.

### Moving from WindowsVoice

1. Ship `VoxBridge.dll` instead of `WindowsVoice.dll`.
2. Change every `DllImport("WindowsVoice")` to `DllImport("VoxBridge")`.
3. Pass text to `addToSpeechQueue` as UTF-16 (`[MarshalAs(UnmanagedType.LPWStr)] string`).

## Versioning

- Release tags are `vMAJOR.MINOR.PATCH`.
- `MAJOR` always equals `API_VERSION` in `VoxBridge.h`.
- Any breaking change to an export, the text encoding or the state values bumps both.

## Building

1. Install Visual Studio 2026 with the "Desktop development with C++" workload (toolset v145).
2. Build `VoxBridge.sln`, configuration `Release`, platform `x64`. The sources and the project file are in `src/`.
3. Output: `bin\x64\Release\VoxBridge.dll`.
4. Check the exports: `pwsh -File tests\Test-Exports.ps1 -DllPath bin\x64\Release\VoxBridge.dll`.

## Releasing

1. Update `CHANGELOG.md`.
2. Push a tag `vX.Y.Z`.
3. The `build` workflow builds, tests and publishes a GitHub Release with the DLL, PDB and SHA256 file.

## Credits

Details and license terms of third-party code are in [NOTICE](NOTICE).

- Based on Chad Weisshaar's [Microsoft Speech for Unity](https://blog.chadweisshaar.com/2015/07/02/microsoft-speech-for-unity/), published as "Free for all use and open source".
- Voice naming and Natural voice detection by [gexgd0419](https://github.com/gexgd0419).

## License

Copyright (c) 2021-2026 Christian Schubert (Osmodium).

Licensed under the [PolyForm Strict License 1.0.0](LICENSE).

- You may use VoxBridge for noncommercial purposes.
- You may not distribute it, change it or build new works on it.
- For anything else, ask in an [issue](https://github.com/Osmodium/VoxBridge/issues).
- Third-party parts keep their own terms. See [NOTICE](NOTICE).
