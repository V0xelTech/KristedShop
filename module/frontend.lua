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

function frontendold()
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

function frontend()
    local layout = require("../layout")

    local monitor = peripheral.find("monitor")
    local w,h = monitor.getSize()
    local y = 1
    function mprint(msg,xstart,xend,align)
        if xstart == nil then
            xstart = 1
        end
        if xend == nil then
            xend = w
        end
        if align == nil then
            align = "left"
        end
        monitor.setCursorPos(xstart,y)
        if align == "left" then
            monitor.write(msg)
        elseif align == "center" then
            --print(xstart, xend, msg)
            --print(math.floor((xend-xstart)/2-#msg/2))
            monitor.setCursorPos(math.floor((xend-xstart)/2-#msg/2)+xstart,y)
            monitor.write(msg)
            --print("msize: "..w.."x"..h)
        elseif align == "right" then
            monitor.setCursorPos(xend-#msg,y)
            monitor.write(msg)
        end
    end


    local function esc(x)
        return (x:gsub('%%', '%%%%')
                 :gsub('^%^', '%%^')
                 :gsub('%$$', '%%$')
                 :gsub('%(', '%%(')
                 :gsub('%)', '%%)')
                 :gsub('%.', '%%.')
                 :gsub('%[', '%%[')
                 :gsub('%]', '%%]')
                 :gsub('%*', '%%*')
                 :gsub('%+', '%%+')
                 :gsub('%-', '%%-')
                 :gsub('%?', '%%?'))
    end

    function render()
        y = 1

        -- pass 1, render the background and set the text' xstart and xend based on the 'width' property in the elements of layout. If the overall width is bigger than the monitor's width, it will be resized to fit the monitor's width.
        -- if it is smaller, it is stretched to fit the monitor's width.

        local overallWidth = 0

        for k,v in ipairs(layout) do
            if v.width == nil then
                if v.text then
                    v.width = w
                else
                    v.width = w
                end
            end
            overallWidth = overallWidth + v.width

            if v.text then
                -- check if the text contains things like {Shop-Name} {Shop-Description} etc.
                -- the text may have a "-" symbol too. Make it so that it won't confuse the pattern
                local text = v.text
                for kk,vv in pairs(config) do
                    print("{"..kk.."}")
                    text = string.gsub(text, "{"..esc(kk).."}", vv)
                end
                print(text)
                v.text = text
            end
        end

        local multiplier = 1
        --print(multiplier)

        local xer = 1

        for k,v in ipairs(layout) do
            if v.width == nil then
                v.width = w
            end
            v.width = v.width * multiplier

            if v.align == nil then
                v.align = "left"
            end

            if v.xstart == nil then
                v.xstart = 1
                xer = xer + v.width


            end
            if v.xend == nil then
                v.xend = v.xstart + v.width
            end

        end

        local bg, tc = 0,0

        for k,v in ipairs(layout) do
            if v.type == "background" then
                bg = tonumber(v.bg)
                tc = tonumber(v.text)
            end
        end

        monitor.setBackgroundColor(bg)
        monitor.clear()

        for k,v in ipairs(layout) do
            if v.background ~= nil then
                monitor.setBackgroundColor(v.background)
            else
                monitor.setBackgroundColor(bg)
            end
            if v.textcolor ~= nil then
                monitor.setTextColour(tonumber(v.color))
            else
                monitor.setTextColour(tc)
            end
            if v.type == "Header" then
                mprint(v.text,v.xstart,v.xend,v.align)
                y = y + 1
                -- draw a horizontal line below the header
                monitor.setCursorPos(v.xstart,y)
                monitor.write(string.rep(" ",v.xend-v.xstart+1))
                y = y + 2
            end
            if v.type == "Text" then
                mprint(v.text,v.xstart,v.xend,v.align)
                y = y + 1
            end
            if v.type == "SellTable" then
                local colors = v.colors
                local cIndex = 1

                local overallWidther = 0
                for i,j in ipairs(v.columns) do
                    -- set xstart and xend. Do almost the same as in the first pass.
                    if j.width == nil then
                        j.width = w/4
                    end
                    overallWidther = overallWidther + j.width
                end
                local multiplierer = (v.xend-v.xstart)/overallWidther
                local xor = v.xstart
                -- write the column names centered
                for i,j in ipairs(v.columns) do
                    if j.width == nil then
                        j.width = w/4
                    end
                    j.width = j.width * multiplierer
                    if j.xstart == nil then
                        j.xstart = xor
                        xor = xor + j.width
                    end
                    if j.xend == nil then
                        j.xend = j.xstart + j.width
                    end
                end

                cIndex = cIndex + 1
                if cIndex > #colors.background then
                    cIndex = 1
                end
                for i,j in ipairs(v.columns) do
                    monitor.setCursorPos(j.xstart,y)
                    monitor.setBackgroundColor(colors.background[cIndex])
                    monitor.write(string.rep(" ",j.xend-j.xstart+1))
                    monitor.setCursorPos(j.xstart,y)
                    monitor.setTextColour(colors.text[cIndex])
                    mprint(j.name,j.xstart,j.xend,j.align)

                end

                y = y + 1

                for kk,vv in ipairs(config.Items) do
                    for i,j in ipairs(v.columns) do
                        j.text = string.gsub(j.text, "{name}", vv.Name)
                        j.text = string.gsub(j.text, "{price}", vv.Price)
                        j.text = string.gsub(j.text, "{stock}", stockLookup(vv.Id))
                    end

                    --print(v.xend-v.xstart)
                    cIndex = cIndex + 1
                    if cIndex > #colors.background then
                        cIndex = 1
                    end
                    for i,j in ipairs(v.columns) do

                        monitor.setCursorPos(j.xstart,y)
                        monitor.setBackgroundColor(colors.background[cIndex])
                        monitor.write(string.rep(" ",j.xend-j.xstart+1))
                        monitor.setCursorPos(j.xstart,y)
                        monitor.setTextColour(colors.text[cIndex])
                        mprint(j.text,j.xstart,j.xend,j.align)

                    end
                    y = y + 1
                end
            end
        end
    end

    while true do
        render()
        os.sleep(5)
    end
end

return frontend