local dw = {}
--local json = require("json")

dw.sendMessage = function(link, content)
    http.post(link, '{"content":"'..content..'"}', {["Content-Type"]="application/json"})
end

dw.sendEmbed = function(link, title, desc, color, fields)
    local fi = ""
    for k,v in ipairs(fields) do
        fi = fi..'{"name": "'..v.name..'","value": "'..v.value..'"},'
    end
    fi = string.sub(fi, 1, #fi-1)
    --print('{"embeds": [{"title":"'..title..'","description":"'..desc..'","color":"'..color..'","fields":['..fi..']}]}')
    --print(json.decode('{"embeds": [{"title":"'..title..'","description":"'..desc..'","color":"'..color..'","fields":['..fi..']}]}'))
    http.post(link, '{"embeds": [{"title":"'..title..'","description":"'..desc..'","color":"'..color..'","fields":['..fi..']}]}', {["Content-Type"]="application/json"})
end

return dw