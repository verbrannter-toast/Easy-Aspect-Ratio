-- This script was written by Erik M (toast_tries_art) on 21.01.2025
-- It is intended to be used in Asperite to resize the canvas to most common aspect ratios
-- V1.2

--Function to calculate new dimensions
local function calculateNewSize(width, height, ratio, keepSide)
  local ratioWidth, ratioHeight = ratio[1], ratio[2]
  if keepSide == "Width" then
    return width, math.floor(width * ratioHeight / ratioWidth)
  elseif keepSide == "Height" then
    return math.floor(height * ratioWidth / ratioHeight), height
  end
end

--Main function to resize canvas
local function resizeCanvas()
  -- Get active sprite
  local sprite = app.activeSprite
  if not sprite then
    app.alert("No active sprite found. Please open a sprite to use this script.")
    return
  end

  --Current canvas Size
  local currentWidth = sprite.width
  local currentHeight = sprite.height

  --All aspect ratios
  local aspectRatios = {
    ["1:1"] = {1, 1},
    ["4:3"] = {4, 3},
    ["3:4"] = {3, 4},
    ["16:9"] = {16, 9},
    ["9:16"] = {9, 16},
    ["5:4"] = {5, 4},
    ["4:5"] = {4, 5},
    ["3:2"] = {3, 2},
    ["2:3"] = {2, 3},
    ["8:5"] = {8, 5},
    ["5:8"] = {5, 8},
    ["6:13"] = {6, 13},
    ["13:6"] = {13, 6},
  }

  --Initialize dialog and state
  local dlg = Dialog("Resize Canvas by Aspect Ratio")
  local previewText = "Select options to see the new size."

  --Function to update preview dynamically
  local function updatePreview()
    local ratioKey = dlg.data.aspectRatio
    local keepSide = dlg.data.keepSide

    if not ratioKey or not keepSide then
      dlg:modify{id="preview", text="Select options to see the new size."}
      return
    end

    local ratio = aspectRatios[ratioKey]
    local newWidth, newHeight = calculateNewSize(currentWidth, currentHeight, ratio, keepSide)
    dlg:modify{id="preview", text="New size: " .. newWidth .. "x" .. newHeight}
  end

  --Build dialog
  dlg:label{text="Current size: " .. currentWidth .. "x" .. currentHeight}

  dlg:combobox{
    id="aspectRatio",
    label="Aspect Ratio",
    options={"1:1", "4:3", "3:4", "16:9", "9:16", "5:4", "4:5", "3:2", "2:3", "8:5", "5:8", "6:13", "13:6"},
    onchange=updatePreview --Update preview when the aspect ratio changes
  }

  dlg:combobox{
    id="keepSide",
    label="Keep Side Size",
    options={"Width", "Height"},
    onchange=updatePreview --Update preview when the side to keep changes
  }

  dlg:label{
    id="preview",
    text=previewText
  }

  dlg:button{
    text="Resize",
    onclick=function()
      local ratioKey = dlg.data.aspectRatio
      local keepSide = dlg.data.keepSide

      if not ratioKey or not keepSide then
        app.alert("Please select both an aspect ratio and a side to keep.")
        return
      end

      local ratio = aspectRatios[ratioKey]
      local newWidth, newHeight = calculateNewSize(currentWidth, currentHeight, ratio, keepSide)

      --Resize Canvas
      app.transaction(function()
        sprite:resize(newWidth, newHeight)
      end)

      app.alert("Canvas resized to: " .. newWidth .. "x" .. newHeight)
    end
  }

  dlg:button{text="Cancel"}

  --Show dialog
  dlg:show{wait=false}
end

resizeCanvas()

