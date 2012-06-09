root = exports ? this

class root.Drawer
    # spec must be validated with Pref* by WeakSpec
    constructor: (@spec) ->
        throw new Error 'no valid spec' unless @spec && @size() > 1
            
    size: ->
        (Object.keys @spec).length
                    
    draw: ->
        html = ''
        for group, opts of @spec
            html += "<fieldset>\n" +
            "<form id='#{@uid(group, "", "group")}'>\n" + 
            "<legend>#{group}</legend>\n" +
            "<table>\n"
            
            (html += @generatePref group, name, instr) for name, instr of opts
            
            html += "</table>\n<div>\n"+
            "<input type='submit' value='Save'>\n" +
            "<input type='reset'>\n" +
            "</div>\n" +
            "</form>\n" +
            "</fieldset>\n\n"
        html

    uid: (group, name, type) ->
        switch type
            when 'group' then "#{group}|#{name}|group"
            when 'bHelp' then "#{group}|#{name}|bHelp"
            when 'bDefault' then "#{group}|#{name}|bDefault"
            
            when 'string' then "#{group}|#{name}|pString"
            when 'number' then "#{group}|#{name}|pNumber"
            when 'list' then "#{group}|#{name}|pList"
            when 'bool' then "#{group}|#{name}|pBool"
            else
                new Error "invalid uid type '#{type}'"

    uid2groupUid: (uid) ->
        return null unless uid
        [group, name, eClass] = uid.trim().split '|'
        return null unless group

        @uid group, name ||= '', 'group'

    generatePref: (group, name, instr) ->
        throw new Error "no type" unless instr.type

        mapping = {
            'string' : @pString,
            'number' : @pNumber,
            'list' : @pList,
            'bool' : @pBool
        }

        throw new Error "invalid type '#{instr.type}'" unless mapping[instr.type]

        html = "<tr>\n" +
        "<th>#{instr.desc}</th>\n" +
        "<td>\n"
        html += mapping[instr.type](group, name, instr)
        html += "</td>\n" +
        "<td>\n" +
        "<button type='button' class='bDefault' id='#{@uid(group, name, "bDefault")}'>Default</button>\n" +
        "<a class='bHelp' href='#' id='#{@uid(group, name, "bHelp")}'>?</a>\n" +
        "</td>\n" +
        "</tr>\n"

    pString: (group, name, instr) =>
        pattern = if instr.validationRegexp then "pattern='#{instr.validationRegexp}'" else ""
        required = if instr.allowEmpty then '' else 'required'
        "<input #{required} class='pref' #{pattern} id='#{@uid(group, name, "string")}'>\n"

    pNumber: (group, name, instr) =>
        min = if instr.range then "min='#{instr.range[0]}'" else ""
        max = if instr.range then  "max='#{instr.range[1]}'" else ""
        "<input required class='pref' type='number' #{min} #{max} id='#{@uid(group, name, "number")}'>\n"

    pList: (group, name, instr) =>
        multiple = if instr.selectedSize[0] == 1 && instr.selectedSize[1] == 1 then "" else "multiple"
        html = "<select required class='pref' #{multiple} id='#{@uid(group, name, "list")}'>"
        html += "<option value='#{idx}'>#{idx}</option>" for idx in instr.data
        html += "</select>"

    pBool: (group, name, instr) =>
        "<input class='pref' type='checkbox' id='#{@uid(group, name, "bool")}'>\n"
        
