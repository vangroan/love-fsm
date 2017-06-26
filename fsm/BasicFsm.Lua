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
    o.current_key = ''
    o.states = {}
    -- Events map an event name to a new state
    o.events = {}
    
    return o
end


-------------------
-- State Methods --
-------------------


function BasicFsm:set_state(key, state)
    assert(self.states[key] == nil, 'Key "' .. key .. '" already exists in states')
    self.states[key] = state
end


function BasicFsm:_change_state(new_key, new_state)
    safe_call(self.current, 'on_exit')
    self.current = new_state
    self.current_key = new_key
    safe_call(self.current, 'on_enter')
end


function BasicFsm:change_state(key)
    if key == nil then
        self:_change_state('', nil)
    else
        assert(self.states[key] ~= nil, 'State "' .. key .. '" does not exist')
        self:_change_state(key, self.states[key])
    end
end


-------------------
-- Event methods --
-------------------


function BasicFsm:add_event(event_key, source_key, target_key)
    if self.events[event_key] == nil then
        self.events[event_key] = {}
    end
    
    assert(self.events[event_key][source_key] == nil, 'Event "' .. event_key .. '" already has a transition from "' .. source_key .. '"')
    self.events[event_key][source_key] = target_key
end


function BasicFsm:trigger(event_key)
    assert(self.events[event_key] ~= nil, 'Event "' .. event_key .. '" does not exist')
    
    local source_key = self.current_key
    assert(self.events[event_key][source_key] ~= nil, 'Event "' .. event_key .. '" transition has no source "' .. source_key)
    
    local target_key = self.events[event_key][source_key]
    self:change_state(target_key)
end


return BasicFsm
