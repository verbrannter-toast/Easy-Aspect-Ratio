-- This script was written by Erik M (toast_tries_art) on 21.01.2025
-- It is intended to be used in Asperite to resize the canvas to most common aspect ratios
-- V1.3

local function calculateNewSize(width, height, ratio, keepSide)
  local ratioWidth, ratioHeight = ratio[1], ratio[2]
  if keepSide == "Width" then
    return width, math.floor(width * ratioHeight / ratioWidth)
  elseif keepSide == "Height" then
    return math.floor(height * ratioWidth / ratioHeight), height
  end
end

local function resizeCanvas()
  local sprite = app.activeSprite
  if not sprite then
    app.alert("No active sprite found. Please open a sprite to use this script.")
    return
  end

  local currentWidth = sprite.width
  local currentHeight = sprite.height

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

  local dlg = Dialog("Resize Canvas by Aspect Ratio")
  local previewText = "Select options to see the new size."

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

  dlg:label{text="Current size: " .. currentWidth .. "x" .. currentHeight}

  dlg:combobox{
    id="aspectRatio",
    label="Aspect Ratio",
    options={"1:1", "4:3", "3:4", "16:9", "9:16", "5:4", "4:5", "3:2", "2:3", "8:5", "5:8", "6:13", "13:6"},
    onchange=updatePreview
  }

  dlg:combobox{
    id="keepSide",
    label="Keep Side Size",
    options={"Width", "Height"},
    onchange=updatePreview
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

      local offsetX = math.max(0, (newWidth - currentWidth) // 2)
      local offsetY = math.max(0, (newHeight - currentHeight) // 2)

      -- Use transaction to modify canvas without altering image
      app.transaction(function()
        sprite.width = newWidth
        sprite.height = newHeight
        sprite:crop(newWidth, newHeight, offsetX, offsetY)
      end)

      app.alert("Canvas resized to: " .. newWidth .. "x" .. newHeight)
    end
  }

  dlg:button{text="Cancel"}

  dlg:show{wait=false}
end

resizeCanvas()

