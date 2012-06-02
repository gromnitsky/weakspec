if module
    ws = module.exports
    drw = require './drawer'
else
    ws = window

class ws.ParseError extends Error
    constructor: (msg) ->
        Error.captureStackTrace @, @constructor
        @name = @constructor.name
        @message = "parser: #{msg}"

class ws.PrefError extends ws.ParseError
    constructor: (group, prefName, msg) ->
        Error.captureStackTrace @, @constructor
        @name = @constructor.name
        @message = "parser: group '#{group}': pref '#{prefName}': #{msg}"


class ws.WeakSpec
    constructor: (@spec) ->
        throw new ws.ParseError('the spec must contain at least 1 group') if @size() < 1
        for group, opts of @spec
            @validate group, name, instr for name, instr of opts

    size: ->
        n = 0
        n++ for k of @spec
        n

    validate: (group, name, instr) ->
        throw new ws.PrefError group, name, "no type" unless instr.type
        @validateUid group, name

        mapping = {
            'char*' : ws.PrefStr,
            'int' : ws.PrefInt,
            'char**' : ws.PrefArrayOfStr,
            'int**' : ws.PrefArrayOfInt,
            'bool' : ws.PrefBool
        }

        throw new ws.PrefError group, "invalid type '#{instr.type}'" unless mapping[instr.type]
        (new mapping[instr.type](group, name, instr)).validate()

    validateUid: (group, name) ->
        re = /^[A-Za-z0-9_,. -]+$/
        throw new ws.ParseError "group: invalud value '#{group}'" unless group.match re
        throw new ws.ParseError "group: '#{group}': name: invalud value '#{name}'" unless name.match re

    toHtml: ->
        (new drw.Drawer @spec).draw()

# Interface to data validation from a specfile.
class Pref
    constructor: (@group, @name, @instr) ->
        throw new ws.ParseError "no group or name or instractions" unless @group && @name && @instr
        @req = {
            'desc' : (val) =>
                this.isStr(val)
            ,
            'default' : null,
            'type' : null
        }
        @optional = { 'help' : null, 'cleanCallback' : null, 'validationCallback' : null }

    validate: ->
        for k of @req
            throw new ws.PrefError @group, @name, "missing '#{k}'" if @instr[k] == undefined
            throw new ws.PrefError @group, @name, "invalid value in '#{k}'" if @req[k] && !@req[k](@instr[k])

        for k of @instr when @req[k] == undefined
            throw new ws.PrefError @group, @name, "'#{k}' is unknown" if @optional[k] == undefined
            throw new ws.PrefError @group, @name, "invalid value in '#{k}'" if @optional[k] && @instr[k] != null && !@optional[k](@instr[k])

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
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) ->
            typeof val == 'string'
        
        @optional['cleanByRegexp'] = (val) =>
            this.isStr(val)

        @optional['validationRegexp'] = (val) =>
            this.isStr(val)
    
        @optional['allowEmpty'] = (val) =>
            this.isBoolean val

class ws.PrefInt extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) ->
            typeof val == 'number'
            
        @optional['range'] = (val) =>
            this.isRange val

class ws.PrefArrayOfStr extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
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

class ws.PrefArrayOfInt extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) ->
            return false unless val instanceof Array
            (return false if typeof idx != 'number') for idx in val
            true

        @optional['range'] = (val) =>
            this.isRange val

        @optional['size'] = (val) =>
            this.isSize val

class ws.PrefBool extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) =>
            this.isBoolean val

