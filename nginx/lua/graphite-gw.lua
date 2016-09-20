-- Gets the value of "graphite_out" HTTP POST parameter
local function get_graphite_out()
    ngx.req.read_body()
    
    local args, err = ngx.req.get_post_args()
    graphite_out = args['graphite_out']
    if not graphite_out then
        ngx.status = 530
        ngx.say("No graphite_out post argument: ")
        return
    end
    if ngx.var.log_graphite_out == "1" then
        ngx.log(ngx.ERR, graphite_out)
    end
    return graphite_out
end

-- Sends data to graphite
local function send_to_graphite(graphite_address, graphite_port, graphite_out)
    local sock = ngx.socket.tcp()
    sock:settimeout(ngx.var.graphite_timeout)
    local ok, err = sock:connect(graphite_address, graphite_port)
    if not ok then
        ngx.status = 532
        ngx.say("Failed to connect to graphite: ", err)
        ngx.log(ngx.ERR, "Failed to connect to graphite: ", err)
        return
    end
    
    local bytes, err = sock:send(graphite_out)
    if not bytes then
        ngx.status = 533
        ngx.say("Cannot send to graphite: ", err)
        ngx.log(ngx.ERR, "Cannot send to graphite: ", err)
        return
    end
    
    sock:close()
    return
end

graphite_out = get_graphite_out()
send_to_graphite(ngx.var.graphite_address, ngx.var.graphite_port, graphite_out)
