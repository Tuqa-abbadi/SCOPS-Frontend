# API Configuration

The app reads its backend base URL from the Dart compile-time environment key
`API_BASE_URL`.

Run the app with the current backend URL:

```bash
flutter run
```

The default backend is
`https://overgenerous-supercerebrally-russel.ngrok-free.dev/api/`. To use
another backend temporarily, override it at compile time (keep the `/api/`
suffix and trailing slash):

```bash
flutter run --dart-define=API_BASE_URL=https://example.com/api/
```

Ngrok URLs are temporary. Update the default URL and launch override when the
tunnel address changes.

If Android still shows `Failed host lookup`, the app is not reaching DNS from
the emulator or device. Open the same URL in the emulator/device browser first.
If it fails there too, cold boot the emulator, disable emulator proxy settings,
or switch the device network.
