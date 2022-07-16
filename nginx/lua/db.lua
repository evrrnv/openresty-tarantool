local tnt = require "resty.tarantool"

local db = {}

function db.new()
    if tnt then
        local tar, err = tnt:new({
            host = '172.18.0.2',
            port = 3301,
            user = 'admin',
            password = 'password',
            socket_timeout = 2000,
            call_semantics = 'new'
        })
        return tar, err
    end
end

return db