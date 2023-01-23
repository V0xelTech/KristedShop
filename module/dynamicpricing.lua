local config, kristapi, dw, glogger = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw, _G.kristedData.logger

local logger = glogger.getLogger("DynPrice")


local defaultPrices = {}

local itemCache = {}

-- the same as above but uses the itemcache variable. Stores the item data in the item cache and a timestamp. If it is older than 5 seconds then it updates it.
local function stockLookup(id)
    if itemCache[id] == nil then
        itemCache[id] = {}
        itemCache[id].count = 0
        itemCache[id].time = os.time()-10
    end
    -- print("KIBASZOTT? "..os.time() - itemCache[id].time)
    if os.time() - itemCache[id].time > 0.05 then

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
        itemCache[id].count = count
        itemCache[id].time = os.time()
    end
    return itemCache[id].count
end

function dynamicpricing()
    if config["Enable-Dynamic-Pricing"] then
        while true do
            for k,v in ipairs(config.Items) do
                sleep(1)
                local stock = stockLookup(v.Id)
                if not defaultPrices[v.Id] then
                    defaultPrices[v.Id] = v.Price
                end

                if stock > 0 then
                    --price goes higher if there is lower stock, and price lowers if there is more stock
                    local newPrice = math.floor((defaultPrices[v.Id] * (v.Normal_Stock / stock))*(10 ^ config["Decimal-Digits"]))/(10 ^ config["Decimal-Digits"])
                    if newPrice < 0 then
                        newPrice = 0
                    end
                    config.Items[k].Price = newPrice
                else
                    config.Items[k].Price = defaultPrices[v.Id]
                end

            end
        end
    else
        logger.log(2, "Dynamic pricing is disabled, not running!")
        while true do
            sleep(5)
        end
    end
end

return dynamicpricing