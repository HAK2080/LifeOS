@echo off
rem Run the app in Chrome for quick testing on PC.
set PATH=C:\flutter\bin;%PATH%
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
cd /d "%~dp0"
flutter run -d chrome --release
