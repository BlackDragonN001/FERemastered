<#
.SYNOPSIS
Creates an install of Forgotten Enemies Remastered for Battlezone Combat Commander

.PARAMETER FeInstallDirectory
The directory to create a FE install at. This does not need to already exist

.PARAMETER BzInstallDirectory
The install directory for the base game

.PARAMETER FeRepoDirectory
The location of the git repo for FERemastered

.EXAMPLE
With a powershell window open with the current working directory in the root FERemastered git folder

./install.ps1

This will create a new FE install at C:\Users\User\BZCC-FE

.EXAMPLE
With a powershell window open with the current working directory in the root FERemastered git folder

./install.ps1 -FeInstallDirectory C:\Games\FE
This will create a new FE install at C:\Games\FE

.EXAMPLE
With a powershell window open with the current working directory in the root FERemastered git folder

./install.ps1 -FeInstallDirectory C:\Games\FE -BzInstallDirectory G:\Steam\steamapps\common\BZ2R

This will create a new FE install at C:\Games\FE
This variant is useful when the game is installed at the default location
#>
[CmdletBinding()]
Param(
	[Parameter(Position=0)]
	$FeInstallDirectory = $env:USERPROFILE + "\BZCC-FE",

	[Parameter()]
	$BzInstallDirectory = "C:\Program Files (x86)\Steam\steamapps\common\BZ2R",

	[Parameter()]
	$FeRepoDirectory = "."
)

# Make the new FE directory if it does not already exist
if (-not (Test-Path $FeInstallDirectory)) {
	New-Item -Type Directory $FeInstallDirectory
}

# Symlink steam battlezone install into new location
# We will symlink each top level thing individually to give granular control over the items
Get-ChildItem $BzInstallDirectory -Exclude "bzone.cfg" | ForEach-Object {
	New-Item -Type SymbolicLink -Target $_.FullName "$FeInstallDirectory\$($_.Name)"
}

# Copy specific files
Copy-Item $BzInstallDirectory\bzone.cfg $FeInstallDirectory\bzone.cfg
Copy-Item $FeRepoDirectory\steam_appid.txt $FeInstallDirectory\steam_appid.txt

# Symlink the fe repo into addon of the game directory
New-Item -Type SymbolicLink -Target $FeRepoDirectory $FeInstallDirectory\FERemastered

Copy-Item $FeRepoDirectory\FE_RM_Config\FERM.cfg $FeInstallDirectory\FERM.cfg
Copy-Item $FeRepoDirectory\FE_RM_Config\FERM_bake.cfg $FeInstallDirectory\FERM_bake.cfg

"start .\battlezone2.exe /nointro /config FERM.cfg" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe.bat
"start .\battlezone2.exe /nointro /config FERM.cfg /noscript" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe-noscript.bat
"start .\battlezone2.exe /nointro /config FERM_bake.cfg" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe-bake.bat