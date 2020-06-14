local xsblib = require('xsblua')
local XSB_HOME = "~/opt/xsb-3.8.0"

local XSB = {}
XSB.__index = XSB


local function realpath(p)
    return io.popen("realpath " .. p):read("*l")
end

function XSB:assert(term)
    if term:find(":-") then
        term = "(" .. term .. ")"
    end
    local cmd = "assert(" .. term .. ")."
    return self:command(cmd)
end

function XSB:command(cmd)
    assert(self.isInitialized, "e: xsb engine not initialized")
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:query(query)
    assert(self.isInitialized, "e: xsb engine not initialized")
    return xsblib.query(query)
end

function XSB:close()
    assert(self.isInitialized, "e: xsb engine not initialized")
    local rc = xsblib.close()
    -- it seems it's useless to check the rc
    self.isInitialized = false
    return rc
end

function XSB:init(xsbPath)
    assert(not self.isInitialized, "e: xsb engine already initialized")
    self.isInitialized = false
    local xsbPath = xsbPath or XSB_HOME
    if xsbPath then
        local rc = xsblib.init(realpath(xsbPath))
        if rc == 0 then
            self.isInitialized = true
            self:command(":- auto_table.")
        end
    end
    return self.isInitialized
end

function XSB:new(xsbPath)
    local o = {}
    setmetatable(o, XSB)
    o.isInitialized = false
    o:init(xsbPath)
    return o
end


setmetatable(XSB, {__call=XSB.new})
XSB.__call = XSB.command
return XSB
