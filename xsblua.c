#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "cinterf.h"


#if LUA_VERSION_NUM >= 502
#define new_lib(L, l) (luaL_newlib(L, l))
#else
#define new_lib(L, l) (lua_newtable(L), luaL_register(L, NULL, l))
#endif

#define VERSION         "0.1.0"
#define XSB_INIT_ARGS   " --quietload --nofeedback --nobanner --noprompt"

static int
initXSB(lua_State* L)
{
    const char* p = luaL_checkstring(L, 1);
    char init_string[1024];

    strcpy(init_string, p);
    strcat(init_string, XSB_INIT_ARGS);
    if(xsb_init_string((char*)init_string) == XSB_ERROR) {
        fprintf(stderr, "%s: %s\n", xsb_get_init_error_type(),
                xsb_get_init_error_message());
        lua_pushinteger(L, 1);
    } else {
        lua_pushinteger(L, 0);
    }

    return 1;
}

static int
queryXSB(lua_State* L)
{
    const char* q = luaL_checkstring(L, 1);
    int max_answers = luaL_checkinteger(L, 2);
    int rc;
    XSB_StrDefine(return_string);

    rc = xsb_query_string_string((char*) q, &return_string, "|");
    int n = 0;
    lua_newtable(L);
    while (rc == XSB_SUCCESS && n < max_answers) {
        lua_pushinteger(L, ++n);
        lua_pushstring(L, return_string.string);
        lua_settable(L, -3);
        rc = xsb_next_string(&return_string,"|");
    }
    if(rc == XSB_ERROR) {
        fprintf(stderr, "%s: %s\n", xsb_get_error_type(), xsb_get_error_message());
    }
    xsb_close_query();
    /* lua_pushinteger(L, rc); */

    return 1;
}

static int
commandXSB(lua_State* L)
{
    const char* cmd = luaL_checkstring(L, 1);
    int rc;

    rc = xsb_command_string((char*) cmd);
    if(rc == XSB_ERROR) {
        fprintf(stderr, "%s: %s\n",xsb_get_error_type(), xsb_get_error_message());
    }
    lua_pushinteger(L, rc);

    return 1;
}

static int
closeXSB(lua_State* L)
{
    xsb_close();
    return 0;
}

static int
getVersion(lua_State* L)
{
    lua_pushstring(L, VERSION);

    return 1;
}

static const struct luaL_Reg xsblua [] = {
    {"init", initXSB},
    {"query", queryXSB},
    {"command", commandXSB},
    {"close", closeXSB},
    {"version", getVersion},
    {NULL, NULL}
};


int
luaopen_xsblua(lua_State* L)
{
/*     luaL_newlib(L, xsblua); */
    new_lib(L, xsblua);

    return 1;
}

