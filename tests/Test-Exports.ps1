param(
    [Parameter(Mandatory = $true)][string]$DllPath,
    [uint32]$ExpectedApiVersion = 1
)
$ErrorActionPreference = 'Stop'

# Put the DLL's folder first on PATH so the P/Invoke declarations below load exactly this file.
$fullPath = (Resolve-Path $DllPath).Path
$env:PATH = "$(Split-Path $fullPath);$env:PATH"

Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;

public static class VoxBridgeExports
{
    [DllImport("VoxBridge")] public static extern void initSpeech(int rate, int volume);
    [DllImport("VoxBridge")] public static extern void addToSpeechQueue([MarshalAs(UnmanagedType.LPWStr)] string text);
    [DllImport("VoxBridge")] public static extern void clearSpeechQueue();
    [DllImport("VoxBridge")] public static extern void stopSpeech();
    [DllImport("VoxBridge")] public static extern void destroySpeech();
    [DllImport("VoxBridge")] [return: MarshalAs(UnmanagedType.BStr)] public static extern string getStatusMessage();
    [DllImport("VoxBridge")] [return: MarshalAs(UnmanagedType.BStr)] public static extern string getVoicesAvailable();
    [DllImport("VoxBridge")] public static extern uint getWordLength();
    [DllImport("VoxBridge")] public static extern uint getWordPosition();
    [DllImport("VoxBridge")] public static extern uint getSpeechState();
    [DllImport("VoxBridge")] public static extern uint getApiVersion();
}
'@

# Marshal.Prelink resolves each export without calling it; a missing export throws EntryPointNotFoundException.
$missing = @()
foreach ($method in [VoxBridgeExports].GetMethods() | Where-Object { $_.DeclaringType -eq [VoxBridgeExports] }) {
    try {
        [System.Runtime.InteropServices.Marshal]::Prelink($method)
    }
    catch [System.EntryPointNotFoundException] {
        $missing += $method.Name
    }
}
if ($missing.Count -gt 0) {
    throw "Missing exports: $($missing -join ', ')"
}

$apiVersion = [VoxBridgeExports]::getApiVersion()
if ($apiVersion -ne $ExpectedApiVersion) {
    throw "getApiVersion returned $apiVersion, expected $ExpectedApiVersion"
}

Write-Host "OK: all exports found, API version $apiVersion"
