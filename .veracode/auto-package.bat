@echo off

:: Change into the directory where this script is running
pushd %~dp0

:: Set repo_root to the root folder of the repository (i.e. where the .git metadata folder is located)
for /F "tokens=*" %%g in ('git rev-parse --show-toplevel') do (set repo_root=%%g)
set repo_root=%repo_root:/=\%
pushd %repo_root%

:: Set output_dir variable to the full path where auto packaged artifacts should be placed
set output_dir=%repo_root%\.veracode\output\auto

:: Install CLI with chocolatey if not present.
where /q veracode
if ERRORLEVEL 1 (
    set veracode_install=%repo_root%\.veracode\veracode-install.ps1
    echo Set-ExecutionPolicy AllSigned -Scope Process -Force;$ProgressPreference = "silentlyContinue"; iex ^(^(New-Object System.Net.WebClient^).DownloadString^('https://tools.veracode.com/veracode-cli/install.ps1'^)^) > %veracode_install%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Wait -Verb RunAs powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%veracode_install%\"'"
    del %veracode_install%
)

:: Run the packager
veracode package --source %repo_root% --type directory --output %output_dir% --trust

popd
popd
