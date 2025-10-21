# bootstrap-windows.ps1

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"") -Verb RunAs
    exit
}

Write-Host "Installing Nushell..."
winget install Nushell.Nushell --accept-source-agreements --accept-package-agreements
Write-Host ""

Write-Host "Running Nushell bootstrap script"
Write-Host ""
# cmd /c "nu bootstrap-windows.nu"
Start-Process nu -ArgumentList "bootstrap-windows.nu" -NoNewWindow -Wait
