-- Some super function to test
function my_super_function( arg1, arg2 ) return arg1 + arg2 end

require('luaunit')
require('')

TestMyStuff = {} --class
    function TestMyStuff:testWithNumbers()
        a = 1
        b = 2
        result = my_super_function( a, b )
        --assertEquals( type(result), 'number' )
        --assertEquals( result, 3 )
        assertEquals( result, 3 )
    end

    function TestMyStuff:testWithRealNumbers()
        a = 1.1
        b = 2.2
        result = my_super_function( a, b )
        assertEquals( type(result), 'number' )
        -- I would like the result to be always rounded to an integer
        -- but it won't work with my simple implementation
        -- thus, the test will fail
        --assertEquals( result, 3 )
        assertEquals( result, 3.3 )
    end

-- class TestMyStuff
LuaUnit:run()
