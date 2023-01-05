local config, kristapi, dw = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw



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
        --mprint("Running: Kristed\n")
        mprint("Kristed By: VectorTech team (Bagi_Adam, BomberPlayz_)")

        mprint("")
        local kukucska = {}
        local w,h = monitor.getSize()
        monitor.setCursorPos(1,y)
        y = y + 1
        monitor.write("Stock Name")
        monitor.setCursorPos(w-#("price")+1,y-1)
        monitor.write("price")
        function addItem(id, name, price)
            monitor.setCursorPos(1,y)
            y = y + 1
            monitor.write(stockLookup(id).."")
            monitor.setCursorPos(#("Stock")+2,y-1)
            monitor.write(name)
            monitor.setCursorPos(w-#(price.."kst")+1,y-1)
            monitor.write(price.."kst")
            table.insert(kukucska, {line=y-1,id=id,name=name,price=price,stock=stockLookup(id)})
        end
        --mprint("")
        --addItem("Stock", "Name", "")
        --addItem("Test", 10, 10)
        for k,v in ipairs(config.Items) do
            addItem(v.Id, v.Name, v.Price)
        end

        monitor.setCursorPos(1,h-1)
        monitor.write("To buy something: /pay "..config["Wallet-id"].." <price> itemname=<itemname>")
        monitor.setCursorPos(1,h)
        monitor.write("For example: /pay "..config["Wallet-id"].." "..config.Items[1].Price.." itemname="..config.Items[1].Name)
        monitor.setCursorPos(w-#("Kristed v"..config.Version)+1,h)
        monitor.write("Kristed v"..config.Version)
        return kukucska
    end
    local kuka = rerender()
    while true do
        --rerender()
        for k,v in ipairs(kuka) do
            if stockLookup(v.id) ~= v.stock then
                local w,h = monitor.getSize()
                monitor.setCursorPos(1,v.line)
                monitor.clearLine()
                monitor.write(stockLookup(v.id).."")
                monitor.setCursorPos(#("Stock")+2,v.line)
                monitor.write(v.name)
                monitor.setCursorPos(w-#(v.price.."kst")+1,v.line)
                monitor.write(v.price.."kst")
                kuka[k].stock = stockLookup(v.id)
            end
        end
        os.sleep(10)
    end
end

return frontend