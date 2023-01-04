local text = [[
     _  __     _     _           _
    | |/ /    (_)   | |         | |
    | ' / _ __ _ ___| |_ ___  __| |
    |  < | '__| / __| __/ _ \/ _` |
    | . \| |  | \__ \ ||  __/ (_| |
    |_|\_\_|  |_|___/\__\___|\__,_|

]]
print(text)
print("By. Bagi_Adam")

if _G.KristedSocket ~= nil then
    _G.KristedSocket.close()
end

local kristapi = require("kristapi")
local json = require("json")
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

function stockLookup(id)
    local chest = peripheral.wrap(config["Chest-Id"])
    local count = 0
    for k,v in pairs(chest.list()) do
        if v.name == id then
            count = count + v.count
        end
    end
    return count
end

function preDropItem(id, count)
    local stacks = {}
    local ca = count/64
    local marad = count
    for i=1,math.floor(ca),1 do
        table.insert(stacks, 64)
        marad = marad - 64
    end
    if ca ~= math.floor(ca) then
        table.insert(stacks, marad)
    end
    for k,v in ipairs(stacks) do
        while v > 0 do
            v = v - dropItem(id, v)
        end
    end
end

function dropItem(id, limit)
    local chest = peripheral.wrap(config["Chest-Id"])
    for k,v in pairs(chest.list()) do
        if v.name == id then
            local co = chest.pushItems(config["Self-Id"],k,limit,1)
            turtle.drop(limit)
            return co
        end
    end
end

function backend()
    local socket = kristapi.websocket()
    _G.KristedSocket = socket
    socket.send('{"type":"subscribe","event":"transactions","id":1}')
    while true do
        local dta = socket.receive()
        dta = json.decode(dta)
        if dta.type == "event" and dta.event == "transaction" then
            local trans = dta.transaction
            if trans.to == config["Wallet-id"] then
                if trans.metadata ~= nil then
                    local meta = kristapi.parseMeta(trans.metadata)
                    if meta["return"] ~= nil then
                        print(trans.from, trans.to, trans.value, meta["return"])
                        if meta.itemname ~= nil and meta.itemname ~= "" then
                            local tc = false
                            local vav = nil
                            for k,v in ipairs(config.Items) do
                                if v.Name == meta.itemname then
                                    tc = true
                                    vav = v
                                end
                            end
                            if tc then
                                if stockLookup(vav.Id) > 0 then
                                    local count = math.floor(trans.value / vav.Price)
                                    local exchange = math.floor(trans.value - (stockLookup(vav.Id)*vav.Price))
                                    preDropItem(vav.Id, count)
                                    if exchange >= 0 then
                                        if exchange ~= 0 then
                                            kristapi.makeTransaction(config["Wallet-Key"], trans.from, exchange, meta["return"]..";message=Here is your change")
                                        end
                                    end
                                    local change = ((trans.value / vav.Price)-count)*vav.Price
                                    if change >= 1 then
                                        kristapi.makeTransaction(config["Wallet-Key"], trans.from, change, meta["return"]..";message=Here is your change")
                                    end
                                    if config["Discord-Webhook"] then
                                        dw.sendEmbed(config["Discord-Webhook-URL"], "Kristed", "Someone bought something", 0x0099ff, 
                                        {{["name"]="From address",["value"]=trans.from},{["name"]="Value",["value"]=trans.value},{["name"]="Return address",["value"]=meta["return"]},{["name"]="Itemname",["value"]=meta.itemname},{["name"]="Meta",["value"]="`"..trans.metadata.."`"},{["name"]="Items dropped",["value"]=count},{["name"]="Exchange",["value"]=exchange},{["name"]="Change",["value"]=change}})
                                    end
                                else
                                    kristapi.makeTransaction(config["Wallet-Key"], trans.from, trans.value, meta["return"]..";message=We are out of stock from: "..meta.itemname)
                                end
                            else
                                kristapi.makeTransaction(config["Wallet-Key"], trans.from, trans.value, meta["return"]..";message=We can't give you: "..meta.itemname)
                            end
                        else
                            kristapi.makeTransaction(config["Wallet-Key"], trans.from, trans.value, meta["return"]..";message=Please specify an itemname")
                        end
                    else
                        kristapi.makeTransaction(config["Wallet-Key"], trans.from, trans.value, "message=Please send the krist from switchcraft, or specify return name")
                    end
                else
                    kristapi.makeTransaction(config["Wallet-Key"], trans.from, trans.value, "message=Got no meta!")
                end
            end
        end
        os.sleep(0)
    end
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

function frontend()
    local monitor = peripheral.find("monitor")
    y = 1
    function mprint(msg)
        monitor.setCursorPos(1,y)
        monitor.write(msg)
        y = y + 1
    end
    function rerender()
        y = 1
        monitor.setBackgroundColor(config.Theme["Background-Color"])
        monitor.clear()
        monitor.setTextColour(config.Theme["Text-Color"])
        monitor.setTextScale(0.5)
        mprint(config["Shop-Name"].."\n")
        mprint(config["Description"])
        mprint("Shop owned by: "..config["Owner"].."\n")
        mprint("Running: Kristed\n")
        mprint("By: Bagi_Adam")

        --local kukucska = {}
        function addItem(stock, name, price)
            mprint(stock.."  "..name)
            local w,h = monitor.getSize()
            monitor.setCursorPos(w-#(price.."kst"),y-1)
            monitor.write(price.."kst")
            --table.insert(kukucska, )
        end
        mprint("")
        addItem("Stock", "Name", "")
        --addItem("Test", 10, 10)
        for k,v in ipairs(config.Items) do
            addItem(stockLookup(v.Id), v.Name, v.Price)
        end

        local w,h = monitor.getSize()
        monitor.setCursorPos(1,h-1)
        monitor.write("To buy something: /pay "..config["Wallet-id"].." <price> itemname=<itemname>")
        monitor.setCursorPos(1,h)
        monitor.write("For example: /pay "..config["Wallet-id"].." 10 itemname="..config.Items[1].Name)
    end
    rerender()
    while true do
        rerender()
        os.sleep(10)
    end
end

parallel.waitForAny(backend, frontend, redstoneos)