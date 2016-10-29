local exports = {}

local version = require 'nginx-metrix.version'
local lust = require 'Lust'
local logger = require 'nginx-metrix.logger'
local nginx = ngx

local formats2headers = {
    ["text"] = "text/plain",
    ["html"] = "text/html",
    ["json"] = "application/json",
}

local headers2formats = {}
for k,v in pairs(formats2headers) do
    headers2formats[v]=k
end

local header_http_accept = function()
    local _accept = {}
    local accept_headers = nginx.req.get_headers().accept
    if accept_headers then
        for accept in string.gmatch(accept_headers, "%w+/%w+") do
            table.insert(_accept, accept)
        end
    end
    return iter(_accept)
end

---
-- @return string
local get_format = function()
    -- trying to get format from GET params
    local uri_args = nginx.req.get_uri_args()
    if uri_args["format"] and formats2headers[uri_args["format"]] then
        return uri_args["format"]
    end

    for _, accept in header_http_accept() do
        if headers2formats[accept] then
            return headers2formats[accept]
        end
    end

    -- default is text
    return 'text'
end

---
-- @param content_type string
---
local set_content_type_header = function(content_type)
  if nginx.headers_sent then
        logger.warn('Can not set Content-type header because headers already sent')
    else
    nginx.header.content_type = content_type or formats2headers[get_format()]
    end
end

local title = function()
    return 'Nginx Metrix'
end

local title_version = function()
    return title() .. ' v' .. version
end

---------------------------
-- Utils
---------------------------

local format_value = function(collector, name, value)
    if value ~= nil and type(collector.fields) == 'table' and collector.fields[name] ~= nil and collector.fields[name].format ~= nil then
        value = collector.fields[name].format:format(value)
    end

    return value
end

---------------------------
-- HTML
---------------------------

local html_page_template = function(body)
    local tpl = lust{[[
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://yastatic.net/bootstrap/3.3.6/css/bootstrap.min.css" crossorigin="anonymous">
        <link rel="stylesheet" href="https://yastatic.net/bootstrap/3.3.6/css/bootstrap-theme.min.css" crossorigin="anonymous">
        <title>@if(title)<title>else<default_title></title>
    </head>
    <body>
        <div class="row">
        <div class="col-md-4 col-md-offset-1">
        <h1>@if(title)<title>else<default_title></h1>
        @body
        </div>
        </div>
        <script src="https://yastatic.net/jquery/1.12.0/jquery.min.js"></script>
        <script src="https://yastatic.net/bootstrap/3.3.6/js/bootstrap.min.js" crossorigin="anonymous"></script>
    </body>
</html>
        ]],
        title = [[$title]],
        default_title = title()
    }

    if body then
        tpl.body = body
    end

    return tpl
end

local html_section_template = function(body)
    local tpl = lust{[[
                <div class="panel panel-@if(class)<class>else<default_class>">
                    <div class="panel-heading">
                        <h3 class="panel-title">$name</h3>
                    </div>
                    @if(with_body)<panel_body>else<body>
                </div>
        ]],
        panel_body = [[
            <div class="panel-body">
                @body
            </div>
        ]],
        class = [[$class]],
        default_class = [[default]],
    }

    if body then
        tpl.body = body
    end

    return tpl
end

local html_table_template = function()
    return lust{[[
            <table class="table table-bordered table-condensed table-hover">
            @map{ item=items }:{{<tr><th class="col-md-2">$item.name</th><td>$item.value</td></tr>}}
            </table>
    ]]}
end

local html_render_stats = function(collector)
    return html_section_template(
        html_table_template():gen{
            items = collector:get_raw_stats():map(
                function(name, value)
                    return {name=name, value=format_value(collector, name, value)}
                end
            ):totable()
        }
    ):gen{name=collector.name, with_body=false}
end

local text_header = function()
    return lust("### $title ###\n"):gen{title = title_version()}
end

local text_section_template = function(stats)
    local tpl = lust("\n[$namespace@$collector]\n@stats")
    if stats then
        tpl.stats = stats
    end
    return tpl
end

local text_item_template = function()
    return lust("$name=$value\n")
end

local text_render_stats = function(collector)
    return collector:get_raw_stats():reduce(
        function(formated_stats, name, value)
            return formated_stats .. text_item_template():gen{name=name, value=format_value(collector, name, value)}
        end,
        ''
    )
end

--------------------------------------------------------------------------------
-- EXPORTS
--------------------------------------------------------------------------------

exports.get_format = get_format
exports.set_content_type_header = set_content_type_header
exports.title = title
exports.title_version = title_version
exports.html = {}
exports.html.page_template = html_page_template
exports.html.section_template = html_section_template
exports.html.table_template = html_table_template
exports.html.render_stats = html_render_stats
exports.text = {}
exports.text.header = text_header
exports.text.section_template = text_section_template
exports.text.item_template = text_item_template
exports.text.render_stats = text_render_stats

if __TEST__ then
    exports.__private__ = {
        header_http_accept = header_http_accept,
        format_value = format_value
    }
end

return exports
