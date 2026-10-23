# irm https://felixb.dev/win | iex

$ErrorActionPreference = 'Stop'

$repo = 'https://github.com/brendon-felix/dotfiles.git'
$dest = Join-Path $HOME 'Projects\dotfiles'

function Update-SessionPath {
    $env:Path = @('Machine', 'User' | ForEach-Object { [Environment]::GetEnvironmentVariable('Path', $_) }) -join ';'
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing Git...'
    winget install --id Git.Git --exact --accept-source-agreements --accept-package-agreements
    Update-SessionPath
}

if (Test-Path (Join-Path $dest '.git')) {
    Write-Host "Updating $dest"
    git -C $dest pull --ff-only
} else {
    Write-Host "Cloning $repo -> $dest"
    git clone $repo $dest
}

# Elevated processes start in System32, and bootstrap-windows.ps1 resolves bootstrap-windows.nu relative to the cwd.
$bootstrap = "Set-Location -LiteralPath '$dest'; & .\bootstrap-windows.ps1"
Start-Process powershell -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-NoExit', '-Command', $bootstrap)
