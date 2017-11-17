# Imaging

The files in this repository are files to be used in the AF Imaging process.  The files are:

AutoJoin.ps1 -
Powershell script to be called by the Unattend file during First Login that will do the following items after machine is named:
 - Connects the machine to the AFMobile WiFi network
 - Calls to HP SSM on af-windeploy to install/update device drivers/Firmware/BIOS
 - Activates Windows 7
 - Activates Office
	- Office 2013 is commented, but left in case needed
	- Office 2016 is no commented, but can be removed if 2013 is used in image
 - Copies & installs Kaseya Agent
 - Join the machine to the domain
 - Delete the sysprep directory (this does not work 100%)
 - Restart the machine
 
 MidJoin.ps1 -
 Powershell script to be called at the end of "Live Deployment" where MDT is used to deploy a machine.  This script is based on the AutoJoin script and does the following:
  - Connects the machine to the AFMobile WiFi network
 - Calls to HP SSM on af-windeploy to install/update device drivers/Firmware/BIOS
 - Activates Windows 7
 - Activates Office 2016
 - Copies & installs Kaseya Agent
 - Join the machine to the domain
 
 AFUnattend.xml -
 This file is used by Sysprep & WDS to setup Windows on the machine.  It does a bunch of stuff - I'll detail it here when I have time to parse the file
 
 afwifi.xml -
 This file is used by the *Join.ps1 files to add the AFMobile network to a machine