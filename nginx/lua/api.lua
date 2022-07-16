local db = require "db"
local utils = require "utils"

function strSplit(delim,str)
    local t = {}

    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end

    return t
end


ngx.req.read_body();
local cjson = require("cjson")
local reqPath = ngx.var.uri:gsub("api/", "");
local reqMethod = ngx.var.request_method
local body = ngx.req.get_body_data() ==
        nil and {} or cjson.decode(ngx.req.get_body_data());

Api = {}
Api.__index = Api
Api.responded = false;
function Api.endpoint(method, path, callback)
    if Api.responded == false then
        local keyData = {}
        if string.find(path, "<(.-)>")
        then
            local splitPath = strSplit("/", path)
            local splitReqPath = strSplit("/", reqPath)
            for i, k in pairs(splitPath) do
                if string.find(k, "<(.-)>")
                then
                    keyData[string.match(k, "%<(%a+)%>")] = splitReqPath[i]
                    reqPath = string.gsub(reqPath, splitReqPath[i], k)
                end
            end
        end

        if reqPath ~= path
        then
            return false;
        end
        if reqMethod ~= method
        then
            return ngx.say(
                cjson.encode({
                    error=500,
                    message="Method " .. reqMethod .. " not allowed"
                })
            )
        end

        Api.responded = true;
        
        if method == "POST" then
            return callback(body);
        elseif method == "GET" then
            body = keyData
            return callback(body);
        end
    end

    return false;
end

Api.endpoint('POST', '/login',
    function(body)

        local tar, err = db.new()
        if err then ngx.log(ngx.STDERR, err) end

        if tar then
            local res, err = tar:connect()
            if err then ngx.log(ngx.STDERR, err) end

            local res, err = tar:select('mydb', 'secondary', body.username)

            if res ~= nil and res[1] ~= nil and res[1][3] == body.password then
                return ngx.say(cjson.encode(true));
            end
    
            tar:disconnect()
        end

        return ngx.say(cjson.encode(false));
    end
)

Api.endpoint('GET', '/users',
    function(body)

        local tar, err = db.new()
        if err then ngx.log(ngx.STDERR, err) end

        if tar then
            local res, err = tar:connect()
        
            if err then ngx.log(ngx.STDERR, err) end

            local res, err = tar:select('mydb', 'primary')

            tar:disconnect()

            return ngx.say(cjson.encode(res));
        end

        return ngx.say(cjson.encode(body));
    end
)