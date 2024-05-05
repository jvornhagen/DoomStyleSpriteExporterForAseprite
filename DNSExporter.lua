-- Created by Jan Vornhagen: https://int-game.itch.io/
-- tested on Aseprite v1.32-x64 with API version 26; Please report any bugs/feature requests at https://github.com/jvornhagen/DoomStyleSpriteExporterForAseprite
-- License "CC-BY-4.0"
-- Special thanks to https://www.patreon.com/posts/aseprite-export-96589806 who devised a workaround for the SaveFileCopyAs glitch that does not allow the saving of single frames.


-- Setup
local spr = app.sprite

-- Checks for a valid sprite
if not spr then
  app.alert("There is no sprite to export")
  return
end

-- Local Variables
local alphabetArray = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]"}
local sprName = app.sprite.filename
local fileName = app.fs.fileName(spr.filename)
local filePath = app.fs.filePath(spr.filename)
local mirrored_numbers = {
	["1"] = "5",
    ["2"] = "8",
    ["3"] = "7",
	["4"] = "6",
	["5"] = "1",
    ["6"] = "4",
	["7"] = "3",
    ["8"] = "2",
	["9"] = "G",
	["A"] = "F",
	["B"] = "E",
	["C"] = "D",
	["D"] = "C",
	["E"] = "B",
	["F"] = "A",
	["G"] = "9",
}
local frameRange = app.range.frames
local previewName = "ACABA0.png"
--
--

-- Local Functions

local function MirroredNumber (angleNumber)
	return mirrored_numbers[angleNumber] or 99
end


local function CreateName(iteration, path, name, startingLetter, angle, extension, isMirrored)
	local returnName
	
	if isMirrored then
			returnName = path .. app.fs.pathSeparator .. name .. alphabetArray[iteration] .. angle .. alphabetArray[iteration] .. MirroredNumber(angle) .. extension
		else
			returnName = path .. app.fs.pathSeparator .. name .. alphabetArray[iteration] .. angle .. extension
		end

	return returnName
end

local function LetterPosition(val)
   
   letter = tostring(val)
   
   for i=1,#alphabetArray do
      if alphabetArray[i] == letter then 
         return i
      end
   end
   return "NotInArray"
end


local function ExportAllFrames(myExportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)
	startingIteration = LetterPosition(myStartingLetter)
	
	for i,frame in ipairs(spr.frames) do		
		local exportName = CreateName(startingIteration + i-1, myExportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)	
		local img = Image(spr.width, spr.height)
		img:drawSprite(spr, i, Point(0, 0))
		img:saveAs(exportName)	
	end
	
end

local function ExportSelectedFramesOnly(myExportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)
	
	startingIteration = LetterPosition(myStartingLetter)
	
	for i,frame in ipairs(frameRange) do
		local exportName = CreateName(startingIteration + i-1, myExportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)	
		local img = Image(spr.width, spr.height)
		img:drawSprite(spr, frameRange[i], Point(0, 0))
		img:saveAs(exportName)	
	end
	
end

local function DoomStyleExport(myExportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored, onlyExportSelectedFrames)
	-- clean export Name
	local exportPath = app.fs.filePath(myExportPath)
	if exportPath == "" then
		exportPath = filePath		
	end
	
	if onlyExportSelectedFrames then
	-- only export selected Frames
		ExportSelectedFramesOnly(exportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)
	else
	-- export All Frames
		ExportAllFrames(exportPath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored)
	end

end

-- Check if too many frames
local function ValidFrameNumber(exportSelectedFrames)
	if exportSelectedFrames then
		if #(frameRange) > 29 then
			app.alert("You have selected more than 29 frames. Doom naming only works up to 29 frames. Please split the file or select a smaller subset of frames.")
			return false
		else
			return true
		end
	elseif #(app.sprite.frames) > 29 then
		app.alert("There are more than 29 frames in this sprite. Doom naming only works up to 29 frames. Please split the file or select a subset to export.")		
		return false
	else
		return true
	end
end

-- Check if too many frames when not starting at A
local function CheckAvailableFrames(exportSelectedFrames, letter)

	givenLetterPosition = LetterPosition(letter)
	if givenLetterPosition == "NotInArray" then
		app.alert("Not a valid letter. Please choose A-Z, [, \\, or ]")		
		return false
	end
	
	letterContingent = #alphabetArray - givenLetterPosition
	
	if exportSelectedFrames then
		if #(frameRange) > letterContingent then
			app.alert("Starting with letter " .. letter .. ", there is not enough letters left to save all selected frames. Please start with an earlier letter or choose less frames")
			return false
		else
			return true
		end
	elseif #(app.sprite.frames) > letterContingent then
		app.alert("Starting with letter " .. letter .. ", there is not enough letters left to save all selected frames. Please start with an earlier letter or choose less frames")		
		return false
		
	else
		return true
	end 
