root = exports ? this

class root.Drawer
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
            "<legend>#{group}</legend>\n" +
            "<table>\n"
            
            (html += @generatePref group, name, instr) for name, instr of opts
            
            html += "</table>\n<div>\n"+
            "<button class='bSave' id='#{@uid(group, "", "bSave")}'>Save</button>\n" +
            "<button class='bReset' id='#{@uid(group, "", "bReset")}'>Reset</button>\n" +
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

        html = "<tr>\n" +
        "<th>#{instr.desc}</th>\n" +
        "<td>\n"
        html += mapping[instr.type](group, name, instr)
        html += "</td>\n" +
        "<td>\n" +
        "<button class='bDefault' id='#{@uid(group, name, "bDefault")}'>Default</button>\n" +
        "<a class='bHelp' href='#' id='#{@uid(group, name, "bHelp")}'>?</a>\n" +
        "</td>\n" +
        "</tr>\n"


    pString: (group, name, instr) ->
        'string'

    pInteger: (group, name, instr) ->
        'int'

    pArrayOfString: (group, name, instr) ->
        'aos'

    pArrayOfInt: (group, name, instr) ->
        'aoi'

    pBool: (group, name, instr) =>
        checked = if instr.default then "checked='checked'" else ""
        "<input type='checkbox' #{checked} id='#{@uid(group, name, "bool")}' />\n"
        
