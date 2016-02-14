door_status_pin = 4 -- GPIO2
status = nil

ConnStatus = nil
function ConnStatus(n)

status = wifi.sta.status()
uart.write(0,' '..status)
local x = n+1
if (x < 50) and ( status < 5 ) then
   tmr.alarm(0,100,0,function() ConnStatus(x) end)
else
   if status == 5 then
   print('\nConnected as '..wifi.sta.getip())
   
   
   
   
   
   
   else
   print("\nConnection failed")
   end
end
end


function debounce (func)
    local last = 0
    local delay = 2000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

onChange = nil
function onChange ()
	door_status = nil
	door_status = gpio.read(door_status_pin)
    print('The door_status_pin value has changed to '..door_status)
	if status ~= 5 then return end
--	dofile('send_door_status.lua')
	
end

gpio.mode(door_status_pin, gpio.INPUT, gpio.PULLUP)
--gpio.trig(door_status_pin, 'both', debounce(onChange))
tmr_count = 0
pin4_old = 0
tmr.alarm(1, 500, 1, function ()

	local pin4_new = gpio.read(4)
	if (pin4_old ~= pin4_new) then
		print("Pin 4 changed from "..pin4_old.." to "..pin4_new)
		tmr_count = tmr_count + 1
--		if (tmr_count > 10) then tmr.stop(1) end
		if status == 5 then
			door_status = pin4_new
			dofile('send_door_status.lua')
		end
	end
	pin4_old = pin4_new
end)


-- MAIN FUNCTION --
wifi.setmode(wifi.STATION)
wifi.sta.config("VL","vanyilili")
ConnStatus(0)








--led1 = 3

--gpio.mode(led1, gpio.INPUT, gpio.PULLUP)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        local _on,_off = "",""

        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)