Nginx Metrix
============
[![Travis CI Build Status](https://travis-ci.org/ekho/nginx-metrix.svg?branch=1.1-dev)](https://travis-ci.org/ekho/nginx-metrix)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/5gremr4yvc1tospa/branch/1.1-dev?svg=true)](https://ci.appveyor.com/project/ekho/nginx-metrix/branch/1.1-dev)
[![Coverage Status](https://coveralls.io/repos/github/ekho/nginx-metrix/badge.svg?branch=1.1-dev)](https://coveralls.io/github/ekho/nginx-metrix?branch=1.1-dev)

Extended nginx status and metrics.

Description
-----------

Nginx out-of-the-box has not the most complete status page provided by [status](http://nginx.org/ru/docs/http/ngx_http_status_module.html) module.
It is worth noting that in Nginx Plus, this module provides more information.

But using [lua](https://github.com/openresty/lua-nginx-module) module can get much more information. This is the purpose nginx-metrix.

Metrix entirely written in [lua](https://www.lua.org/).

**Base features of Metrix:**
* OpenSource ([MIT licence](/LICENCE))
* modularity
* extensibility (in future)
* complete code coverage

[![Screenshot](/doc/screenshot_preview.png)](/doc/screenshot.png)

Requirements
------------

* nginx >= 1.6.0, but recommended >= 1.9.0
* lua-nginx-module >= 0.9.17
* luarocks >= 2.0

Usage
-----

Nginx with lua-nginx-module should be installed using their instructions.

### Install nginx metrix module
There are two ways to install: globally and locally.

**Global installation**
```
luarocks install nginx-metrix
```

**Local installation**
```
luarocks install nginx-metrix --local
```

*There is a little trick that allows you to setup into an arbitrary folder - specify the HOME environment variable when running `luarocks install`*

### Configure nginx

1\. Put into `http` section

```
lua_shared_dict metrix 16m; # creating metrix storage in nginx shared memory. Usually 16 megabytes should be enough

#lua_package_path '/home/user/.luarocks/share/lua/5.1/?.lua;;'; # Needs only if metrix installed locally
#lua_package_cpath '/home/user/.luarocks/lib/lua/5.1/?.so;;';   # Needs only if metrix installed locally

# init metrix
# In vhosts parameter you can (but not necessary) list all the primary server_name of virtual hosts
init_by_lua_block {
  metrix = require 'nginx-metrix.main'({
    shared_dict = 'metrix',
    vhosts = {'mydomain1', 'mydomain2', ...},
    window_size = 10,
  })
}

# init aggregating scheduler on workers
init_worker_by_lua_block {
    metrix.init_scheduler()
}
```

2\. Put into every `server` section

```
log_by_lua_block {
    metrix.handle_ngx_phase()
}
```

3\. There are two ways to output collected stats

&nbsp;&nbsp;&nbsp;&nbsp;1\. Special location in the existing `server` section.
```
location /metrix/ {
  default_type 'text/plain';
  content_by_lua_block {
    metrix.show()
  }
}

```
&nbsp;&nbsp;&nbsp;&nbsp;2\. Separate virtual host (`server`):

```
server {
    listen 81;
    server_name metrix;

    location / {
        default_type 'text/plain';
        content_by_lua_block {
          metrix.show({vhosts_filter='.*'})
        }
    }
}
```

*NOTE 1: You should to take care of security. For example to use the allow/deny rules or authorization.*

*NOTE 2: You can use both methods together.*

### See or collect stats

Stats can be found at http://mydomain/metrix/ in case of special location. Or at http://metrix:81/ in case of separate server configuration.

Statistics can be viewed in the browser or obtain using various tools.

Supported output formats: `text`(default), `html` and `json`. Format determines by `Accept` http header or by `format` parameter.

By default statistics shows for current virtual host. But you can specify `vhosts_filter` parameter (list of strings or lua string pattern).
List of affected virtual hosts can be obtained by `list_vhosts` query string parameter.
If `vhosts_filter` specified and you want to see stats about only one of vhosts you should pass parameter `vhost=yourdomain.com` in query string.

#### Bundled metrics

1. **request**
    1. `rps` - number of requests per second
    1. `internal_rps` - number of internal requests per second
    1. `https_rps` - number of https requests per second
    1. `time_ps` - average time of request processing
    1. `length_ps` - average length of request
1. **status** - number of requests per second grouped by response status (200, 301, 302, 404, 500, etc).
1. **upstream**
    1. `rps` - number of requests sent to an upstreams per second
    1. `connect_time` - average time of connection to upstreams
    1. `header_time` - average time of http header transfers
    1. `response_time` - average time of upstream response

Extending
---------

Cookbook about creating custom metrics: [COOKBOOK-COLLECTORS.md](/doc/COOKBOOK-COLLECTORS.md).

Contributing
------------

See [CONTRIBUTING.md](/CONTRIBUTING.md). All issues, suggestions, and most importantly pull requests are welcome.

Licence
-------

Copyright 2016 Banki.ru News Agency, Ltd. MIT licensed. See [LICENSE](/LICENSE) for details.
