@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/. This Source Code Form is "Incompatible With Secondary Licenses", as defined by the Mozilla Public License, v. 2.0.

ECHO _^|_ = ^|_ .. -+ ^|___ = -+^| .. ^|.^| = ^|___ ^|-+^| _^|_ ^|_ _^|_ +-_

GOTO :MAIN

:TOPSP
SET "_PATH=%~1"
SET "_EXTENSION=%~2"
ffmpeg -i "!_PATH!!_EXTENSION!" -c:a aac -c:v libx264 -profile:v main -level:v 3.0 -x264opts ref=3:b-pyramid=none:weightp=1 -r 29.97 -s 480x272 -pix_fmt yuv420p -b:v 768k -ar 48000 -ab 192k "!_PATH!.psp!_EXTENSION!"
GOTO :EOF

:MAIN
WHERE ffmpeg >nul 2>&1

IF %ERRORLEVEL% EQU 0 (
    FOR %%X in (%*) DO (
        SET "_PATH=%%~dpX"
        SET "_NAME=%%~nX"
        SET "_EXTENSION=%%~xX"
        IF "!_NAME:~-4!" EQU ".psp" (SET "_PSP=1") ELSE (SET "_PSP=0")
        IF "!_EXTENSION!" EQU ".m3u8" (
            SET "_PATH=!_PATH!!_NAME!"
            ffmpeg -protocol_whitelist "file,http,https,tcp,tls" -i "!_PATH!!_EXTENSION!" -c copy -bsf:a aac_adtstoasc "!_PATH!.mp4"
            CALL :TOPSP "!_PATH!" ".mp4"
        ) ELSE IF !_PSP! EQU 0 (
            IF "!_EXTENSION!" EQU ".mp4" (
                CALL :TOPSP "!_PATH!!_NAME!" "!_EXTENSION!"
            ) ELSE (
                ECHO !_PATH!!_NAME!!_EXTENSION! is not in MP4 format.
                TIMEOUT 15
            )
        ) ELSE (
            ECHO !_PATH!!_NAME!!_EXTENSION! is already in PSP format.
            TIMEOUT 15
        )
    )
) ELSE (
    ECHO FFmpeg is not installed.
    TIMEOUT 15
)