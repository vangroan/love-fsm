-- Tests
io.stdout:setvbuf("no")

local BasicFsm = require 'fsm.BasicFsm'


local tests = {}


-- Checks that a state cannot be added more than once on the same kay
function tests.add_multiple()
    local fsm = BasicFsm:new()
    fsm:add_state('stand', {})
    local success, err = pcall(fsm.add_state, fsm, 'stand', {})
    assert(success == false, 'Expected error to be thrown')
end


function tests.delegates()
    local fsm = BasicFsm:new()
    local state = {
        val = 0,
        update = function(self, dt)
            self.val = dt * 1000
        end
    }
    fsm:add_state('stand', state)
    fsm:set_state('stand')
    fsm:update(0.16)
    assert(state.val == 160, 'Update delegate on state was not called')
end


function love.load(arg)
    print('Starting tests...')
    for _, test in pairs(tests) do
        test()
    end
    print('Done')
end
