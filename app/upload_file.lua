local saveRootPath = "/usr/local/openresty/upload/"
local func = require "common.function" 

local my_get_file_name = function(str)
    local filename = ngx.re.match(str,'(.+)filename="(.+)"(.*)') 
    if filename then  
        return filename[2] 
    end 
end
	
                local upload = require "resty.upload"
                local cjson = require "cjson"

                local chunk_size = 4096 -- should be set to 4096 or 8192
                                     -- for real-world settings
                local file
                local form, err = upload:new(chunk_size)
                if not form then
                    ngx.log(ngx.ERR, "failed to new upload: ", err)
                    ngx.exit(500)
                end

                form:set_timeout(1000) -- 1 sec
                local  filestr=""
                while true do

                    local typ, res, err = form:read()
                    if not typ then
                        ngx.say("failed to read: ", err)
                        return
                    end

                    if typ == "header" then
                        if res[1] == "Content-Disposition" then
                    	   local file_name = my_get_file_name(res[2])

                           if file_name then 
                                file,err = io.open(saveRootPath .. file_name,"w+")
                                if not file then 
                                    ngx.say("failed to open file ", saveRootPath..file_name,err)
                                    return
                                end  
                           
                           end 
                        end

			         elseif typ == "body" then
			            
			            if res then
                            filestr = filestr .. res
                        end

                    elseif typ == "part_end" then 
                        if file then
                            file:write(filestr)
                        end
                    elseif typ == "eof" then
                        if file then
                            file:close()
                        end

                        break
                    end
                end


                ngx.say(cjson.encode({"success"}))
                