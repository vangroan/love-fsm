--[[
    A Basic Finite State Machine that can hold a single active state.
]]


local BasicFsm = {}
local meta = { __index = BasicFsm }


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
    assert(self.states[key] == nil, 'Key "' .. key .. '" exists in states')
    self.states[key] = state
end


function BasicFsm:set_state(key)
    assert(self.states[key] ~= nil, 'State "' .. key .. '" does not exist')
    self.current = self.states[key]
end


-------------------
-- Event methods --
-------------------


function BasicFsm:trigger(event_key)
    
end


return BasicFsm
