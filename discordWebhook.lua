local dw = {}
--local json = require("json")

dw.sendMessage = function(link, content)
    local da = {
        ["content"]=content
    }
    http.post(link, textutils.serialiseJSON(da), {["Content-Type"]="application/json"})
end

dw.sendEmbed = function(link, title, desc, color, fields)
    --print('{"embeds": [{"title":"'..title..'","description":"'..desc..'","color":"'..color..'","fields":['..fi..']}]}')
    --print(json.decode('{"embeds": [{"title":"'..title..'","description":"'..desc..'","color":"'..color..'","fields":['..fi..']}]}'))
    local da = {
        ["embeds"] = {
            {
                ["title"]=title,
                ["description"]=desc,
                ["color"]=color,
                ["fields"]=fields
            }
        }
    }
    http.post(link, textutils.serialiseJSON(da), {["Content-Type"]="application/json"})
end

return dw