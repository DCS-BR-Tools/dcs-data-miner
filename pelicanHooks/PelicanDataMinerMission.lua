-- %USERPROFILE%\Saved Games\DCS\Scripts\PelicanTestMission.lua


local function handle_request(luastring, env)
    if (env ~= "default") then
        local str, err = net.dostring_in(env, luastring)
        return str
    else
        local loaded = assert(loadstring(luastring))
        local result = loaded()
        return result
    end
end


package.cpath = package.cpath .. ";" .. lfs.writedir() .. "\\Mods\\tech\\Pelican\\bin\\?.dll"
PELICAN = { logger_level = "debug" }

local status, ____pelican = pcall(require, "pelican")
if not status then
    env.error("Failed to load Pelican: " .. tostring(____pelican))
    return
else
    env.info("Pelican loaded successfully")
end

local logger = ____pelican.logger

local my_logger = logger.Logger.new("PELICAN.MISSION")

my_logger:info("Pelican Running...")

local jsonrpc = ____pelican.jsonrpc

local server = jsonrpc.JsonRpcServer.new({ host = "127.0.0.1", port = 1235 })
local router = jsonrpc.JsonRpcRouter.new()

router:add_method(
    "ping",
    function(params)
        local param = params[1]
        local env = params[2]
        local success, res = pcall(handle_request, param, env)
        if (not success) then
            return {
                error = {
                    message = "Failed",
                    data = res
                }
            }
        end
        return res
    end
)

timer.scheduleFunction(
    function(arg, time)
        local result, err = server:process_rpc(router)
        if not result then
            env.error("RPC error: " .. tostring(err))
        end

        return timer.getTime() + .01
    end,
    nil,
    timer.getTime() + .01
)
