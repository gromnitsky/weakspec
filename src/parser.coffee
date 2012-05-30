ws = module.exports

class ws.ParseError extends Error
    constructor: (msg) ->
        e = super "parser: #{msg}"
        e.name = 'ws.ParseError'
        return e # works in coffeescript 1.3.3

class ws.GroupError extends ws.ParseError
    constructor: (@group, msg) ->
        e = super "group '#{@group}': #{msg}"
        e.name = 'ws.GroupError'
        return e


class ws.WeakSpec
    constructor: (@spec) ->
        throw new ws.ParseError('the spec must contain at least 1 entry') if this.size() < 1
        this.chain = []
        (this.chain.push this.delegate(k, v)) for k,v of @spec

    size: ->
        n = 0
        n++ for k of @spec
        n

    delegate: (group, instructions) ->
        throw new ws.GroupError group, "no type" unless instructions.type

        mapping = {
            'char*' : ws.PrefStr,
            'int' : ws.PrefInt,
            'char**' : ws.PrefArrayOfStr,
            'int**' : ws.PrefArrayOfInt,
            'bool' : ws.PrefBool
        }

        throw new ws.GroupError group, "invalid type '#{instructions.type}'" unless mapping[instructions.type]
        (new mapping[instructions.type](group, instructions)).gen()

    draw: ->
        console.log this.chain

# Abstract
class Pref
    constructor: (@group, @instructions) ->
        @req = {
            'name' : (val) =>
                !this.isEmptyStr(val)
            ,
            'desc' : (val) =>
                !this.isEmptyStr(val)
            ,
            'default' : null,
            'type' : null
        }
        @optional = { 'help' : null, 'cleanCallback' : null, 'validationCallback' : null }

    validate: ->
        for k of @req
            throw new ws.GroupError @group, "missing '#{k}'" if @instructions[k] == undefined
            throw new ws.GroupError @group, "invalid value in '#{k}'" if @req[k] && !@req[k](@instructions[k])

        for k of @instructions when @req[k] == undefined
            throw new ws.GroupError @group, "'#{k}' is unknown" if @optional[k] == undefined
            throw new ws.GroupError @group, "invalid value in '#{k}'" if @optional[k] && @instructions[k] != null && !@optional[k](@instructions[k])

    gen: ->
        throw new Error 'override me'

    isEmptyStr: (t) ->
        return true if typeof t != 'string'
        t.match /^\s*$/

    isBoolean: (t) ->
        typeof t == 'boolean'

class ws.PrefStr extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) =>
            typeof val == 'string'
        
        @optional['cleanByRegexp'] = (val) =>
            !this.isEmptyStr(val)

        @optional['validationRegexp'] = (val) =>
            !this.isEmptyStr(val)
    
        @optional['allowEmpty'] = (val) =>
            this.isBoolean val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefInt extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @optional['range'] = null

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefArrayOfStr extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @optional['cleanByRegexp'] = null
        @optional['validationRegexp'] = null
        @optional['size'] = null

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefArrayOfInt extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @optional['size'] = null
        @optional['range'] = null

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefBool extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

