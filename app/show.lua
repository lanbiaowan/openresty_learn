--local template = require("resty.template")  

local template = require "resty.template"


--template.render(ngx.var.command ..".html",{ message = ngx.var.params})
--local tpl = ngx.var.command .. ".html"

--test1
--test


template.render(ngx.var.command ..".html",{param = ngx.var.arg_param,param2 = ngx.var.arg_param2})
--ngx.say(ngx.var.command .. ".html")
