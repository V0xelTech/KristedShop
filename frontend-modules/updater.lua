local config, kristapi, dw = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

function updater(layout)
    if config["Enable-Automatic-Update"] then
        while true do
            local nver = http.get("https://raw.githubusercontent.com/afonya2/KristedShop/main/version.txt").readAll()
            if config.Version ~= nver then
                local monitor = peripheral.find("monitor")
                local w,h = monitor.getSize()
                local decoder = dfpwm.make_decoder()

                for chunk in io.lines("jingle_3.dfpwm", 16 * 1024) do
                    local buffer = decoder(chunk)

                    while not speaker.playAudio(buffer, 1) do
                        os.pullEvent("speaker_audio_empty")
                    end
                end

                table.insert(layout, {type = "text", text = "Automatic update", align = "right", color = 0x4000}, 1)
                table.insert(layout, {type = "text", text = "in ?? seconds", align = "right", color = 0x4000}, 1)

                for i=10,1,-1 do
                    layout[2].text = "in "..i.." seconds"
                    os.sleep(1)
                end
                layout[2].text = "now!"

                local fi = fs.open("startup.lua","w")
                fi.write('local monitor = peripheral.find("monitor")\n')
                fi.write('monitor.setBackgroundColor(0x100)\n')
                fi.write('monitor.setTextColor(0x4000)\n')
                fi.write('monitor.clear()\n')
                fi.write('monitor.setCursorPos(1,1)\n')
                fi.write('monitor.write("The shop is currently updating...")\n')

                fi.write('shell.run("rm installer.lua")\n')
                fi.write('shell.run("wget https://raw.githubusercontent.com/afonya2/KristedShop/main/installer.lua")\n')
                fi.write('shell.run("installer autostart")')
                fi.close()
                shell.run("reboot")
            end
            os.sleep(60)
        end
    end
end

return updater