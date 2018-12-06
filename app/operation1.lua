
local redis = require "resty.redis" 
local conf = require "config.config" 
local func = require "common.function" 
               local cjson = require "cjson" 
               local red = redis:new()
               red:set_timeout(2000)
               local ok,err = red:connect(conf.redis_ip,conf.redis_port)
               if (not ok) or (err ~= nil) then
                     ngx.say("failed to connect:", err) 
                        return 
               end

               local switch = {
                    get = function (key)
                        local res = {}
                        local data,err = red:get(key)
                        res[key] = data
                        return res,err
                    end,
                    
                    mget = function (key)
                    	keys = func.split(key ,",")
                    	local data,err = red:mget(unpack(keys))
                    	local res = {}
                    	for k,v in pairs(keys) do
    						res[v] = data[k]
                    	end
                    	return res,err	 	
                    end,
                    hgetall = function (key)
                    	data,err = red:hgetall(key)

                    	if err ~= nil then
                    		return data,err
                    	end 
                        local reskey
                        local res = {} 
                    	for k,v in pairs(data) do

                    		if k%2 ==1 then 
                    			reskey = v
                    		else
                    			res[reskey] = v
                    		end 
                    	end 
                    	return res,err
                    end,


                    hget = function (key)

	                    local res = {}
	                    local keys = func.split(key,',')
	                    local data,err =  red:hget(keys[1],keys[2])
	                    res[keys[1]]  = keys[2]
	                    return res,err
                    end,

                    hincrby = function (key)
                    	local keys = func.split(key,',')
                    	local res = {}
                    	if table.getn(keys) ~= 3 then
                    		res["status"] = "1"
                    		res["msg"] = "bad params"
                    		return 
                    	else
                    		local ret = red:hincrby(keys[1],keys[2],keys[3])

                    		if ret == false then 
                    			res["status"] = "1"
                    			res["msg"] = "failer"
                    		else
                    			res["status"] = "0"
                    			res["data"] = ret
                    			res["msg"] = "success"
                    		end

                    		
                    	end
                    	return res,nil

                    	
                    	-- body
                    end,


                    pub = function (key)
                    	local keys = func.split(key,",")
                    	local  res = {}
                    	local data,err = red:publish(keys[1],keys[2])
                    	res["ret"] = data
                    	return res,err

                    end,

                    sub = function (key)
                    	local res={}
                    	local data = red:subscribe(key)
                    	res["ret"] = data
                    	return res,nil
                    end

               }
               local command = ngx.var.command

               local f = switch[command]
               local json = {}
               	
               json,_ = f(ngx.var.arg_param)
               red:close()
                ngx.say(cjson.encode(json))


               
