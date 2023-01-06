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

_G.kristedData = {
    dw = dw,
    config = config,
    kristapi = kristapi
}

function showError(err)
    local monitor = peripheral.find("monitor")
    monitor.setBackgroundColor(0x100)
    monitor.setTextColor(0x4000)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.write("The shop had an error")
    monitor.setCursorPos(1,2)
    monitor.write(err)
end

local frontend, backend, updater = require("module.frontend"), require("module.backend"), require("module.updater")
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
    local stat, err = pcall(updater)
    if not stat then
        showError(err)
    end
end)