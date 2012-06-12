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
        (Object.keys @spec).length

    validateSpecPref: (group, name) ->
        instr = @spec[group][name]
        throw new root.PrefError group, name, "no type" unless instr.type
        @_validateUid group, name

        (new (@_mapping instr.type)(group, name, instr) ).validateSpec()

    _mapping: (type) ->
        {
            'string' : root.PrefStr
            'number' : root.PrefNumber
            'list' : root.PrefList
            'bool' : root.PrefBool
            'text' : root.PrefText
            'color' : root.PrefColor
            'email' : root.PrefEmail
            'datetime' : root.PrefDatetime
            'date' : root.PrefDate
            'week' : root.PrefWeek
            'time' : root.PrefTime
        }[type] || throw new root.ParseError "no method for '#{type}' type"

    _validateUid: (group, name) ->
        throw new root.ParseError "group: invalud value '#{group}'" unless group.indexOf('|') == -1
        throw new root.ParseError "group: '#{group}': name: invalud value '#{name}'" unless name.indexOf('|') == -1

    validate: (group, name, value) ->
        type = @spec[group]?[name]?.type
        throw new Error "no type for #{group}->#{name}" unless type
        (new (@_mapping type)(group, name, @spec[group][name]) ).validate(value)

    toDomElements: ->
        @drw.tree()

# Interface to data validation from a specfile.
class Pref
    constructor: (@group, @name, @instr) ->
        throw new root.ParseError "no group or name or instructions" unless @group && @name && @instr
        @req = {
            'desc' : (val) =>
                this.isStr(val)
            ,
            'type' : null
        }
        @local = [
            { 'help' : null },
            { 'validationCallback' : null }
        ]

    _localFind: (opt) ->
        for idx in @local
            cb = (Object.keys idx)[0]
            return idx[cb] if cb == opt
        undefined

    validateSpec: ->
        if @instr['default'] in [null, undefined]
            throw new root.PrefError @group, @name, "'default' cannot be null or missing"
                        
        # check for required for all
        for k of @req
            throw new root.PrefError @group, @name, "missing '#{k}'" if @instr[k] == undefined
            throw new root.PrefError @group, @name, "invalid value in '#{k}'" if @req[k] && !@req[k](@instr[k])

        # check for unknown
        for k of @instr when @req[k] == undefined
            callback = @_localFind k
            throw new root.PrefError @group, @name, "'#{k}' is unknown" if callback == undefined

        # check for required locals
        for idx in @local
            option = (Object.keys idx)[0]
            callback = idx[option]

            if @instr[option] == undefined && callback != null
                throw new root.PrefError @group, @name, "'#{option}' is required (set if to null if you don't care)"
            
            if callback && @instr[option] != null && !callback(@instr[option])
                throw new root.PrefError @group, @name, "invalid value in '#{option}'"


    isStr: (t) ->
        return false if typeof t != 'string'
        !t.match /^\s*$/

    isRegexp: (t) ->
        return false if typeof t != 'string'
        try
            new RegExp t
        catch error
            return false
        true

    isBoolean: (t) ->
        typeof t == 'boolean'

    isArray: (t) ->
        t instanceof Array

    isRange: (t) ->
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
        @_localFind('default')(value)
        

class root.PrefStr extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'validationRegexp' : (val) =>
            this.isRegexp(val)
        }
    
        @local.push { 'allowEmpty' : (val) =>
            this.isBoolean val
        }

        # add 'default' check
        @local.push { 'default' : (val) =>
            return false if typeof val != 'string'
            return @instr.allowEmpty if val == ''
            (return false unless val.match @instr.validationRegexp) if @instr.validationRegexp
            true
        }

class root.PrefNumber extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
            
        @local.push { 'range' : (val) =>
            this.isRange val
        }

        @local.push { 'default' : (val) =>
            return false if typeof val != 'number'
            return false unless this.inRange(@instr.range, val)
            true
        }

