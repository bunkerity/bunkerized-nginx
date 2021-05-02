local M			= {}
local api_list		= {}
local api_whitelist_ip	= {%API_WHITELIST_IP%}
local iputils		= require "resty.iputils"
local whitelist		= iputils.parse_cidrs(api_whitelist_ip)

api_list["^/ping$"] = function ()
	return true
end

api_list["^/reload$"] = function ()
	return os.execute("/usr/sbin/nginx -s reload") == 0
end

function M.is_api_call (api_uri)
	if iputils.ip_in_cidrs(ngx.var.remote_addr, whitelist) and ngx.var.request_uri:sub(1, #api_uri) .. "/" == api_uri .. "/" then
		for uri, code in pairs(api_list) do
			if string.match(ngx.var.request_uri:sub(#api_uri + 1), uri) then
				return true
			end
		end
	end
	return false
end

function M.do_api_call (api_uri)
	for uri, code in pairs(api_list) do
		if string.match(ngx.var.request_uri:sub(#api_uri + 1), uri) then
			return code()
		end
	end
end

return M
