@echo off
setlocal
cd /d "%~dp0"
if errorlevel 1 exit /b 1

if "%~1"=="" (
    set "stage=all"
) else (
    set "stage=%~1"
)
if not "%~2"=="" (
    echo Error: provide at most one stage argument. 1>&2
    exit /b 2
)

if /I "%stage%"=="configure" goto configure_only
if /I "%stage%"=="build" goto build_only
if /I "%stage%"=="test" goto test_only
if /I "%stage%"=="install" goto install_only
if /I "%stage%"=="run" goto run_only
if /I "%stage%"=="all" goto all_stages
echo Error: unknown stage "%stage%". 1>&2
exit /b 2

:all_stages
call :do_configure
if errorlevel 1 exit /b 1
call :do_build
if errorlevel 1 exit /b 1
call :do_test
if errorlevel 1 exit /b 1
call :do_install
if errorlevel 1 exit /b 1
call :do_run
if errorlevel 1 exit /b 1
exit /b 0

:configure_only
call :do_configure
exit /b %errorlevel%

:build_only
call :do_build
exit /b %errorlevel%

:test_only
call :do_test
exit /b %errorlevel%

:install_only
call :do_install
exit /b %errorlevel%

:run_only
call :do_run
exit /b %errorlevel%

:do_configure
echo ==^> [configure]
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1
exit /b 0

:do_build
echo ==^> [build]
cmake --build build --config Release --parallel
if errorlevel 1 exit /b 1
exit /b 0

:do_test
echo ==^> [test]
ctest --test-dir build -C Release --output-on-failure
if errorlevel 1 exit /b 1
exit /b 0

:do_install
echo ==^> [install]
cmake --install build --config Release --prefix dist
if errorlevel 1 exit /b 1
exit /b 0

:do_run
echo ==^> [run]
set "run_id=%RANDOM%-%RANDOM%"
set "actual_file=%TEMP%\hello-output-%run_id%.txt"
set "expected_file=%TEMP%\hello-expected-%run_id%.txt"
> "%expected_file%" echo Hello, World!
if errorlevel 1 exit /b 1
dist\bin\hello.exe > "%actual_file%"
if errorlevel 1 goto run_failed
fc /b "%expected_file%" "%actual_file%" >nul
if errorlevel 1 goto run_mismatch
type "%actual_file%"
if errorlevel 1 goto run_failed
del /q "%actual_file%" "%expected_file%"
if errorlevel 1 exit /b 1
exit /b 0

:run_mismatch
echo Error: dist\bin\hello.exe output did not match "Hello, World!". 1>&2
del /q "%actual_file%" "%expected_file%" >nul 2>&1
exit /b 1

:run_failed
del /q "%actual_file%" "%expected_file%" >nul 2>&1
exit /b 1