end

-- Preview File Name
local function UpdateNamePreview(myFilePath, mySpriteName, myStartingLetter, myAngle, myExtension, isMirrored, onlySelectedFrames)
	
	if isMirrored then
		previewName = myFilePath .. app.fs.pathSeparator .. mySpriteName .. myStartingLetter .. myAngle .. myStartingLetter .. MirroredNumber(myAngle) .. myExtension
	else
		previewName = myFilePath .. app.fs.pathSeparator .. mySpriteName .. myStartingLetter .. myAngle .. myExtension
	end	
end

local function NamePreviewHandler(data)
	if data == nil then
		UpdateNamePreview(filepath, "ABCD", "A", 0, ".png", false)
	else
		UpdateNamePreview(app.fs.filePath(data.exportPath), data.spriteName, data.startingLetter, data.angle, data.exportExtension, data.mirrored, data.exportSelectedFrames)		
	end
end

local function SetStartingLetter(data)
	returnLetter = "A"
	if(data.exportSelectedFrames) then
		returnLetter = alphabetArray[frameRange[1].frameNumber]
	end	
	return returnLetter
end

local function MirrorPossible(angle)
	if MirroredNumber(angle) == 99 then
		return false
	else 
		return true
	end
end

local function AngleClickHandler(dlg, change)
	dlg:modify{id="angle",
		text=change}
	NamePreviewHandler(dlg.data)
	if not MirrorPossible(change) then 
				dlg:modify{id="mirrored", selected=false, visible=false}
			else 
				dlg:modify{id="mirrored", visible=true}
			end
	dlg:modify {id="exportPath", filename=previewName} 
	dlg:repaint()
end
--
--

-- Main


local dlg = Dialog("Doom Naming Style Exporter")
local data = dlg.data
-- Enter 4 Letters for Name
dlg:entry{
		id="spriteName",
		label="Sprite Name (4 symbols)",
		text= string.upper(string.sub(fileName, 1, 4)),
		onchange= function() 
			NamePreviewHandler(dlg.data) 
			dlg:modify {id="exportPath", filename=previewName} 
			dlg:repaint() 
		end
		}
-- Angle Buttons
   :label{id="string", label="Select your Sprite Angle:"}
   :button{id="FourOuter", 	text="4 (135°)", 	onclick= function() AngleClickHandler(dlg, "4") end, label=""}
   :button{id="C", 			text="C (157.5°)", 	onclick= function() AngleClickHandler(dlg, "C") end}
   :button{id="FiveOuter", 	text="5 (180°)", 	onclick= function() AngleClickHandler(dlg, "5") end}
   :button{id="D", 			text="D (202.5°)", 	onclick= function() AngleClickHandler(dlg, "D") end}
   :button{id="SixOuter", 	text="6 (225°)", 	onclick= function() AngleClickHandler(dlg, "6") end}
   :newrow()
   :button{id="B", 			text="B (112.5°)", 	onclick= function() AngleClickHandler(dlg, "B") end, label=""}
   :button{id="FourInner", 	text="4", 			onclick= function() AngleClickHandler(dlg, "4") end}
   :button{id="FiveInner", 	text="5", 			onclick= function() AngleClickHandler(dlg, "5") end}
   :button{id="SixInner",  	text="6", 			onclick= function() AngleClickHandler(dlg, "6") end}
   :button{id="E", 			text="E (247.5°)", 	onclick= function() AngleClickHandler(dlg, "E") end}
   :newrow()
   :button{id="ThreeOuter",	text="3 (112.5°)", 	onclick= function() AngleClickHandler(dlg, "3") end, label=""}
   :button{id="ThreeInner", text="3", 			onclick= function() AngleClickHandler(dlg, "3") end}
   :button{id="Zero", 		text="0", 			onclick= function() AngleClickHandler(dlg, "0") end}
   :button{id="SevenInner", text="7", 			onclick= function() AngleClickHandler(dlg, "7") end}
   :button{id="SevenOuter", text="7 (270°)", 	onclick= function() AngleClickHandler(dlg, "7") end}
   :newrow()
   :button{id="A", 			text="A (67.5°)", 	onclick= function() AngleClickHandler(dlg, "A") end, label=""}
   :button{id="TwoInner", 	text="2", 			onclick= function() AngleClickHandler(dlg, "2") end}
   :button{id="OneInner", 	text="1", 			onclick= function() AngleClickHandler(dlg, "1") end}
   :button{id="EightInner",	text="8", 			onclick= function() AngleClickHandler(dlg, "8") end}
   :button{id="F", 			text="F (292.5°)", 	onclick= function() AngleClickHandler(dlg, "F") end}
   :newrow()
   :button{id="TwoOuter", 	text="2 (45°)", 	onclick= function() AngleClickHandler(dlg, "2") end, label=""}
   :button{id="Nine",		text="9 (22.5°)", 	onclick= function() AngleClickHandler(dlg, "9") end}
   :button{id="OneOuter", 	text="1 (0°)", 		onclick= function() AngleClickHandler(dlg, "1") end}
   :button{id="G", 			text="G (337.5°)", 	onclick= function() AngleClickHandler(dlg, "G") end}
   :button{id="EightOuter",	text="8 (315°)", 	onclick= function() AngleClickHandler(dlg, "8") end}

