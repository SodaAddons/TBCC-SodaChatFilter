local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out´
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

local addonFrame = CreateFrame("FRAME")
addonFrame:RegisterEvent("CHAT_MSG_ADDON")
addonFrame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
    if prefix == "SCF" then
        print(string.format("[%s] [%s]: %s %s", channel, sender, prefix, msg))
    end
end)
C_ChatInfo.RegisterAddonMessagePrefix("SCF")

filters = {}

local playerName, realm = UnitName("player");

function frame:OnEvent(event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "SodaChatFilter" then
      if ChatFilters == nil then
        ChatFilters = {}
      else
        filters = ChatFilters
        local filterCount = setGetSize(filters)
        if filterCount > 0 then
          print("SodaChatFilter (SCF) currently uses : "..filterCount.." filters. Type /SCF print to list them.")
        else
          print("SCF currently contains 0 filters. Type \"/SCF add\" followed by the word or sentence_containing_multiple_words")
        end
      end
  end
  if event == "PLAYER_LOGOUT" then
    ChatFilters = filters
  end
end
frame:SetScript("OnEvent", frame.OnEvent);

function createSet (list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function addToSet(set, key)
    set[key] = true
end

function removeFromSet(set, key)
    set[key] = nil
end

function setContains(set, key)
    return set[key] ~= nil
end
function setGetSize(set)
    local i = 0
    for filter,v in pairs(filters) do
        i = i+1
    end
    return i
end
function PrintFilters()
    print("SCF Print:")
    for filter,v in pairs(filters) do
        print(filter)
    end
end
SLASH_SCF1 = "/SCF"
local function MyCommands(msg, editbox)
    local case, text = strsplit(" ", msg, 2)
    --msg = msg:gsub()
    if case == "add" then
        for word in text:gmatch("%S+") do
            if word:find("_") then
              word = gsub(word, "_", " ")
            end
            if not setContains(filters, word) then
                word = string.lower(word)
                addToSet(filters, word)
                print("SCF Added: "..word)
            end
        end
    elseif case == "remove" then
        for word in text:gmatch("%S+") do
            if word:find("_") then
              word = gsub(word, "_", " ")
            end
            if setContains(filters, word) then
                word = string.lower(word)
                removeFromSet(filters, word)
                print("SCF Removed: "..word)
            end
        end
    elseif case == "clear" then
        for filter,v in pairs(filters) do
            removeFromSet(filters, filter)
        end
        print("SCF Cleared")
    elseif case == "print" then
        PrintFilters()
    else
        success = C_ChatInfo.SendAddonMessage("SCF","Whisper test", "WHISPER", UnitName("player"))
    end
end
SlashCmdList["SCF"] = MyCommands

local function myChatFilter(self, event, msg, author, ...)
    local authorName, realm = strsplit("-", author, 2)
    msg = removeIcons(msg)
    if authorName == playerName then
      return false, msg, author, ... --do nothing
    end
    loweredmsg = string.lower(msg)
    for filter,_ in pairs(filters) do
        local startPos, endPos = string.find(loweredmsg, filter)
        if endPos ~= nil then --there is a match
            if endPos+1 <= #loweredmsg then --the text is not longer
                local followingChar = string.sub(loweredmsg, endPos+1, endPos+1)
                if string.match(followingChar, "[^a-zA-Z%d%s]") then --following char is whitespace or non-alphanumeric
                    return true
                end
            else
                return true
            end
        end
    end
    return false, msg, author, ... --do nothing
end


function removeIcons(msg)
  msg = msg:gsub("{%a+%d+}", "");
  msg = msg:gsub("{%a+}", "");
  return msg
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
