-- This script was written by Erik M (toast_tries_art) on 20.01.2025
-- It is intended to be used in Asperite to resize the canvas to most common aspect ratios
-- V1.1

--Calculate new Size
local function calculateNewSize(width, height, ratio, keepSide)
    local ratioWidth, ratioHeight = ratio[1], ratio[2]
    if keepSide == "Width" then
      return width, math.floor(width * ratioHeight / ratioWidth)
    elseif keepSide == "Height" then
      return math.floor(height * ratioWidth / ratioHeight), height
    end
  end
  
--Main
  local function resizeCanvas()
    --Get active sprite
    local sprite = app.activeSprite
    if not sprite then
      app.alert("No active sprite found. Please open a sprite to use this script.")
      return
    end
  
    --Current Canvas Size
    local currentWidth = sprite.width
    local currentHeight = sprite.height
  
    --All Aspect Ratios
    local aspectRatios = {
      ["1:1"] = {1, 1},
      ["4:3"] = {4, 3},
      ["3:4"] = {3, 4},
      ["16:9"] = {16, 9},
      ["9:16"] = {9, 16},
      ["3:2"] = {3, 2},
      ["2:3"] = {2, 3},
      ["8:5"] = {8, 5},
      ["5:8"] = {5, 8},
      ["6:13"] = {6, 13},
      ["13:6"] = {13, 6},
    }
  
    --User Input Dialog
    local dlg = Dialog("Resize Canvas by Aspect Ratio")
  
    dlg:label{text="Current size: " .. currentWidth .. "x" .. currentHeight}
  
    dlg:combobox{
      id="aspectRatio",
      label="Aspect Ratio",
      options={"1:1", "4:3", "3:4", "16:9", "9:16", "3:2", "2:3", "8:5", "5:8", "6:13", "13:6"}
    }
  
    dlg:combobox{
      id="keepSide",
      label="Keep Side Size",
      options={"Width", "Height"}
    }
  
    dlg:button{
      text="Resize",
      onclick=function()
        local ratioKey = dlg.data.aspectRatio
        local keepSide = dlg.data.keepSide
  
        --Get chosen ratio
        local ratio = aspectRatios[ratioKey]
  
        --Calculate new dimensions
        local newWidth, newHeight = calculateNewSize(currentWidth, currentHeight, ratio, keepSide)
  
        --Resize canvas
        app.transaction(function()
          sprite:resize(newWidth, newHeight)
        end)
  
        app.alert("Canvas resized to: " .. newWidth .. "x" .. newHeight)
      end
    }
  
    dlg:button{text="Cancel"}
  
    dlg:show{wait=false}
  end
  
  resizeCanvas()
  
