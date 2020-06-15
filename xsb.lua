local xsblib = require('xsblua')
local XSB_HOME = "~/opt/xsb-3.8.0"

local XSB = {}
XSB.__index = XSB

local MSG = {
    NOT_INITIALIZED = "xsb engine not initialized",
    ALREADY_INITIALIZED = "xsb engine already initialized",
    REPR_INITIALIZED = "<binding version %s, xsb-%s initialized at '%s'>",
    REPR_NOT_INITIALIZED = "<binding version %s, xsb engine not initialized>",
}

local function realpath(p)
    return io.popen("realpath " .. p):read("*l")
end

local function getXSBVersion()
    local r = xsblib.query("xsb_configuration(version,X).", 1)
    return r[1]
end

function XSB:unify(term1, term2, max)
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
    local max = max or 10
    local q = string.format("unify_with_occurs_check(%s, %s).", term1, term2)
    local r = xsblib.query(q, max)
    return r
end

function XSB:consult(fn)
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
    local cmd = string.format("consult('%s').", fn)
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:assert(term)
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
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
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
    if cmd:sub(-1) ~= '.' then cmd = cmd .. '.' end
    local rc = xsblib.command(cmd)
    return rc
end

function XSB:query(query, max)
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
    local max = max or 10
    if query:sub(-1) ~= '.' then query = query .. '.' end
    return xsblib.query(query, max)
end

function XSB:close()
    assert(self.isInitialized, MSG.NOT_INITIALIZED)
    xsblib.close()
    self.isInitialized = false
end

function XSB:__tostring()
    local str
    if self.isInitialized then
        str = MSG.REPR_INITIALIZED:format(self.lib_version,
                                          self.xsb_version,
                                          self.xsb_path)
    else
        str = MSG.REPR_NOT_INITIALIZED:format(self.lib_version)
    end
    return str
end

function XSB:init(xsbPath)
    assert(not self.isInitialized, MSG.ALREADY_INITIALIZED)
    self.isInitialized = false
    local xsbPath = xsbPath or XSB_HOME
    if xsbPath then
        xsbPath = realpath(xsbPath)
        local rc = xsblib.init(xsbPath)
        if rc == 0 then
            self.isInitialized = true
            self.xsb_path = xsbPath
            self.lib_version = xsblib.version()
            self.xsb_version = getXSBVersion()
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
