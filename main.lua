local text = [[
     _  __     _     _           _
    | |/ /    (_)   | |         | |
    | ' / _ __ _ ___| |_ ___  __| |
    |  < | '__| / __| __/ _ \/ _` |
    | . \| |  | \__ \ ||  __/ (_| |
    |_|\_\_|  |_|___/\__\___|\__,_|

]]
print(text)
print("By. VectorTech team (Bagi_Adam, BomberPlayz_)")

if _G.KristedSocket ~= nil then
    _G.KristedSocket.close()
end



local kristapi = require("kristapi")
--local json = require("json")
local dw = require("discordWebhook")
local config = require("config")
local url = "https://krist.dev"

function includes(table, string)
    for k,v in pairs(table) do
        if v == string then
            return true
        end
    end
    return false
end

function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end



function redstoneos()
    local reds = false
    while true do
        if reds then
            reds = false
        else
            reds = true
        end
        redstone.setOutput(config["Redstone_Output"], reds)
        os.sleep(1)
    end
end

local function escapeString(str)
    return str:gsub("([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1")
end

function getLogger(name)
    local ret = {
        logFile = nil,
        parent = nil,
        name = name,
        logLevel = 0,
    }

    function ret.setFile(logFileName)
        ret.logFile = fs.open(logFileName, "w")
    end
    function ret.autoFile(level)
        -- "log_"..name.."_"..os.date("%Y-%m-%d_%H-%M-%S")..".log"
        local logFileName = "/logs/"..name.."_latest.log"
        -- check if file exists
        if fs.exists(logFileName) then
            -- if it does, rename it
            fs.move(logFileName, "/logs/"..name.."_"..os.date("%Y-%m-%d_%H-%M-%S")..".log")
        end
        ret.logFile = fs.open(logFileName, "w")
    end
    function ret.writeToFile(data)
        if ret.logFile ~= nil then
            ret.logFile.writeLine(data)
            ret.logFile.flush()
        end
    end
    function ret.setParent(parent)
        ret.parent = parent
    end
    function ret.writeIntoRootFile(data)
        if ret.parent ~= nil then
            ret.parent.writeIntoRootFile(data)
        else
            ret.writeToFile(data)
        end
    end
    function ret.getFullLogPrefix()
        if ret.parent ~= nil then
            return ret.parent.getFullLogPrefix().."/"..ret.name
        else
            return ret.name
        end
    end

    function ret.log(level, data)

        if level == nil then
            level = 1
        end

        term.write("["..os.date("%H:%M:%S").."] ")

        if level == 0 then
            term.setTextColor(colors.cyan)
            term.write("[DEBUG] ")
        elseif level == 1 then
            term.setTextColor(colors.green)
            term.write("[INFO] ")
        elseif level == 2 then
            term.setTextColor(colors.yellow)
            term.write("[WARN] ")
        elseif level == 3 then
            term.setTextColor(colors.red)
            term.write("[ERROR] ")
        end

        term.setTextColor(colors.green)
        term.write("["..ret.getFullLogPrefix().."] > ")
        term.setTextColor(colors.white)
        print(data)

        if level >= ret.logLevel then
            ret.writeIntoRootFile("["..os.date("%H:%M:%S").."] ["..ret.getFullLogPrefix().."] > "..data)
        end

    end

    function ret.getLogger(name)
        local newLogger = getLogger(name)
        newLogger.setParent(ret)
        return newLogger
    end

    return ret

end

local logger = getLogger("main")
logger.autoFile(0)
logger.log(0, "test")

_G.kristedData = {
    dw = dw,
    config = config,
    kristapi = kristapi,
    logger = logger,
}

function showError(err)
    logger.log(3, "Critical error: "..err)
    local monitor = peripheral.find("monitor")
    monitor.setBackgroundColor(0x100)
    monitor.setTextColor(0x4000)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.write("The shop had an error")
    monitor.setCursorPos(1,2)
    monitor.write(err)
end

local frontend, backend, dynaprice = require("module.frontend"), require("module.backend"), require("module.dynamicpricing")
--parallel.waitForAny(backend, frontend, redstoneos, updater)
parallel.waitForAny(function()
    local stat, err = pcall(backend)
    if not stat then
        showError(err)
    end
end,
function()
    local stat, err = pcall(frontend)
    if not stat then
        showError(err)
    end
end,
function()
    local stat, err = pcall(redstoneos)
    if not stat then
        showError(err)
    end
end,
function()
    local stat, err = pcall(dynaprice)
    if not stat then
        showError(err)
    end
end)