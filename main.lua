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


function love.load(arg)
    print('Starting tests...')
    for _, test in pairs(tests) do
        test()
    end
    print('Done')
end
