local xsblib = require('xsblua')
local XSB_HOME = "~/opt/xsb-3.8.0"

local XSB = {}
XSB.__index = XSB


local function realpath(p)
    return io.popen("realpath " .. p):read("*l")
end

function XSB:unify(term1, term2)
    assert(self.isInitialized, "e: xsb engine not initialized")
    local q = string.format("unify_with_occurs_check(%s, %s).", term1, term2)
    local r = xsblib.query(q)
    return r
end

function XSB:consult(fn)
    assert(self.isInitialized, "e: xsb engine not initialized")
    local cmd = string.format("consult('%s').", fn)
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:assert(term)
    assert(self.isInitialized, "e: xsb engine not initialized")
    if term:sub(-1) == '.' then
        term = term:sub(1, -2)
    end
    if term:find(":-") then
        term = "(" .. term .. ")"
    end
    local cmd = "assert(" .. term .. ")."
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:command(cmd)
    assert(self.isInitialized, "e: xsb engine not initialized")
    if cmd:sub(-1) ~= '.' then cmd = cmd .. '.' end
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:query(query)
    assert(self.isInitialized, "e: xsb engine not initialized")
    if query:sub(-1) ~= '.' then query = query .. '.' end
    return xsblib.query(query)
end

function XSB:close()
    assert(self.isInitialized, "e: xsb engine not initialized")
    xsblib.close()
    self.isInitialized = false
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
