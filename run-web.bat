@echo off
rem Build and serve a stable release web preview on port 5180.
rem This avoids the Flutter debug web-server bridge used by the embedded
rem browser, which can terminate the browser session on this machine.
set PATH=C:\flutter\bin;%PATH%
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
cd /d "%~dp0"
call flutter build web --release
if errorlevel 1 exit /b %errorlevel%
cd /d "%~dp0build\web"
python -m http.server 5180 --bind 127.0.0.1
