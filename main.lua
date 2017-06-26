-- Tests

-- Print output immediately
io.stdout:setvbuf("no")

local BasicFsm = require 'fsm.BasicFsm'


local tests = {}


-- Checks that a state cannot be added more than once on the same key
function tests.add_multiple()
    local fsm = BasicFsm:new()
    fsm:set_state('stand', {})
    local success, err = pcall(fsm.set_state, fsm, 'stand', {})
    assert(success == false, 'Expected error to be thrown')
end


function tests.delegates()
    local fsm = BasicFsm:new()
    
    -- Ensure that calling a delegate on an FSM with no current state will not
    -- throw an error.
    fsm:update(0.16)
    
    -- Test that the the call is delegated to the current state
    local state = {
        val = 0,
        update = function(self, dt)
            self.val = dt * 1000
        end
    }
    fsm:set_state('stand', state)
    fsm:change_state('stand')
    fsm:update(0.16)
    assert(state.val == 160, 'Update delegate on state was not called')
end


function tests.setting_state()
    local fsm = BasicFsm:new()
    local state = { name = 'walk' }
    fsm:set_state('state', state)
    
    fsm:change_state('state')
    assert(fsm.current == state, 'Unexpected current state')
    
    fsm:change_state(nil)
    assert(fsm.current == nil, 'Current state expected to be nil')
    
    local success, err = pcall(fsm.change_state, fsm, 'walk')
    assert(success == false, 'Setting state of unknown key succeeded')
end


function tests.triggering_events()
    local fsm = BasicFsm:new()
    fsm:add_event('go_for_walk', 'stand', 'walk')
    
    local walk_entered = false
    
    local stand = {
        update = function(self, dt)
            return 'go_for_walk'
        end
    }
    local walk = {
        on_enter = function(self)
            walk_entered = true
        end
    }
    
    fsm:set_state('stand', stand)
    fsm:set_state('walk', walk)
    
    fsm:change_state('stand')
    fsm:update(0.16)
    
    assert(fsm.current == walk, 'State not changed to "walk"')
    assert(walk_entered == true, 'Walk was not entered')
end


function tests.event_errors()
    local fsm = BasicFsm:new()
    fsm:set_state('stand', {})
    
    local success, err = false, ''
    
    -- Event doesn't exist
    success, err = pcall(fsm.trigger, fsm, 'does_not_exist')
    assert(success == false, 'Unexpected success when event does not exist')
    
    -- Event exists, but Source state does not exist
    fsm:add_event('stand_up', 'sit', 'stand')
    success, err = pcall(fsm.trigger, fsm, 'stand_up')
    assert(success == false, 'unexpected success when source does not exist')
    
    -- Event already exists
    success, err = pcall(fsm.add_event, fsm, 'stand_up')
    assert(success == false, 'Unexpected success when event already exists')
    
    -- Event is already transitions from any
    fsm:add_event('jump', '*', 'that')
    success, err = pcall(fsm.add_event, fsm, 'jump', 'this', 'that')
    assert(success == false, 'Unexpected success when event already transitions from "*"')
end


-- Ensure that an event can be sourced from any states
function tests.event_source_anything()
    local fsm = BasicFsm:new()
    fsm:set_state('stand', { name = 'state' })
    fsm:set_state('walk', { name = 'walk' })
    fsm:add_event('go', '*', 'walk')
    
    -- Should be able to transition to walk from any state
    fsm:change_state('stand')
    fsm:trigger('go')
    
    assert(fsm.current.name == 'walk', 'State did not transition to "walk"')
end


function tests.enter_and_exit()
    local fsm = BasicFsm:new()
    local state = {
        val = 0,
        on_enter = function(self)
            self.val = self.val + 7
        end,
        on_exit = function(self)
            self.val = self.val - 11
        end
    }
    fsm:set_state('stand', state)
    fsm:change_state('stand')
    assert(state.val == 7, 'State value was not updated on enter')
    fsm:change_state(nil)
    assert(state.val == -4, 'State value was not udpated on exit')
end


function love.load(arg)
    if arg[#arg] == '-debug' then require("mobdebug").start() end
    print('Starting tests...')
    for _, test in pairs(tests) do
        test()
    end
    print('Done')
end
