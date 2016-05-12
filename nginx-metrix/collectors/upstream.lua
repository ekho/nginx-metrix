local collector = {
    name = 'upstream',
    ngx_phases = { [[log]] },
    fields = {
        rps = { format = '%d', cyclic = true, },
        connect_time = { format = '%0.3f', mean = true, },
        header_time = { format = '%0.3f', mean = true, },
        response_time = { format = '%0.3f', mean = true, },
    }
}

function collector:on_phase(phase)
    if phase == 'log' and ngx.var.upstream_addr ~= nil then
        self.storage:cyclic_incr('rps')
        self.storage:mean_add('connect_time', ngx.var.upstream_connect_time)
        self.storage:mean_add('header_time', ngx.var.upstream_header_time)
        self.storage:mean_add('response_time', ngx.var.upstream_response_time)
    end
end

return collector