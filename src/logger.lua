--#ignore
local config = {}

local logger = {}
local slackURL = config.slackURL
local discordURL = config.discordURL
local slackName = config.slackName
local discordName = config.discordName
local externName

local function time()
  return os.day("utc") .. "-" .. os.time("utc")
end

function logger.init(prints, tExternName, noColor)
  logger.printf = prints and print or function() end
  logger.handle = fs.open("/log", "a")
  logger.color = not noColor

  externName = tExternName or os.getComputerLabel() or "Computer - " .. os.getComputerID()
end

function logger.log(text)
  if logger.color then
    term.setTextColor(colors.white)
  end
  logger.printf(text)
  logger.handle.write(text .. "\n")
  logger.handle.flush()
end

function logger.info(text, externRelay, quiet)
  if logger.color then
    term.setTextColor(colors.gray)
  end
  logger.printf("[" .. time() .. "] [INFO] " .. text)

  if not quiet then
    logger.handle.write("[" .. time() .. "] [INFO] " .. text .. "\n")
    logger.handle.flush()
  end

  if externRelay == "important" then
    logger.externMention(text)
  elseif externRelay then
    logger.externInfo(text)
  end
end

function logger.warn(text, externRelay, quiet)
  if logger.color then
    term.setTextColor(colors.yellow)
  end
  logger.printf("[" .. time() .. "] [WARN] " .. text)

  if not quiet then
    logger.handle.write("[" .. time() .. "] [WARN] " .. text .. "\n")
    logger.handle.flush()
  end

  if externRelay then
    logger.externMention(text)
  end
end

function logger.error(text, externRelay, quiet)
  if logger.color then
    term.setTextColor(colors.red)
  end
  logger.printf("[" .. time() .. "] [ERROR] " .. text)

  if not quiet then
    logger.handle.write("[" .. time() .. "] [ERROR] " .. text .. "\n")
    logger.handle.flush()
  end

  if externRelay then
    logger.externMention(text)
  end
end

function logger.externInfo(text)
  if slackURL then
    http.post(slackURL, [[payload={"username": "]] .. externName .. [[", "text":"]] .. textutils.urlEncode(text) .. [["}]])
  end

  if discordURL then
    http.post(discordURL, [[payload={"username": "]] .. externName .. [[", "content":"]] .. textutils.urlEncode(text) .. [["}]])
  end
end

function logger.externMention(text)
  if slackURL then
    if slackName then
      http.post(slackURL, [[payload={"username": "]] .. externName .. [[", "text":"<@]] .. slackName .. [[> ]] .. textutils.urlEncode(text) .. [["}]])
    else
      http.post(slackURL, [[payload={"username": "]] .. externName .. [[", "text":"]] .. textutils.urlEncode(text) .. [["}]])
    end
  end

  if discordURL then
    if discordName then
      http.post(discordURL, [[payload={"username": "]] .. externName .. [[", "content":"<@]] .. discordName .. [[> ]] .. textutils.urlEncode(text) .. [["}]])
    else
      http.post(discordURL, [[payload={"username": "]] .. externName .. [[", "content":"]] .. textutils.urlEncode(text) .. [["}]])
    end
  end
end

function logger.close()
  logger.handle.close()
end

return logger