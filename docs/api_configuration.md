# API Configuration

The app reads its backend base URL from the Dart compile-time environment key
`API_BASE_URL`.

Run the app with the current backend URL:

```bash
flutter run --dart-define=API_BASE_URL=https://men-jeff-offering-rights.trycloudflare.com/api/
```

Cloudflare `*.trycloudflare.com` URLs are temporary. When the tunnel restarts,
copy the new tunnel URL and run Flutter again with the new value:

```bash
flutter run --dart-define=API_BASE_URL=https://new-tunnel-name.trycloudflare.com/api/
```

If Android still shows `Failed host lookup`, the app is not reaching DNS from
the emulator or device. Open the same URL in the emulator/device browser first.
If it fails there too, cold boot the emulator, disable emulator proxy settings,
or switch the device network.

For production, replace the Cloudflare tunnel with a stable HTTPS API domain.