-- Enter angle number for direction
   :entry{id="angle",
		label="Selected angle/manual entry",
		text="0",
		onchange= function() 
			NamePreviewHandler(dlg.data)
			if not MirrorPossible(dlg.data.angle) then 
				dlg:modify{id="mirrored", selected=false, visible=false}
			else 
				dlg:modify{id="mirrored", visible=true}
			end
			dlg:modify {id="exportPath", filename=previewName} 
			dlg:repaint() 
		end
		}
	
   :label{id="string2", text="For more info go to: https://zdoom.org/wiki/Sprite#Angles"}
-- Checkbox For Mirrored
   :check{id="mirrored",
		label="Mirror Sprite angle?",
		selected=false,
		visible=false,
		onclick= function() 
			NamePreviewHandler(dlg.data) 
			dlg:modify {id="exportPath", filename=previewName}
			dlg:repaint() 
		end
		}

-- Checkbox Export all or just selection
	:check{id="exportSelectedFrames",
		label="Only export selected frames?",
		selected=false,
		onclick = function()						
			dlg:modify {id="startingLetter", text=SetStartingLetter(dlg.data)}
			NamePreviewHandler(dlg.data)
			dlg:modify {id="exportPath", filename=previewName} 
			dlg:repaint()
		end
		}	
-- Starting letter
	:entry{
		id="startingLetter",
		label="Letter to start export at",
		text= "A",
		onchange= function() 
			NamePreviewHandler(dlg.data)
			dlg:modify {id="exportPath", filename=previewName} 
			dlg:repaint() 
		end
		}

-- Extension
   :combobox{id="exportExtension",
		label="File Type",
		option=".png",
		options={".ase", ".aseprite", ".bmp", ".css", ".flc", ".fli", ".gif", ".ico", ".jpeg", ".jpg", ".pcx", ".pcc", ".png", ".qoi", ".svg", ".tga", ".webp"},
		onchange= function() 
			NamePreviewHandler(dlg.data)
			dlg:modify {id="exportPath", filename=previewName} 
			dlg:repaint() 
		end
		}
		
-- FilePath
   :file{id="exportPath",
		label="Set file path:",
		filename=previewName,
		filetypes={".ase", ".aseprite", ".bmp", ".css", ".flc", ".fli", ".gif", ".ico", ".jpeg", ".jpg", ".pcx", ".pcc", ".png", ".qoi", ".svg", ".tga", ".webp"},
		save=true
		}
	
-- Button Export
   :button{ id="export", text="Export", focus=true }
-- Button Cancel
   :button{ id="cancel", text="Cancel" }

NamePreviewHandler(dlg.data) 
	dlg:modify {id="exportPath", filename=previewName}
	dlg:repaint()

-- Show the Dialog
   dlg:show()

if not dlg.data.export then
	return
end

-- First check if export is possible
if not ValidFrameNumber(dlg.data.exportSelectedFrames) then
	return
end
if not CheckAvailableFrames(dlg.data.exportSelectedFrames, dlg.data.startingLetter) then
	return
end

-- if so, start export with given info
DoomStyleExport(dlg.data.exportPath, dlg.data.spriteName, dlg.data.startingLetter, dlg.data.angle, dlg.data.exportExtension, dlg.data.mirrored, dlg.data.exportSelectedFrames)
