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
        @drw = new drw.Drawer @spec

    size: ->
        n = 0
        n++ for k of @spec
        n

    validateSpecPref: (group, name) ->
        instr = @spec[group][name]
        throw new root.PrefError group, name, "no type" unless instr.type
        @_validateUid group, name

        (new (@_mapping instr.type)(group, name, instr) ).validateSpec()

    _mapping: (type) ->
        {
            'char*' : root.PrefStr,
            'int' : root.PrefInt,
            'list' : root.PrefList,
            'bool' : root.PrefBool
        }[type] || throw new root.PrefError group, "no method for '#{instr.type}' type"

    _validateUid: (group, name) ->
        re = /^[A-Za-z0-9_,. -]+$/
        throw new root.ParseError "group: invalud value '#{group}'" unless group.match re
        throw new root.ParseError "group: '#{group}': name: invalud value '#{name}'" unless name.match re

    validate: (group, name, value) ->
        type = @spec[group]?[name]?.type
        throw new Error "no type for #{group}->#{name}" unless type
        (new (@_mapping type)(group, name, @spec[group][name]) ).validate(value)

    toHtml: ->
        @drw.draw()

# Interface to data validation from a specfile.
class Pref
    constructor: (@group, @name, @instr) ->
        throw new root.ParseError "no group or name or instractions" unless @group && @name && @instr
        @req = {
            'desc' : (val) =>
                this.isStr(val)
            ,
            'type' : null
        }
        @local = {
            'help' : null,
            'validationCallback' : null,
            'default' : null
        }

    validateSpec: ->
        for k of @req
            throw new root.PrefError @group, @name, "missing '#{k}'" if @instr[k] == undefined
            throw new root.PrefError @group, @name, "invalid value in '#{k}'" if @req[k] && !@req[k](@instr[k])

        for k of @instr when @req[k] == undefined
            throw new root.PrefError @group, @name, "'#{k}' is unknown" if @local[k] == undefined
            throw new root.PrefError @group, @name, "invalid value in '#{k}'" if @local[k] && @instr[k] != null && !@local[k](@instr[k])

    isStr: (t) ->
        return false if typeof t != 'string'
        !t.match /^\s*$/

    isBoolean: (t) ->
        typeof t == 'boolean'

    isArray: (t) ->
        t instanceof Array

    isRange: (t) =>
        return false unless @isArray t
        return false if t.length != 2
        (return false if typeof idx != 'number') for idx in t
        return false if t[0] > t[1]
        true

    inRange: (range, t) ->
        return true if !range
        [min, max] = range
        t >= min && t <= max

    validate: (value) ->
        return @instr.validationCallback(value) if @instr.validationCallback
        @local['default'](value)
        

class root.PrefStr extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local['validationRegexp'] = (val) =>
            this.isStr(val)
    
        @local['allowEmpty'] = (val) =>
            this.isBoolean val

        @local['default'] = (val) =>
            return false if typeof val != 'string'
            return false if val == '' && !@instr.allowEmpty
            (return false unless val.match @instr.validationRegexp) if @instr.validationRegexp
            true
        

class root.PrefInt extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
            
        @local['range'] = (val) =>
            this.isRange val

        @local['default'] = (val) =>
            return false if typeof val != 'number'
            return false unless this.inRange(@instr.range, val)
            true

class root.PrefList extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        @local['data'] = (val) =>
            return false unless @isArray val
            true

        @local['selectedSize'] = (val) =>
            return false unless @isArray val
            return false unless @isRange @instr.selectedSize
            return false unless val[0] <= @instr.data.length && \
                val[1] <= @instr.data.length && \
                val[0] > 0 && val[1] > 0
            true

        @local['default'] = (val) =>
            return false unless @isArray(val) && val.length
            return false unless @isArray @instr.data
            (return false unless idx in @instr.data) for idx in val
            return false unless val.length <= @instr.selectedSize[1]
            true


class root.PrefBool extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local['default'] = (val) =>
            this.isBoolean val
