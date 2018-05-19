-- vim: syntax=lua
-- luacheck: globals loadRemote getRemote fs loadstring peripheral

local successTools = {}

local function xenon()
  if not turtle then
    error("Xenon must run on a turtle")
  end

  -- Load local config
  local configHandle = fs.open(".config", "r")
  if not configHandle then
    error("No config file found at '.config', please create one")
  end

  local config
  local configFunc, err = loadstring("return " .. configHandle.readAll())
  if not configFunc then
    error("Invalid config: " .. err)
  else
    config = configFunc()
  end

  configHandle.close()

  --#include "src/sections/requires.lua"

  --#include "src/sections/renderer.lua"

  local repaintMonitor -- Forward declaration

  --#include "src/sections/peripherals.lua"
  --#include "src/sections/inventory.lua"
  --#include "src/sections/payments.lua"

  --#include "src/sections/display.lua"

  -- Initialize Item List
  countItems()

  --#include "src/sections/krist.lua"

  drawStartup()
  --#include "src/sections/jua.lua"
end

local success, error = pcall(xenon)

if not success then
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.red)

  print("[ERROR] Xenon terminated with error: '" .. error .. "'")

  term.setTextColor(colors.blue)
  print("This computer will reboot in 10 seconds..")

  if successTools.monitor then
    local mon = successTools.monitor
    local monW, monH = mon.getSize()

    mon.setPaletteColor(2^0, 0xFFA502)
    mon.setPaletteColor(2^1, 0xFFFFFF)
    mon.setPaletteColor(2^2, 0xFF4757)

    mon.setBackgroundColor(2^0)
    mon.setTextColor(2^1)
    mon.clear()

    mon.setBackgroundColor(2^2)
    for i = 2, 4 do
      mon.setCursorPos(1, i)
      mon.write((" "):rep(monW))
    end

    mon.setCursorPos(2, 3)
    mon.write("Xenon ran into an error!")

    mon.setBackgroundColor(2^0)

    mon.setCursorPos(2, 6)
    mon.write("Error Details:")
    mon.setCursorPos(2, 7)
    mon.write(error)

    local str = "Xenon will reboot in 10 seconds.."
    mon.setCursorPos(math.ceil((monW - #str) / 2), monH - 1)
    mon.write(str)
  end

  if successTools.logger then
    successTools.logger.error("Xenon (" .. ((config or {}).title or "Shop") .. "): Terminated with error: '" .. error .. "'",
      ((config or {}).logger or {}).crash or false)
  end

  sleep(10)
  os.reboot()
else
  if successTools.monitor then
    local mon = successTools.monitor
    local monW, monH = mon.getSize()

    mon.setPaletteColor(2^0, 0x2F3542)
    mon.setPaletteColor(2^1, 0x747D8C)

    mon.setBackgroundColor(2^0)
    mon.setTextColor(2^1)
    mon.clear()

    local str = "Xenon was terminated..."
    mon.setCursorPos(math.ceil((monW - #str) / 2), math.ceil(monH / 2))
    mon.write(str)
  end
end