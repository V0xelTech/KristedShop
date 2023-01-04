local args = {...}

local text = [[
     _  __     _     _           _
    | |/ /    (_)   | |         | |
    | ' / _ __ _ ___| |_ ___  __| |
    |  < | '__| / __| __/ _ \/ _` |
    | . \| |  | \__ \ ||  __/ (_| |
    |_|\_\_|  |_|___/\__\___|\__,_|

]]
print(text)
print("Installer")
print("By. Bagi_Adam")

print("Installing version: "..http.get("https://raw.githubusercontent.com/afonya2/KristedShop/main/version.txt").readAll())

print("Checking for old versions...")
if fs.exists("config.lua") then
    print("Older versions found: "..require("config").Version)
end

print("Downloading apis...")
shell.run("rm kristapi.lua")
shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/kristapi.lua kristapi.lua")
shell.run("rm json.lua")
shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/json.lua json.lua")
shell.run("rm discordWebhook.lua")
shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/discordWebhook.lua discordWebhook.lua")

print("Downloading main system...")
shell.run("rm main.lua")
shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/main.lua main.lua")

print("Downloading config...")
if fs.exists("config.lua") then
    shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/config.lua configpre.lua")
    print("Updating config...")
    local oc = require("config")
    local nc = require("configpre")
    for k,v in ipairs(nc) do
        if oc[k] == nil then
            oc[k] = v
        end
    end
    oc.Version = nc.Version
    local ncc = fs.open("config.lua", "w")
    ncc.write("return "..textutils.serialise(nc))
    ncc.close()
else
    shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/config.lua config.lua")
end
print("Generating startup...")
local fi = fs.open("startup.lua","w")
fi.write('shell.run("main.lua")')
fi.close()

print("Kristed installed on your system!")
if args[1] == "autostart" then
    shell.run("main")
end