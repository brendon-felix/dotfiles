# Bootstrap development environment

## Windows
1. Ensure Powershell can execute scripts
```ps
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
2. Install FiraCode Nerd Font using `.ttf` files in FiraCode.zip (select all, right-click, click "Install")
3. Run the bootstrap script
```ps
./bootstrap-windows.ps1
```
4. If Nushell was not installed, run `winget install Nushell.Nushell` and then run
```
winget install Nushell.Nushell
nu bootstrap-windows.nu
```
