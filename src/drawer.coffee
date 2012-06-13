root = exports ? this

dg = require?('./domgenerator') || root

class root.Drawer
    # spec must be validated with Pref* by WeakSpec
    constructor: (@spec) ->
        throw new Error 'no valid spec' unless @spec && @size() > 1
        @DG = dg.DomGenerator

    size: ->
        (Object.keys @spec).length

    tree: ->
        nodes = []
        for group, opts of @spec
            o = this

            grp = @DG.n null, 'fieldset'
            form = @DG.n grp, 'form', {}, ->
                @d.n this, 'legend', null, ->
                    # caption
                    @d.t this, group
                    
                @d.n this, 'table', null, ->
                    o.generatePref this, group, name, instr for name, instr of opts

                @d.n this, 'div', null, ->
                    @d.n this, 'input', { 'type' : 'reset' }
                    @d.t this, ' '
                    @d.n this, 'input', { 'type' : 'submit', 'value' : 'Save' }

            nodes.push grp.node
        nodes

    uid: (group, name, type) ->
        return [group, name, type].join '|' if type in ['bHelp', 'bDefault']
        [group, name, "p#{type}"].join '|'

    _mapping: (type) ->
        {
            'string' : @pString
            'number' : @pNumber
            'list' : @pList
            'bool' : @pBool
            'text' : @pText
            'color' : @pColor
            'email' : @pEmail
            'datetime' : @pDatetime
            'date' : @pDate
            'week' : @pWeek
            'time' : @pTime
        }[type] || throw new Error "invalid type '#{type}'"

    generatePref: (parentDomGen, group, name, instr) ->
        try
            @_mapping instr.type
        catch e
            throw new Error "cannot draw '#{instr.type}': #{e.message}"

        o = this
        @DG.n parentDomGen, 'tr', null, ->
            @d.n this, 'th', null, ->
                @d.t this, instr.desc
            @d.n this, 'td', null, ->
                # execute in the class instance context 'o'
                o._mapping(instr.type).call(o, this, group, name, instr)
            @d.n this, 'td', null, ->
                @d.n this, 'button', { 'type' : 'button', "class" : "bDefault", "id" : o.uid(group, name, "bDefault") }, ->
                    @d.t this, 'Default'
                @d.t this, ' '
                @d.n this, 'a', { "href" : "#", "class" : "bHelp", "id" : o.uid(group, name, "bHelp") }, ->
                    @d.t this, "?"

    pString: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "string")
        }
        attr['pattern'] = instr.validationRegexp if instr.validationRegexp
        attr['required'] = "" if !instr.allowEmpty
        @DG.n parentDomGen, 'input', attr

    pNumber: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "number"),
            "required" : "",
            "type" : "number"
        }
        attr['min'] = instr.range[0] if instr.range
        attr['max'] = instr.range[1] if instr.range
        @DG.n parentDomGen, 'input', attr

    pList: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "list"),
            "required" : ""
        }
        attr["multiple"] = "multiple" if !(instr.selectedSize[0] == 1 && instr.selectedSize[1] == 1)
        @DG.n parentDomGen, 'select', attr, ->
            for idx in instr.data
                @d.n this, 'option', { 'value' : idx }, ->
                    @d.t this, idx

    pBool: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "bool"),
            "type" : "checkbox"
        }
        @DG.n parentDomGen, 'input', attr

    pText: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "text"),
            "cols" : "30",
            "rows" : 4
        }
        attr['required'] = "" if !instr.allowEmpty
        attr['maxlength'] = instr.range[1] if instr.range
        @DG.n parentDomGen, 'textarea', attr

    pColor: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref"
            "id" : @uid(group, name, "color")
            "type" : "color"
        }
        @DG.n parentDomGen, 'input', attr

    pEmail: (parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref"
            "id" : @uid(group, name, "email")
            "type" : "email"
        }
        attr['required'] = "" if !instr.allowEmpty
        @DG.n parentDomGen, 'input', attr

    # Common ground for datetime/date/week/time
    pAbstractDate: (type, parentDomGen, group, name, instr) ->
        attr = {
            "class" : "pref"
            "id" : @uid(group, name, type)
            "type" : type
        }
        attr['required'] = "" if !instr.allowEmpty
        [attr['min'], attr['max']] = instr.range if instr.range
        @DG.n parentDomGen, 'input', attr

    pDatetime: (parentDomGen, group, name, instr) ->
        @pAbstractDate 'datetime', parentDomGen, group, name, instr

    pDate: (parentDomGen, group, name, instr) ->
        @pAbstractDate 'date', parentDomGen, group, name, instr

    pWeek: (parentDomGen, group, name, instr) ->
        @pAbstractDate 'week', parentDomGen, group, name, instr

    pTime: (parentDomGen, group, name, instr) ->
        @pAbstractDate 'time', parentDomGen, group, name, instr
