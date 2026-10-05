-- This script was written by Erik M (toast_tries_art) on 21.01.2025 and updated to version 1.4 on 05.10.2026
-- GitHub repo: https://github.com/verbrannter-toast/Easy-Aspect-Ratio
-- It is intended to be used in Asperite to resize the canvas to most common aspect ratios
-- V1.4

local function calculateNewSize(width, height, ratio, keepSide)
  local ratioWidth, ratioHeight = ratio[1], ratio[2]
  if keepSide == "Width" then
    return width, math.floor(width * ratioHeight / ratioWidth)
  else
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

  local ratioOrder = {"1:1", "4:3", "3:4", "16:9", "9:16", "5:4", "4:5",
                      "3:2", "2:3", "8:5", "5:8", "6:13", "13:6"}
  local aspectRatios = {
    ["1:1"] = {1, 1},  ["4:3"] = {4, 3},   ["3:4"] = {3, 4},
    ["16:9"] = {16, 9}, ["9:16"] = {9, 16}, ["5:4"] = {5, 4},
    ["4:5"] = {4, 5},  ["3:2"] = {3, 2},   ["2:3"] = {2, 3},
    ["8:5"] = {8, 5},  ["5:8"] = {5, 8},   ["6:13"] = {6, 13},
    ["13:6"] = {13, 6},
  }

  -- Snapshot of the current frame, rendered once for the preview
  local snapshot = Image(sprite.spec)
  snapshot:drawSprite(sprite, app.activeFrame or 1)

  local PREVIEW_W, PREVIEW_H, PADDING = 240, 240, 12
  local CELL = 26 -- size of one anchor grid cell in pixels

  -- Anchor: 0 = left/top, 1 = center, 2 = right/bottom
  local anchor = {x = 1, y = 1}

  local dlg = Dialog("Resize Canvas by Aspect Ratio")

  local function getNewSize()
    local ratio = aspectRatios[dlg.data.aspectRatio]
    return calculateNewSize(currentWidth, currentHeight, ratio, dlg.data.keepSide)
  end

  -- Position of the old sprite relative to the top-left of the new canvas
  -- (positive when expanding, negative when cropping)
  local function getOffset(newWidth, newHeight)
    local ox = (newWidth - currentWidth) * anchor.x / 2
    local oy = (newHeight - currentHeight) * anchor.y / 2
    return math.floor(ox), math.floor(oy)
  end

  local function updatePreview()
    local newWidth, newHeight = getNewSize()
    dlg:modify{id="sizeText", text=newWidth .. "x" .. newHeight}
    dlg:repaint()
  end

  local function onPaintPreview(ev)
    local gc = ev.context
    local newWidth, newHeight = getNewSize()
    local ox, oy = getOffset(newWidth, newHeight)

    -- Bounding box of both canvases in sprite coordinates
    local minX = math.min(0, ox)
    local minY = math.min(0, oy)
    local maxX = math.max(newWidth, ox + currentWidth)
    local maxY = math.max(newHeight, oy + currentHeight)
    local unionW, unionH = maxX - minX, maxY - minY

    local scale = math.min((gc.width - PADDING * 2) / unionW,
                           (gc.height - PADDING * 2) / unionH)

    -- Pixel position of sprite-coordinate (0, 0), so the bounding box is centered
    local originX = (gc.width - unionW * scale) / 2 - minX * scale
    local originY = (gc.height - unionH * scale) / 2 - minY * scale

    local function rect(x, y, w, h)
      return Rectangle(
        math.floor(originX + x * scale),
        math.floor(originY + y * scale),
        math.floor(w * scale),
        math.floor(h * scale))
    end

    local newRect = rect(0, 0, newWidth, newHeight)
    local oldRect = rect(ox, oy, currentWidth, currentHeight)

    -- New canvas background (shows added empty area)
    gc.color = Color{r=60, g=60, b=60}
    gc:fillRect(newRect)

    -- Current sprite content
    gc.antialias = false
    gc:drawImage(snapshot, Rectangle(0, 0, currentWidth, currentHeight), oldRect)

    -- Outline of the new canvas
    gc.color = Color{r=255, g=80, b=80}
    gc.strokeWidth = 2
    gc:strokeRect(newRect)

    -- Outline of the old canvas
    gc.color = Color{r=255, g=255, b=255, a=120}
    gc.strokeWidth = 1
    gc:strokeRect(oldRect)
  end

  local function onPaintAnchor(ev)
    local gc = ev.context
    for row = 0, 2 do
      for col = 0, 2 do
        local r = Rectangle(col * CELL + 2, row * CELL + 2, CELL - 4, CELL - 4)
        if col == anchor.x and row == anchor.y then
          gc.color = Color{r=255, g=80, b=80}
          gc:fillRect(r)
        else
          gc.color = Color{r=120, g=120, b=120}
          gc.strokeWidth = 1
          gc:strokeRect(r)
        end
      end
    end
  end

  local function onAnchorClick(ev)
    local col = math.max(0, math.min(2, ev.x // CELL))
    local row = math.max(0, math.min(2, ev.y // CELL))
    anchor.x, anchor.y = col, row
    dlg:repaint()
  end

  dlg:label{label="Current size", text=currentWidth .. "x" .. currentHeight}

  dlg:combobox{
    id="aspectRatio",
    label="Aspect Ratio",
    options=ratioOrder,
    onchange=updatePreview
  }

  dlg:combobox{
    id="keepSide",
    label="Keep Side Size",
    options={"Width", "Height"},
    onchange=updatePreview
  }

  dlg:label{id="sizeText", label="New size", text="..."}

  dlg:canvas{
    id="anchorGrid",
    label="Anchor",
    width=CELL * 3,
    height=CELL * 3,
    onpaint=onPaintAnchor,
    onmousedown=onAnchorClick
  }

  dlg:canvas{
    id="preview",
    label="Preview",
    width=PREVIEW_W,
    height=PREVIEW_H,
    onpaint=onPaintPreview
  }

  dlg:button{
    text="Resize",
    onclick=function()
      local newWidth, newHeight = getNewSize()

      local x = (currentWidth - newWidth) * anchor.x // 2
      local y = (currentHeight - newHeight) * anchor.y // 2

      app.transaction(function()
        sprite:crop(x, y, newWidth, newHeight)
      end)

      dlg:close()
      app.alert("Canvas resized to: " .. newWidth .. "x" .. newHeight)
    end
  }

  dlg:button{text="Cancel"}

  dlg:show{wait=false}
  updatePreview()
end

resizeCanvas()