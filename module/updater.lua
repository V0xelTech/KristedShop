local config, kristapi, dw = _G.kristedData.config, _G.kristedData.kristapi, _G.kristedData.dw

function updater()
    if config["Enable-Automatic-Update"] then
        while true do
            local nver = http.get("https://raw.githubusercontent.com/afonya2/KristedShop/main/version.txt").readAll()
            if config.Version ~= nver then
                local monitor = peripheral.find("monitor")
                local w,h = monitor.getSize()
                for i=10,1,-1 do
                    monitor.setTextColor(0x4000)
                    monitor.setCursorPos(w-#("Automatic update"),1)
                    monitor.clearLine()
                    monitor.write("Automatic update")
                    monitor.setCursorPos(w-#("in "..i.." seconds"),2)
                    monitor.clearLine()
                    monitor.write("in "..i.." seconds")
                    os.sleep(1)
                end
                monitor.setTextColor(0x4000)
                monitor.setCursorPos(w-#("Automatic update"),1)
                monitor.clearLine()
                monitor.write("Automatic update")
                monitor.setCursorPos(w-#("now"),2)
                monitor.clearLine()
                monitor.write("now")

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