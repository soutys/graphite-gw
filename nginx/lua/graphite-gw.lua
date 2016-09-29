----------------------------------
-- Authorizaton configuration
----------------------------------

-- Some prefix to help with writing ACLS
prefix = ngx.var.graphite_gw_prefix

-- Get CN from the client certificate
client_name = string.gsub(string.sub(ngx.var.ssl_client_s_dn, 5), "%.", "_")
if not client_name then
    echo(530, "Cannot get CN from certificate")
end

-- ACLS, to check if client can write to chosen graphite leaf
--
-- Entry format:
-- [<client name regex>] = <metric regex>
-- Example:
--
-- ACLS = {
--     ['^[a-z0-9-]+_(firstdomain|seconddomain)_(net|com)$'] = 
--     {'^[\\s]*' .. prefix .. 'dc01.' .. client_name .. '.[a-z0-9-_\\. ]+$'},
-- 
--     ['^[a-z0-9-]+_subdomain_(firstdomain|seconddomain)_net$'] = 
--     {'^[\\s]*' .. prefix .. 'dc02.' .. client_name .. '.[a-z0-9-_. ]+$'},
-- }
--
-- The first acl will, if prefix is "metrics." let client "test1.example.com" 
-- write to the leaf "metrics.dc01.test1_example_com.".
--
-- If not necessary it can be left empty.
ACLS = {}

----------------------------------

-- Log and return a message then exit
local function echo(status, message)
        ngx.status = status
        ngx.say(message)
        ngx.log(ngx.ERR, message)
        ngx.exit(status)
end

-- Return table length
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
    
-- Check if all lines in a message match a regex
local function match_lines(lines, regex)
    for line in lines:gmatch("[^\r\n]+") do
        matched_line, err = ngx.re.match(line, regex, "d")
        if not matched_line then
            return false
        end
    end
    return true
end

-- Get graphite_out POST argument value
local function get_graphite_out()
    ngx.req.read_body()
    
    local args, err = ngx.req.get_post_args()
    graphite_out = args['graphite_out']
    if not graphite_out then
        echo(531, "No graphite_out POST argument: ")
    end
    if ngx.var.log_graphite_out == "1" then
        ngx.log(ngx.ERR, graphite_out)
    end
    return graphite_out
end

-- Send data to graphite
local function send_to_graphite(graphite_address, graphite_port, graphite_out)
    local sock = ngx.socket.tcp()
    sock:settimeout(ngx.var.graphite_timeout)
    local ok, err = sock:connect(graphite_address, graphite_port)
    if not ok then
        echo(532, "Failed to connect to graphite: ")
    end
    
    local bytes, err = sock:send(graphite_out)
    if not bytes then
        echo(533, "Cannot send to graphite: ")
    end
    
    sock:close()
    return
end

-- Check if data can be sent to graphite
local function match_graphite_out(acls, graphite_out)
    for cert_regex, acl in pairs(acls) do
        if match_lines(client_name, cert_regex) then
            for i, metrics_regex in pairs(acls[cert_regex]) do
                if match_lines(graphite_out, metrics_regex) then
                    return true
                end
            end
            echo(534, "Not authorized to write to graphite leaf")
        end
    end
    echo(535, "Cannot match certificate")
end

graphite_out = get_graphite_out()

matched_graphite_out = match_graphite_out(ACLS, graphite_out)

if tablelength(ACLS) > 0 then
    if matched_graphite_out then
        send_to_graphite(ngx.var.graphite_address, ngx.var.graphite_port, graphite_out)
    else
        echo(536, "Unknown error" )
    end
else
    send_to_graphite(ngx.var.graphite_address, ngx.var.graphite_port, graphite_out)
end
