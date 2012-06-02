drw = if module then module.exports else window

class drw.Drawer
    # spec must be validated with Pref* by WeakSpec
    constructor: (@spec) ->
        throw new Error 'no valid spec' unless @spec && @size() > 1
            
    size: ->
        n = 0
        n++ for k of @spec
        n
        
    draw: ->
        html = ''
        for group, opts of @spec
            html += "<fieldset id='#{@uid(group, "", "group")}' class='cut'>\n" +
            "<legend>#{group}<legend>\n"
            
            (html += @generatePref group, name, instr) for name, instr of opts
            
            html += "<div>\n"+
            "<button id='#{@uid(group, "", "bReset")}'>Reset</button>\n" +
            "<button id='#{@uid(group, "", "bSave")}'>Save</button>\n" +
            "</div>\n" +
            "</fieldset>\n\n"
        html

    uid: (group, name, type) ->
        switch type
            when 'group' then "#{group}|#{name}|group"
            when 'bReset' then "#{group}|#{name}|bReset"
            when 'bSave' then "#{group}|#{name}|bSave"
            when 'bHelp' then "#{group}|#{name}|bHelp"
            when 'bDefault' then "#{group}|#{name}|bDefault"
            
            when 'char*' then "#{group}|#{name}|pString"
            when 'int' then "#{group}|#{name}|pInt"
            when 'char**' then "#{group}|#{name}|pArrayOfString"
            when 'int**' then "#{group}|#{name}|pArrayOfInt"
            when 'bool' then "#{group}|#{name}|pBool"
            else
                new Error "invalid uid type '#{type}'"

    generatePref: (group, name, instr) ->
        throw new Error "no type" unless instr.type

        mapping = {
            'char*' : @pString,
            'int' : @pInteger,
            'char**' : @pArrayOfString,
            'int**' : @pArrayOfInt,
            'bool' : @pBool
        }

        throw new Error "invalid type '#{instr.type}'" unless mapping[instr.type]
        mapping[instr.type](group, name, instr)

    pString: (group, name, instr) ->
        'string'

    pInteger: (group, name, instr) ->
        'int'

    pArrayOfString: (group, name, instr) ->
        'aos'

    pArrayOfInt: (group, name, instr) ->
        'aoi'

    pBool: (group, name, instr) ->
        'bool'
