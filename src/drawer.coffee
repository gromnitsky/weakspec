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
            form = @DG.n grp, 'form', { 'id' : o.uid(group, '', 'group') }, ->
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
        switch type
            when 'group' then "#{group}|#{name}|group"
            when 'bHelp' then "#{group}|#{name}|bHelp"
            when 'bDefault' then "#{group}|#{name}|bDefault"

            when 'string' then "#{group}|#{name}|pString"
            when 'number' then "#{group}|#{name}|pNumber"
            when 'list' then "#{group}|#{name}|pList"
            when 'bool' then "#{group}|#{name}|pBool"
            when 'text' then "#{group}|#{name}|pText"
            when 'color' then "#{group}|#{name}|pColor"
            else
                new Error "invalid uid type '#{type}'"

    uid2groupUid: (uid) ->
        return null unless uid
        [group, name, eClass] = uid.trim().split '|'
        return null unless group

        @uid group, name ||= '', 'group'

    generatePref: (parentDomGen, group, name, instr) ->
        throw new Error "no type" unless instr.type

        mapping = {
            'string' : @pString
            'number' : @pNumber
            'list' : @pList
            'bool' : @pBool
            'text' : @pText
            'color' : @pColor
        }

        throw new Error "invalid type '#{instr.type}'" unless mapping[instr.type]
        o = this
        
        @DG.n parentDomGen, 'tr', null, ->
            @d.n this, 'th', null, ->
                @d.t this, instr.desc
            @d.n this, 'td', null, ->
                mapping[instr.type](this, group, name, instr)
            @d.n this, 'td', null, ->
                @d.n this, 'button', { 'type' : 'button', "class" : "bDefault", "id" : o.uid(group, name, "bDefault") }, ->
                    @d.t this, 'Default'
                @d.t this, ' '
                @d.n this, 'a', { "href" : "#", "class" : "bHelp", "id" : o.uid(group, name, "bHelp") }, ->
                    @d.t this, "?"

    pString: (parentDomGen, group, name, instr) =>
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "string")
        }
        attr['pattern'] = instr.validationRegexp if instr.validationRegexp
        attr['required'] = "" if !instr.allowEmpty
        @DG.n parentDomGen, 'input', attr

    pNumber: (parentDomGen, group, name, instr) =>
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "number"),
            "required" : "",
            "type" : "number"
        }
        attr['min'] = instr.range[0] if instr.range
        attr['max'] = instr.range[1] if instr.range
        @DG.n parentDomGen, 'input', attr

    pList: (parentDomGen, group, name, instr) =>
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

    pBool: (parentDomGen, group, name, instr) =>
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "bool"),
            "type" : "checkbox"
        }
        @DG.n parentDomGen, 'input', attr

    pText: (parentDomGen, group, name, instr) =>
        attr = {
            "class" : "pref",
            "id" : @uid(group, name, "text"),
            "cols" : "30",
            "rows" : 4
        }
        attr['required'] = "" if !instr.allowEmpty
        attr['maxlength'] = instr.range[1] if instr.range
        @DG.n parentDomGen, 'textarea', attr

    pColor: (parentDomGen, group, name, instr) =>
        attr = {
            "class" : "pref"
            "id" : @uid(group, name, "color")
            "type" : "color"
        }
        @DG.n parentDomGen, 'input', attr
        