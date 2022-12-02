# Forgotten Enemies: Remastered

## Mod Manager Installation Instructions:

1. Download and extract the latest realease of the Battlezone Redux Mod Manager:

	https://github.com/Nielk1/Battlezone-Redux-Mod-Manager/releases

1. Following the setup instructions for BZRMM - open `BZRModManager.exe` and select the `Settings` tab. Make sure to set the install location for BZCC (either GOG or Steam) and set the `My Docs/My Games` folder location 
![](docs/BZRMM_Settings.PNG)

1. On the BZCC tab, paste the github url for FER (https://github.com/BlackDragonN001/FERemastered.git) into the `Mod URL` field and click download (This will take a long time to download, See the `Tasks` tab to watch the current progress)
![](docs/BZRMM_ModURL.PNG)

1. Once `Busy Tasks` is 0 in the status at the bottom of BZRMM, select all FER Mods and choose either `Install GOG` or `Install Steam` in the right-click menu
![](docs/BZRMM_Install.PNG)

1. Start Battlezone2 and activate `Forgotten Enemies: Remastered` from the mods menu

1. Have fun!

## Powershell Install Instructions

1. Open an administrator powershell window (type 'powershell' into windows search and right click and select 'Run as administrator')

1. Run the following command `Set-ExecutionPolicy -Scope Process Unrestricted`

1. Navigate to the FERemastered repo in powershell. This can be done by running `cd "C:\Users\User\FERemastered"` if the FERemastered repo was cloned into `C:\Users\User\FERemastered`

1. Run `.\install.ps1`. This will create an install of FERemastered in your user home directory.
> The install directory can be customised by running `./install.ps1 -FeInstallDirectory C:\Games\FE`

> If the install directory of Battlezone Combat Commander is different to default you can run the following `./install.ps1 -FeInstallDirectory C:\Games\FE -BzInstallDirectory G:\Steam\steamapps\common\BZ2R`
