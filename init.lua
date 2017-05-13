wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","password")

function check_wifi()
 local ip = wifi.sta.getip()

 if(ip==nil) then
   print("Connecting...")
 else
  tmr.stop(0)
  print("Connected to AP!")
  print(ip)  
 end
end

tmr.alarm(0,1000,1,check_wifi)

RADIO_PIN = 4
gpio.mode(RADIO_PIN, gpio.OUTPUT)

function sendCode(code)
    print("Sending radio code " .. code) 
  rc.send(RADIO_PIN,code,24,185,1,2) --Sends the data via GPIO pin 4 to the rc switch.
end

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
                print("Got parameter " .. k .. ": " .. v)
            end
        end
        buf = buf.."<h1> ESP8266 Radio Web Server</h1>";
        local radiofreq = {
             ["Socket 1"] = {on= 6916877, off= 6916878},
            ["Socket 2"] = {on= 6916871, off= 6916870},
             ["Socket 3"] = {on= 6916875, off= 6916874},
             ["Socket 4"] = {on= 6916867, off= 6916866}
        }
        for k, v in pairs(radiofreq) do 
            buf = buf.."<p>" .. k .. "<a href=\"?f=" ..v["on"] .."\"><button>ON</button></a>&nbsp;<a href=\"?f="..v["off"].."\"><button>OFF</button></a></p>";
        end 
       
        local _on,_off = "",""
        
        if( _GET.f ~= nil)then
              sendCode(_GET.f)
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)

print ("Server started ") 
