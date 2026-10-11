#pragma once

#ifdef DLL_EXPORTS
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

#include <windows.h>
#include <oleauto.h>

namespace VoxBridge {
	// Bump on every breaking ABI change. Always equals the major version of the release tag (v1.x.y => 1).
	constexpr UINT32 API_VERSION = 1;

	extern "C" {
		DLL_API void __cdecl initSpeech(int rate, int volume);
		DLL_API void __cdecl addToSpeechQueue(const wchar_t* text);
		DLL_API void __cdecl clearSpeechQueue();
		DLL_API void __cdecl stopSpeech();
		DLL_API void __cdecl destroySpeech();
		DLL_API BSTR __cdecl getStatusMessage();
		DLL_API BSTR __cdecl getVoicesAvailable();
		DLL_API UINT32 __cdecl getWordLength();
		DLL_API UINT32 __cdecl getWordPosition();
		DLL_API UINT32 __cdecl getSpeechState();
		DLL_API UINT32 __cdecl getApiVersion();
	}

	// Part of the ABI: consumers mirror these values in this order. See README.md, "Consumer contract".
	enum class speech_state_enum { uninitialized, ready, speaking, terminated, error };
}
