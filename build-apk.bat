@echo off
rem Build the installable release APK.
rem Output: build\app\outputs\flutter-apk\app-release.apk
set PATH=C:\flutter\bin;%PATH%
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set GRADLE_OPTS=-Djavax.net.ssl.trustStore=C:/flutter/.certs/cacerts -Djavax.net.ssl.trustStorePassword=changeit
cd /d "%~dp0"
flutter build apk --release
echo.
echo APK ready: %~dp0build\app\outputs\flutter-apk\app-release.apk
pause
