--[[
    A Basic Finite State Machine that can hold a single active state.
]]


local BasicFsm = {}
local meta = { __index = BasicFsm }


-- Calls the function name on the given table, if the table is not nil and the
-- function is not nil. Does nothing otherwise.
local function safe_call(t, func_name)
    if t ~= nil then
        local f = t[func_name]
        if f ~= nil then
            f(t)
        end
    end
end


-- Functions that will be delegated to the current state
local delegates = {
        'update', 'keypressed', 'keyreleased'
    }


-- Adds delegate methods to class which will be despatched to the current state
function BasicFsm._init_delegates(cls)
    for _, f in ipairs(delegates) do
        if cls[f] == nil then
            cls[f] = function(self, ...)
                local event_key = nil
                if self.current ~= nil then
                    event_key = self.current[f](self.current, ...)
                    if event_key ~= nil then
                        self:trigger(event_key)
                    end
                end
            end
        end
    end
end


BasicFsm._init_delegates(BasicFsm)


function BasicFsm:new()
    local o = setmetatable({}, meta)
    
    o.current = nil
    o.states = {}
    -- Events map an event name to a new state
    o.events = {}
    
    return o
end


-------------------
-- State Methods --
-------------------


function BasicFsm:add_state(key, state)
    assert(self.states[key] == nil, 'Key "' .. key .. '" already exists in states')
    self.states[key] = state
end


function BasicFsm:_set_state(new_state)
    safe_call(self.current, 'on_exit')
    self.current = new_state
    safe_call(self.current, 'on_enter')
end


function BasicFsm:set_state(key)
    if key == nil then
        self:_set_state(nil)
    else
        assert(self.states[key] ~= nil, 'State "' .. key .. '" does not exist')
        self:_set_state(self.states[key])
    end
end


-------------------
-- Event methods --
-------------------


function BasicFsm:add_event(event_key, target)
    assert(self.events[event_key] == nil, 'Key "' .. event_key .. '" already exists in events')
    self.events[event_key] = target
end


function BasicFsm:trigger(event_key)
    assert(self.events[event_key] ~= nil, 'Event "' .. event_key .. '" does not exist')
    self:set_state(self.events[event_key])
end


return BasicFsm
