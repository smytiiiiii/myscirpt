@echo off
cd /d "%~dp0"
artifacts\FXServer.exe +exec server.cfg
pause
