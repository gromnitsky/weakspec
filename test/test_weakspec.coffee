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
            "default" : "",
            "allowEmpty" : true
            "validationRegexp" : null
        }
        @min_number = {
            "type" : null,
            "desc" : "zz",
            "default" : 42,
            "range" : null
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
            "data" : ['q', 'w', 'e']
            "default" : ['w']
            "selectedSize" : [1, 1]
        }
        @min_bool = {
            "type" : null,
            "desc" : "zzzzz",
            "default" : true
        }
        @min_text = {
            "type" : null,
            "desc" : "z",
            "default" : "12",
            "allowEmpty" : false,
            "range" : [2,4]
        }
        @min_email = {
            "type" : null,
            "desc" : "z",
            "default" : "q@c",
            "allowEmpty" : false
        }
        @min_datetime = {
            "desc" : "z"
            "type" : null
            "default" : "2000-03-01T00:00:00Z"
            "allowEmpty" : true
            "range" : ['2000-03-01T00:00:00Z', '2001-03-01T00:00:00Z']
        }
        @min_date = {
            "desc" : "z"
            "type" : null
            "default" : "2000-03-01"
            "allowEmpty" : true
            "range" : ['2000-03-01', '2000-03-02']
        }

    test 'smoke test', ->
        assert.equal 4, @ws01.size()

    test 'spec string validation ok', ->
        check_val ws.PrefStr, ['validationRegexp'], 'hm', @min_string
        
        @min_string.default = "qwe"
        check_val ws.PrefStr, ['allowEmpty'], false, @min_string
        check_val ws.PrefStr, ['validationRegexp'], 'q', @min_string

    test 'spec string validation fail', ->
        assert.throws ->
            (new ws.PrefStr 'foo', 'bar', {'default' : 'zzz'}).validateSpec()
        , /missing 'desc'/
        
        @min_string.default = "qwe"
        check_bogusVal ws.PrefStr, ['default'], [], @min_string
        check_bogusVal ws.PrefStr, ['validationRegexp'], 1, @min_string
        check_bogusVal ws.PrefStr, ['validationRegexp'], '[', @min_string
        check_bogusVal ws.PrefStr, ['allowEmpty'], undefined, @min_string

        @min_string.ooops = 1
        assert.throws =>
            (new ws.PrefStr 'foo', 'bar', @min_string).validateSpec()
        , /'ooops' is unknown/
        delete @min_string.ooops

        check_bogusVal ws.PrefStr, ['validationRegexp'], '', {
            "type" : null,
            "desc" : "z",
            "default" : null,
            "allowEmpty" : true
        }

        check_bogusVal ws.PrefStr, ['validationRegexp'], '', {
            "type" : null,
            "desc" : "z",
            "allowEmpty" : true
        }

        check_bogusVal ws.PrefStr, ['validationRegexp'], '', {
            "type" : null,
            "desc" : "z",
            "default" : undefined,
            "allowEmpty" : true
        }

    test 'spec number validaion ok', ->
        assert.doesNotThrow =>
            (new ws.PrefNumber 'foo', 'bar', @min_number).validateSpec()

        check_val ws.PrefNumber, ['range'], [10, 100], @min_number

    test 'spec number validation fail', ->
        check_bogusVal ws.PrefNumber, ['default'], '', @min_number
        check_bogusVal ws.PrefNumber, ['range'], 'whoa', @min_number
        check_bogusVal ws.PrefNumber, ['range'], [null], @min_number
        check_bogusVal ws.PrefNumber, ['range'], [0], @min_number
        check_bogusVal ws.PrefNumber, ['range'], [0, 1, 2], @min_number
        check_bogusVal ws.PrefNumber, ['range'], [0, -1], @min_number

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

    test 'spec text validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefText 'foo', 'bar', @min_text).validateSpec()

        check_val ws.PrefText, ['default'], 'Yo', @min_text
        check_val ws.PrefText, ['range'], [1,5], @min_text

        @min_text.default = ''
        check_val ws.PrefText, ['allowEmpty'], true, @min_text

    test 'spec text validation fail', ->
        check_bogusVal ws.PrefText, ['default'], null, @min_text
        check_bogusVal ws.PrefText, ['default'], "1", @min_text
        check_bogusVal ws.PrefText, ['default'], "12345", @min_text

        check_bogusVal ws.PrefText, ['range'], [5,5], @min_text

    test 'spec email validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefEmail 'foo', 'bar', @min_email).validateSpec()

        @min_email.default = ''
        check_val ws.PrefEmail, ['allowEmpty'], true, @min_email

    test 'spec email validation fail', ->
        check_bogusVal ws.PrefEmail, ['default'], "12345", @min_email
        check_bogusVal ws.PrefEmail, ['default'], "q@", @min_email
        check_bogusVal ws.PrefEmail, ['default'], "q@ e", @min_email

    test 'spec datetime validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefDatetime 'foo', 'bar', @min_datetime).validateSpec()

        @min_datetime.default = ''
        check_val ws.PrefDatetime, ['allowEmpty'], true, @min_datetime

    test 'spec datetime validation fail', ->
        check_bogusVal ws.PrefDatetime, ['default'], "q@", @min_datetime
        check_bogusVal ws.PrefDatetime, ['default'], "q@ e", @min_datetime

        check_bogusVal ws.PrefDatetime, ['range'], "q@ e", @min_datetime
        check_bogusVal ws.PrefDatetime, ['range'], ["q@", "e"], @min_datetime
        check_bogusVal ws.PrefDatetime, ['range'], ["2020", "2019"], @min_datetime

    test 'spec date validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefDate 'foo', 'bar', @min_date).validateSpec()

        @min_date.default = ''
        check_val ws.PrefDate, ['allowEmpty'], true, @min_date

    test 'spec date validation fail', ->
        check_bogusVal ws.PrefDate, ['default'], "q@", @min_date
        check_bogusVal ws.PrefDate, ['default'], "q@ e", @min_date

        check_bogusVal ws.PrefDate, ['range'], "q@ e", @min_date
        check_bogusVal ws.PrefDate, ['range'], ["q@", "e"], @min_date
        check_bogusVal ws.PrefDate, ['range'], ["2000-03-02", "2000-03-01"], @min_date

    test 'string validation', ->
        assert !@ws01.validate('Group 1', 'opt1', null)
        assert !@ws01.validate('Group 1', 'opt1', 'zzz')
        assert @ws01.validate('Group 1', 'opt1', 'zz')

        @spec01['Group 1']['opt1'].validationRegexp = null
        @spec01['Group 1']['opt1'].allowEmpty = false
        assert !@ws01.validate('Group 1', 'opt1', '')
        @spec01['Group 1']['opt1'].allowEmpty = true
        assert @ws01.validate('Group 1', 'opt1', '')

    test 'number validation', ->
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

        assert !@ws01.validate('Group #4', 'opt1', ['five', 'six'])
        assert !@ws01.validate('Group #4', 'opt1', ['qwe'])
        assert @ws01.validate('Group #4', 'opt1', ['seven'])

    test 'bool validation', ->
        assert !@ws01.validate('Group 5', 'opt1', 'whoa')
        assert @ws01.validate('Group 5', 'opt1', false)

    test 'week parse', ->
        p = new ws.PrefWeek 'foo', 'bar', '{}'
        assert.equal '2000-01-01', p._dateweek2date '2000-W01'
        assert.equal '2000-02-01', p._dateweek2date '2000-W05'
        assert.equal '2000-12-01', p._dateweek2date '2000-W48'
        assert.equal null, p._dateweek2date '2000-W49'
        assert.equal null, p._dateweek2date '200-W01'
        assert.equal null, p._dateweek2date '2000-W00'
        assert.equal null, p._dateweek2date ''
        assert.equal null, p._dateweek2date null
