ws = module.exports

class ws.ParseError extends Error
    constructor: (msg) ->
        Error.captureStackTrace @, @constructor
        @name = @constructor.name
        @message = "parser: #{msg}"

class ws.GroupError extends ws.ParseError
    constructor: (@group, msg) ->
        Error.captureStackTrace @, @constructor
        @name = @constructor.name
        @message = "parser: group '#{@group}': #{msg}"


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

# Interface
class Pref
    constructor: (@group, @instructions) ->
        throw new ws.ParseError "no group or instructions specified" unless @group && @instructions
        @req = {
            'name' : (val) =>
                this.isStr(val)
            ,
            'desc' : (val) =>
                this.isStr(val)
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

    isStr: (t) ->
        return false if typeof t != 'string'
        !t.match /^\s*$/

    isBoolean: (t) ->
        typeof t == 'boolean'

    isRange: (t) ->
        return false unless t instanceof Array
        return false if t.length != 2
        (return false if typeof idx != 'number') for idx in t
        return false if t[0] > t[1]
        true

    isSize: (t) ->
        return false unless this.isRange t
        return false if t[0] < 0
        true
        

class ws.PrefStr extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) ->
            typeof val == 'string'
        
        @optional['cleanByRegexp'] = (val) =>
            this.isStr(val)

        @optional['validationRegexp'] = (val) =>
            this.isStr(val)
    
        @optional['allowEmpty'] = (val) =>
            this.isBoolean val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefInt extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) ->
            typeof val == 'number'
            
        @optional['range'] = (val) =>
            this.isRange val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefArrayOfStr extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) ->
            return false unless val instanceof Array
            (return false if typeof idx != 'string') for idx in val
            true

        @optional['cleanByRegexp'] = (val) =>
            this.isStr val

        @optional['validationRegexp'] = (val) =>
            this.isStr val

        @optional['size'] = (val) =>
            this.isSize val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefArrayOfInt extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) ->
            return false unless val instanceof Array
            (return false if typeof idx != 'number') for idx in val
            true

        @optional['range'] = (val) =>
            this.isRange val

        @optional['size'] = (val) =>
            this.isSize val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

class ws.PrefBool extends Pref
    constructor: (@group, @instructions) ->
        super @group, @instructions
        @req['default'] = (val) =>
            this.isBoolean val

    gen: ->
        this.validate()
        "<h2>#{@group}<h2>"

