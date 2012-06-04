root = exports ? this

drw = require?('./drawer') || root

class root.ParseError extends Error
    constructor: (msg) ->
        try
            Error.captureStackTrace @, @constructor
        catch e
            ; # ignore in Opera
        @name = @constructor.name
        @message = "parser: #{msg}"

class root.PrefError extends root.ParseError
    constructor: (group, prefName, msg) ->
        try
            Error.captureStackTrace @, @constructor
        catch e
            ; # ignore in Opera
        @name = @constructor.name
        @message = "parser: group '#{group}': pref '#{prefName}': #{msg}"


class root.WeakSpec
    constructor: (@spec) ->
        throw new root.ParseError('the spec must contain at least 1 group') if @size() < 1
        for group, opts of @spec
            @validateSpecPref group, name for name of opts

    size: ->
        n = 0
        n++ for k of @spec
        n

    mapping: (type) ->
        {
            'char*' : root.PrefStr,
            'int' : root.PrefInt,
            'char**' : root.PrefArrayOfStr,
            'int**' : root.PrefArrayOfInt,
            'bool' : root.PrefBool
        }[type]

    validateSpecPref: (group, name) ->
        instr = @spec[group][name]
        throw new root.PrefError group, name, "no type" unless instr.type
        @validateUid group, name

        throw new root.PrefError group, "invalid type '#{instr.type}'" unless @mapping instr.type
        (new (@mapping instr.type)(group, name, instr) ).validateSpec()

    validateUid: (group, name) ->
        re = /^[A-Za-z0-9_,. -]+$/
        throw new root.ParseError "group: invalud value '#{group}'" unless group.match re
        throw new root.ParseError "group: '#{group}': name: invalud value '#{name}'" unless name.match re

    validate: (group, name, value) ->
        type = @spec[group]?[name]?.type
        throw new Error "no type for #{group}->#{name}" unless type
        (new (@mapping type)(group, name, @spec[group][name]) ).validate(value)

    toHtml: ->
        (new drw.Drawer @spec).draw()

# Interface to data validation from a specfile.
class Pref
    constructor: (@group, @name, @instr) ->
        throw new root.ParseError "no group or name or instractions" unless @group && @name && @instr
        @req = {
            'desc' : (val) =>
                this.isStr(val)
            ,
            'default' : null,
            'type' : null
        }
        @optional = { 'help' : null, 'cleanCallback' : null, 'validationCallback' : null }

    validateSpec: ->
        for k of @req
            throw new root.PrefError @group, @name, "missing '#{k}'" if @instr[k] == undefined
            throw new root.PrefError @group, @name, "invalid value in '#{k}'" if @req[k] && !@req[k](@instr[k])

        for k of @instr when @req[k] == undefined
            throw new root.PrefError @group, @name, "'#{k}' is unknown" if @optional[k] == undefined
            throw new root.PrefError @group, @name, "invalid value in '#{k}'" if @optional[k] && @instr[k] != null && !@optional[k](@instr[k])

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

    validate: (value) ->
        throw new Error 'override me'
        

class root.PrefStr extends Pref
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

    validate: (value) ->
        return @instr.validationCallback(value) if @instr.validationCallback
        return false unless @req['default'](value)
        return false if value == '' && @instr.allowEmpty
        true

class root.PrefInt extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) ->
            typeof val == 'number'
            
        @optional['range'] = (val) =>
            this.isRange val

class root.PrefArrayOfStr extends Pref
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

class root.PrefArrayOfInt extends Pref
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

class root.PrefBool extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @req['default'] = (val) =>
            this.isBoolean val

    validate: (value) ->
        @req['default'](value)
