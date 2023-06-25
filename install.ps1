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

function New-Symlink {
	Param($Source, $Target)

	Write-Verbose "Symlink Source: $Source"
	Write-Verbose "Symlink Target: $Target"

	# Need to check if it is a file or a folder to pass to mklink
	if ((Get-Item $Source).PSIsContainer) {
		cmd /c mklink /D $Target $Source > $null
	} else {
		cmd /c mklink $Target $Source > $null
	}
}

function Invoke-FESetup {
	[CmdletBinding()]
	Param($FeInstallDirectory, $BzInstallDirectory, $FeRepoDirectory)

	# Make the new FE directory if it does not already exist
	if (-not (Test-Path $FeInstallDirectory)) {
		New-Item -Type Directory $FeInstallDirectory > $null
	}

	# Now we know that every folder should exist, resolve any relative paths
	$FeInstallDirectory = Resolve-Path $FeInstallDirectory
	$BzInstallDirectory = Resolve-Path $BzInstallDirectory
	$FeRepoDirectory = Resolve-Path $FeRepoDirectory

	Write-Verbose $FeInstallDirectory
	Write-Verbose $BzInstallDirectory
	Write-Verbose $FeRepoDirectory

	Write-Host "Creating links to Battlezone install..."

	# Symlink steam battlezone install into new location
	# We will symlink each top level thing individually to give granular control over the items
	Get-ChildItem $BzInstallDirectory -Exclude "bzone.cfg" | ForEach-Object {
		# New-Item -Type SymbolicLink -Target $_.FullName "$FeInstallDirectory\$($_.Name)"
		New-Symlink $_.FullName "$FeInstallDirectory\$($_.Name)"
	}

	Write-Host "Copying battlezone config files..."
	Copy-Item $BzInstallDirectory\bzone.cfg $FeInstallDirectory\bzone.cfg

	Write-Host "Creating links to Forgotten Enemies install..."
	New-Symlink $FeRepoDirectory $FeInstallDirectory\FERemastered

	Write-Host "Copying Forgotten Enemies config..."
	Copy-Item $FeRepoDirectory\baked\FE_RM_Config\FERM.cfg $FeInstallDirectory\FERM.cfg
	Copy-Item $FeRepoDirectory\baked\FE_RM_Config\FERM_bake.cfg $FeInstallDirectory\FERM_bake.cfg
	Copy-Item $FeRepoDirectory\steam_appid.txt $FeInstallDirectory\steam_appid.txt

	Write-Host "Creating batch shortcuts..."
	"start .\battlezone2.exe /nointro /config FERM.cfg" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe.bat
	"start .\battlezone2.exe /nointro /config FERM.cfg /noscript" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe-noscript.bat
	"start .\battlezone2.exe /nointro /config FERM_bake.cfg" | Out-File -Encoding ascii $FeInstallDirectory\bzone-fe-bake.bat

	Write-Host
	Write-Host -ForegroundColor Yellow @"
Finished installing Forgotten Enemies.

To play the mod head to '$FeInstallDirectory' and run 'bzone-fe.bat'
"@
}

$args = @{
	FeInstallDirectory = $FeInstallDirectory
	BzInstallDirectory = $BzInstallDirectory
	FeRepoDirectory = $FeRepoDirectory
	ErrorAction = 'Stop'
}

Invoke-FESetup @args