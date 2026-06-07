/// Base URL of the Taskko backend (Next.js API on Vercel, or local dev).
///
/// Defaults to the Android emulator's host-loopback (`10.0.2.2`) on port 3000,
/// so `npm run dev` in `admin/` is reachable from an emulator out of the box.
/// Override at build/run time:
///   --dart-define=BACKEND_URL=https://taskko-admin.vercel.app
///   --dart-define=BACKEND_URL=http://192.168.1.20:3000   (physical device on LAN)
abstract final class BackendConfig {
  static const String baseUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: 'https://taskkoadmin.vercel.app');
}
