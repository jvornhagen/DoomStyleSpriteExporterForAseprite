# Doom Naming Style (DNS) Exporter For Aseprite
This script allows to automatically export Aseprite animations as a series of images named in the Doom naming style.

Created/tested on Aseprite v1.3.2-x64 on Windows.


## Installation:
Put the DoomStyleSpriteExporter.lua file into your Aseprite scripts folder (File -> Scripts -> Open Scripts Folder)

## Use:
Select the sprite you want to export. If you just want to export a specific range of frames, select the range as well.
Start the script by going to File -> Scripts -> DoomStyleSpriteExporter (If you have just put the file in the scripts folder press "Rescan Scripts Folder" first).

In the export dialog:
  - Name: Set the name for the sprite to be exported (Defaults to the first 4 letters of the sprite)
  - Sprite Angle: Select the angle the srite represents by pressing one of the buttons. An explanation can be found at https://zdoom.org/wiki/Sprite#Angles
  - If you select an angle you can mirror (eg 2,3,4), a checkbox to enable mirroring appears. Ie: Turn POSSA2 to POSSA2A8
  - Check "Only export selected frames?" to do just that
  - Select the File Type
  - Click on File Path to change the location of the exported files. No need to name the exported files as the script will name them. (Defaults to the open sprites file path)
    - The file path button will display a preview of the name for the first file.
  - Press "Export" to start the export.

## License
CC BY 4.0

## Known Issue:
The use of \ in a file name messes things up atm. Export still works, but one file will be exported into a new sub folder (at least on windows).
