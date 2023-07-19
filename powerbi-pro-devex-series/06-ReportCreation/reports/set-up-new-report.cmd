@echo off
echo:
echo Enter folder name for new report (no spaces!)
powershell.exe -command "& '..\tools\New-PbiReport.ps1'"
pause
