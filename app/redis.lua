local redis = require "resty.redis" 
local conf = require "config.config"
local cjson = require "cjson" 
  			 	local red = redis:new()
               	red:set_timeout(2000)
               	local ok,err = red:connect(conf.redis_ip,conf.redis_port)
               	if (not ok) or (err ~= nil) then
                    ngx.say(cjson.encode({"failed to connect:", err})) 
                    return 
               	end

               local last_num = ngx.var.arg_last_num

               
               local i = 0
               while true do
               		local momeny,err = red:get("today_revenue")
               		if err ~= nil then
               			ngx.say(cjson.encode({"redis get fail:", err})) 
                    	return  
	               	end

	               	if last_num ~= momeny then
	               		ngx.say(cjson.encode({today_revenue=momeny})) 
	                    return 
	               	end

	               	if i == 30 then
	               		ngx.say(cjson.encode({today_revenue=momeny})) 
	                    return
	               	end 

	               	i = i + 1
	               	ngx.sleep(1)
               end



