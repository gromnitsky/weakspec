fs = require 'fs'
path = require 'path'
assert = require 'assert'
util = require 'util'

ws = require '../lib/weakspec'

# opts--an array
check_bogusVal = (prefClass, opts, bogusVal, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = bogusVal
        assert.throws ->
            (new prefClass 'foo', 'bar', instructions).validateSpec()
        , ws.PrefError, "opts=#{util.inspect opts}; bogusVal=#{util.inspect bogusVal}"
        instructions[idx] = orig

# opts--an array
check_val = (prefClass, opts, val, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = val
        assert.doesNotThrow ->
            (new prefClass 'foo', 'bar', instructions).validateSpec()
        instructions[idx] = orig

suite 'WeakSpec', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
        
        eval fs.readFileSync('example/01.json', "ascii")
        @spec01 = weakspec
        @ws01 = new ws.WeakSpec @spec01

        @min_string = {
            "type" : null,
            "desc" : "z",
            "default" : ""
        }
        @min_int = {
            "type" : null,
            "desc" : "zz",
            "default" : 42
        }
        @min_list_multi = {
            "type" : null,
            "desc" : "zzz",
            "default" : ['w', 'e']
            "data" : ['q', 'w', 'e']
            "selectedSize" : [1, 3]
        }
        @min_list_single = {
            "type" : null,
            "desc" : "zzz",
            "default" : ['w']
            "data" : ['q', 'w', 'e']
            "selectedSize" : [1, 1]
        }
        @min_bool = {
            "type" : null,
            "desc" : "zzzzz",
            "default" : true
        }

    test 'smoke test', ->
        assert.equal 4, @ws01.size()
        html = @ws01.toHtml()
        assert.ok html.length > 10

    test 'spec char* validation ok', ->
        check_val ws.PrefStr, ['allowEmpty'], true, @min_string
        
    test 'spec char* validation fail', ->
        assert.throws ->
            (new ws.PrefStr 'foo', 'bar', {}).validateSpec()
        , /missing 'desc'/
        
        check_bogusVal ws.PrefStr, ['default'], [], @min_string
        check_bogusVal ws.PrefStr, ['validationRegexp'], 1, @min_string
        check_bogusVal ws.PrefStr, ['allowEmpty'], undefined, @min_string

        @min_string.default = "qwe"
        @min_string.ooops = 1
        assert.throws =>
            (new ws.PrefStr 'foo', 'bar', @min_string).validateSpec()
        , /'ooops' is unknown/
        delete @min_string.ooops

    test 'spec int validaion ok', ->
        assert.doesNotThrow =>
            (new ws.PrefInt 'foo', 'bar', @min_int).validateSpec()

        check_val ws.PrefInt, ['range'], [10, 100], @min_int

    test 'spec int validation fail', ->
        check_bogusVal ws.PrefInt, ['default'], '', @min_int
        check_bogusVal ws.PrefInt, ['range'], 'whoa', @min_int
        check_bogusVal ws.PrefInt, ['range'], [null], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0, 1, 2], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0, -1], @min_int

    test 'spec list validation ok', ->
        assert.doesNotThrow =>
          (new ws.PrefList 'foo', 'bar', @min_list_multi).validateSpec()
        assert.doesNotThrow =>
            (new ws.PrefList 'foo', 'bar', @min_list_single).validateSpec()

        check_val ws.PrefList, ['selectedSize'], [1, 2], @min_list_multi
        check_val ws.PrefList, ['selectedSize'], [1, 1], @min_list_single
        check_val ws.PrefList, ['selectedSize'], [1, 2], @min_list_single

        check_val ws.PrefList, ['default'], ['q'], @min_list_multi
        check_val ws.PrefList, ['default'], ['q', 'w', 'e'], @min_list_multi
        check_val ws.PrefList, ['default'], ['w'], @min_list_single

        check_val ws.PrefList, ['data'], ['e', 'w', 'q', 'r'], @min_list_multi

    test 'spec list validation fail', ->
        check_bogusVal ws.PrefList, ['default'], 'whoa', @min_list_multi
        check_bogusVal ws.PrefList, ['default'], [], @min_list_multi
        check_bogusVal ws.PrefList, ['default'], ['q', 1], @min_list_multi
        check_bogusVal ws.PrefList, ['default'], ['q', 'whoa'], @min_list_multi
        check_bogusVal ws.PrefList, ['default'], ['q', 'w'], @min_list_single

        check_bogusVal ws.PrefList, ['selectedSize'], 'whoa', @min_list_multi
        check_bogusVal ws.PrefList, ['selectedSize'], [1, 1], @min_list_multi
        check_bogusVal ws.PrefList, ['selectedSize'], [1, null], @min_list_multi
        check_bogusVal ws.PrefList, ['selectedSize'], [-1, 1], @min_list_multi
        check_bogusVal ws.PrefList, ['selectedSize'], [1, 33], @min_list_multi

        check_bogusVal ws.PrefList, ['data'], 'whoa', @min_list_multi
        check_bogusVal ws.PrefList, ['data'], undefined, @min_list_multi
        check_bogusVal ws.PrefList, ['data'], [], @min_list_multi
        check_bogusVal ws.PrefList, ['data'], [1, 2, 3, 4], @min_list_multi
        
    test 'spec bool validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefBool 'foo', 'bar', @min_bool).validateSpec()

        check_val ws.PrefBool, ['default'], false, @min_bool
        
    test 'spec bool validation fail', ->
        check_bogusVal ws.PrefBool, ['default'], 'whoa', @min_bool

    test 'char* validation', ->
        assert !@ws01.validate('Group 1', 'opt1', null)
        assert !@ws01.validate('Group 1', 'opt1', 'zzz')
        assert @ws01.validate('Group 1', 'opt1', 'zz')

        @spec01['Group 1']['opt1'].validationRegexp = null
        @spec01['Group 1']['opt1'].allowEmpty = false
        assert !@ws01.validate('Group 1', 'opt1', '')
        @spec01['Group 1']['opt1'].allowEmpty = true
        assert @ws01.validate('Group 1', 'opt1', '')

    test 'int validation', ->
        assert !@ws01.validate('Group 1', 'opt2', 'whoa')
        assert !@ws01.validate('Group 1', 'opt2', [])
        assert !@ws01.validate('Group 1', 'opt2', 199)
        assert @ws01.validate('Group 1', 'opt2', 99)

    test 'list validation', ->
        assert !@ws01.validate('Group 3', 'opt1', 'whoa')
        assert !@ws01.validate('Group 3', 'opt1', [])
        assert !@ws01.validate('Group 3', 'opt1', 199)
        assert !@ws01.validate('Group 3', 'opt1', [1, 2])
        assert !@ws01.validate('Group 3', 'opt1', ['qqq', 'www', 'eee'])
        assert !@ws01.validate('Group 3', 'opt1', ['one', 'two', 'three'])
        assert @ws01.validate('Group 3', 'opt1', ['one'])
        assert @ws01.validate('Group 3', 'opt1', ['one', 'two'])

        assert !@ws01.validate('Group 4', 'opt1', ['five', 'six'])
        assert !@ws01.validate('Group 4', 'opt1', ['qwe'])
        assert @ws01.validate('Group 4', 'opt1', ['seven'])

    test 'bool validation', ->
        assert !@ws01.validate('Group 5', 'opt1', 'whoa')
        assert @ws01.validate('Group 5', 'opt1', false)

