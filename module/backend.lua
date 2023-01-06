local config, kristapi, dw = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw

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
    local count = 0
    local rawNames = peripheral.getNames()
    for k,v in ipairs(rawNames) do
        if string.match(v, "chest") == "chest" then
            local chest = peripheral.wrap(v)
            for kk,vv in pairs(chest.list()) do
                if vv.name == id then
                    count = count + vv.count
                end
            end
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
            local dro = dropItem(id, v)
            v = v - dro
        end
    end
end

function dropItem(id, limit)
    local rawNames = peripheral.getNames()
    for k,v in ipairs(rawNames) do
        if string.match(v, "chest") == "chest" then
            local chest = peripheral.wrap(v)
            for kk,vv in pairs(chest.list()) do
                if vv.name == id then
                    local co = chest.pushItems(config["Self-Id"],kk,limit,1)
                    turtle.drop(limit)
                    return co
                end
            end
        end
    end
end

function backend()
    local socket = kristapi.websocket()
    _G.KristedSocket = socket
    socket.send('{"type":"subscribe","event":"transactions","id":1}')
    while true do
        local dta = socket.receive()
        --dta = json.decode(dta)
        dta = textutils.unserialiseJSON(dta)
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
                                if v.Name == meta.itemname or v.Alias == meta.itemname then
                                    tc = true
                                    vav = v
                                end
                            end
                            if tc then
                                if stockLookup(vav.Id) > 0 then
                                    local count = math.floor(trans.value / vav.Price)
                                    local exchange = math.floor(trans.value - (stockLookup(vav.Id)*vav.Price))
                                    if exchange >= 0 then
                                        preDropItem(vav.Id, stockLookup(vav.Id))
                                        if exchange ~= 0 then
                                            kristapi.makeTransaction(config["Wallet-Key"], trans.from, exchange, meta["return"]..";message=Here is your change")
                                        end
                                    else
                                        preDropItem(vav.Id, count)
                                    end
                                    local change = ((trans.value / vav.Price)-count)*vav.Price
                                    if change >= 1 then
                                        kristapi.makeTransaction(config["Wallet-Key"], trans.from, change, meta["return"]..";message=Here is your change")
                                    end
                                    if config["Discord-Webhook"] then
                                        dw.sendEmbed(config["Discord-Webhook-URL"], "Kristed", "Someone bought something", 0x0099ff,
                                                {{["name"]="From address",["value"]=trans.from},{["name"]="Value",["value"]=trans.value},{["name"]="Return address",["value"]=meta["return"]},{["name"]="Itemname",["value"]=meta.itemname},{["name"]="Meta",["value"]="`"..trans.metadata.."`"},{["name"]="Items dropped",["value"]=tostring(count)},{["name"]="Exchange",["value"]=tostring(exchange)},{["name"]="Change",["value"]=tostring(change)}})
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

return backend