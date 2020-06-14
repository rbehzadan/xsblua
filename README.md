# xsb prolog lua binding

This is a minimal lua binding for [XSB Prolog](http://xsb.sourceforge.net/), using its `C API`.
I wrote it to test my higher order unification algorithm.

At the moment, only these API functions are used:
- `xsb_init_string`
- `xsb_command_string`
- `xsb_query_string_string`
- `xsb_close`

I compiled the code for `luajit 2.0` and `lua 5.3` successfully.

## 1. Installation

### 1.1. Install XSB prolog
To install xsb, follow the instructions on the manual.
To install `xsb 3.8` locally on a linux machine, you may do something like this:

###### **Note:** *This will install `xsb` on `~/opt/xsb-3.8.0`*


```sh
mkdir -p /tmp/xsb/src /tmp/xsb/dest ~/opt
cd /tmp/xsb/src
# download size is about 14M
curl -L http://xsb.sourceforge.net/downloads/XSB.tar.gz | tar xz
cd XSB/build
./configure -prefix=/tmp/xsb/dest
./makexsb
./makexsb install
mv /tmp/xsb/dest/xsb-3.8.0 ~/opt/
cd ~
rm -rf /tmp/xsb
```

### 1.2. Build lua binding

1.2.1. Clone the repository:

```sh
mkdir -p /tmp/xsblua
cd /tmp
git clone --depth=1 https://github.com/rbehzadan/xsblua.git
cd xsblua
```

###### **Note:** *Don't forget this step!*
1.2.2. Edit `Makefile` and set `XSB_HOME` and `LUA_HOME` according to your system.

1.2.3. Run `make`:
```sh
make
# TODO: make test
```

1.2.4. Copy `xsblua.so` and `xsb.lua` to your lua path:
```sh
cp {xsblua.so,xsb.lua} ~/opt/luajit/lib
```

1.2.5. Clean up
```sh
cd ~
rm -rf /tmp/xsblua
```

# 2. Usage

### 2.2 Example I
Consider the following knowledge-base saved as `kb.P`:
```prolog
man(socrates).
mortal(X) :- man(X).
```

You can load and use it in `lua` like this:
```lua
XSB = require("xsb")
xsb = XSB("~/opt/xsb-3.8.0")        -- This is the default path
xsb:command("consult('kb.P').")     -- Also correct: xsb"consult('kb.P')."
xsb:query("mortal(Who).")
--> { "socrates", }
```

### 2.1 Example II
```lua
xsb = require"xsb"()
xsb:query("(order, (drink, coke), (food, hotdog)) = (order, X, (food, Y)).")
--> { "','(drink,coke)|hotdog", }
```

###### **Note:** *All methods expect correct `XSB Prolog` statements. Feeding erroneous statements to the program, may cause unpredictable behaviour.*

## 3. TODO
- Write tests.
- Add `consult` and `assert` methods.
- Add `unify` method. Use `unify_with_occurs_check/2`.
- Add optional second argument for `query` method to denote maximum desired number of results.
- Update methods `command` and `query` to automatically append `.` (dot) to their arguments when it is missed.
- Update method `query` to parse the results and assign each value to its query variable.
    * e.g:
        ```lua
        { "','(drink,coke)|hotdog", }
        -->
        { X = "(drink,coke)", Y = "hotdog", }
        ```
