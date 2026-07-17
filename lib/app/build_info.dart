/// Human-readable identity for the currently distributed app build.
///
/// Keep [buildNumber] aligned with the `+N` value in pubspec.yaml whenever a
/// new installable build is created. It is shown in Settings so device
/// testing can be tied to an exact APK.
abstract final class AppBuildInfo {
  static const version = '1.0.0';
  static const buildNumber = 3;
  static const label = 'Version $version · Build $buildNumber';
}