class root.PrefList extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr
        
        @local.push { 'data' : (val) =>
            return false unless @isArray val
            true
        }

        @local.push { 'selectedSize' : (val) =>
            return false unless @isArray val
            return false unless @isRange @instr.selectedSize
            return false unless val[0] <= @instr.data.length && \
                val[1] <= @instr.data.length && \
                val[0] > 0 && val[1] > 0
            true
        }

        @local.push { 'default' : (val) =>
            return false unless @isArray(val) && val.length
            return false unless @isArray @instr.data
            (return false unless idx in @instr.data) for idx in val
            return false unless val.length <= @instr.selectedSize[1]
            true
        }


class root.PrefBool extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'default' : (val) =>
            this.isBoolean val
        }
        
class root.PrefText extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'allowEmpty' : (val) =>
            this.isBoolean val
        }

        @local.push { 'range' : (val) =>
            this.isRange val
        }

        @local.push { 'default' : (val) =>
            return false if typeof val != 'string'
            return @instr.allowEmpty if val == ''
            
            return false if val == ''
            return false unless this.inRange(@instr.range, val.length)
            true
        }
        
class root.PrefColor extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'default' : (val) ->
            val.match /^#[A-Za-z0-9]{3,6}$/
        }

class root.PrefEmail extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'allowEmpty' : (val) =>
            this.isBoolean val
        }

        @local.push { 'default' : (val) =>
            return false if typeof val != 'string'
            return @instr.allowEmpty if val == ''

            return false unless val.match /^[^ ]+@[^ ]+$/
            true
        }

class root.PrefDatetime extends Pref
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

        @local.push { 'allowEmpty' : (val) =>
            this.isBoolean val
        }

        @local.push { 'range' : (val) =>
            @isRange val
        }
        
        @local.push { 'default' : (val) =>
            return false if typeof val != 'string'
            return @instr.allowEmpty if val == ''
            return false unless @isDate val

            if @instr.range
                range = (@dateParse idx for idx in @instr.range)
                return false unless this.inRange range, @dateParse(val)

            true
        }

    # t--iso 8601: 2012-06-12T12:00:00Z
    isDate: (t) ->
        d = new Date t
        d.toISOString().replace(/\.000Z$/, 'Z') == t
        
    isRange: (t) ->
        return false unless this.isArray t
        return false if t.length != 2
        (return false unless @isDate idx) for idx in t
        return false unless @dateParse(t[0]) <= @dateParse(t[1])
        true

    dateParse: (t) ->
        Date.parse t

class root.PrefDate extends root.PrefDatetime
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

    # t--'2012-06-12'
    isDate: (t) ->
        d = new Date t
        d.toISOString().replace(/T.+Z$/, '') == t

class root.PrefWeek extends root.PrefDatetime
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

    # converts '2000-W48' to '2000-12-01'
    _dateweek2date: (t) ->
        try
            [dummy, y, w] = t.match /^([0-9]{4})-W([0-9]{2})$/
        catch error
            return null
            
        y = parseInt y
        w = parseInt w
        return null unless y && w
        return null unless this.inRange [1, 48],  w

        m = Math.ceil w/4
        m = "0#{m}" if m < 10
        "#{y}-#{m}-01"

    dateParse: (t) ->
        Date.parse @_dateweek2date(t)

    # t--'2012-W10'
    isDate: (t) ->
        @dateParse t

class root.PrefTime extends root.PrefDatetime
    constructor: (@group, @name, @instr) ->
        super @group, @name, @instr

    # converts '12:13:14' to '2000-01-01T:12:13:00Z'
    _time2date: (t) ->
        try
            [dummy, h, m, s] = t.match /^([0-9]{2}):([0-9]{2}):([0-9]{2})$/
        catch error
            return null

        h = parseInt h
        m = parseInt m
        s = parseInt s
        (return null unless typeof idx == 'number') for idx in [h, m, s]
        
        return null unless this.inRange [0, 23], h
        return null unless this.inRange [0, 59], m
        return null unless this.inRange [0, 59], s

        h = "0#{h}" if h < 10
        m = "0#{m}" if m < 10
        s = "0#{s}" if s < 10
        "2000-01-01T#{h}:#{m}:#{s}Z"

    dateParse: (t) ->
        Date.parse @_time2date(t)

    # t--'12:13:14'
    isDate: (t) ->
        @dateParse t
                