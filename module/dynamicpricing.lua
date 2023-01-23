local config, kristapi, dw, glogger = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw, _G.kristedData.logger

local logger = glogger.getLogger("DynPrice")


local defaultPrices = {}

local itemCache = {}

-- the same as above but uses the itemcache variable. Stores the item data in the item cache and a timestamp. If it is older than 5 seconds then it updates it.
local function checkFilter(item, filters)
    --logger.log(0,"Checking item: "..textutils.serialise(item))
    local o = true
    for k,v in pairs(filters) do
        --logger.log(3, "No filter found named: "..k.." (a nil value)")
        --logger.log(0,"filter: "..k)
        local b = v.callback(item)
        --logger.log(0,"filtra: "..tostring(b))
        if v.inverted then
            b = not b
        end
        if b == false then
            o = false
        end
    end
    return o
end

local function stockLookup(rid, id, filter)
    if itemCache[rid] == nil then
        itemCache[rid] = {}
        itemCache[rid].count = 0
        itemCache[rid].time = os.time()-10
    end

    --logger.log(0,"KIBASZOTT? "..(os.time() - itemCache[rid].time))
    --logger.log(0,"RID: "..rid..", IC: "..textutils.serialise(itemCache[rid]))
    if os.time() - itemCache[rid].time > 0.05 then
        --logger.log(0,"CHECKING FOR: RID: "..rid)



        local count = 0
        local rawNames = peripheral.getNames()
        for k,v in ipairs(rawNames) do
            if string.match(v, "chest") == "chest" then
                local chest = peripheral.wrap(v)
                for kk,vv in pairs(chest.list()) do
                    if vv.name == id and checkFilter(chest.getItemDetail(kk),filter) then
                        --logger.log(0, "fos? "..filter, chest.getItemDetail(kk).displayName)
                        count = count + vv.count
                    end
                end
            end
        end
        --logger.log(0, "FOSTOS? RID: "..rid..", CO: "..count)
        itemCache[rid].count = count
        itemCache[rid].time = os.time()
    end
    return itemCache[rid].count
end

function dynamicpricing()
    if config["Enable-Dynamic-Pricing"] then
        while true do
            for k,v in ipairs(config.Items) do
                sleep(1)
                local stock = stockLookup(v.rawId,v.Id,v.filters)
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