class EPref

    constructor: (@ws) ->
        @spec = ws.spec
        # a hash with user's preferences
        @db = widget?.preferences || {}

        for group, prefs of @spec
            @db[group] ||= {}
            for name, instr of prefs
                if !@db[group][name]
                    @db[group][name] = instr.default
                else
                    # if @db contains invalid value (not conforming to
                    # @spec), delete it and use the default from the @spec.
                    if !@ws.validate group, name, @db[group][name]
                        console.warn "#{group}->#{name}: invalid value '#{@db[group][name]}'; reverting to default"
                        @db[group][name] = instr.default

        # update DOM to current preferences values
        e = document.querySelectorAll '[class="pref"]'
        for idx in e
            [group, name, eClass] = uidParse idx
            @setElement idx, @db[group][name]

    setElement: (element, value) ->
        [group, name, eClass] = uidParse element
        if !@ws.validate group, name, value
            console.error "set #{group}->#{name}: invalid value '#{value}'"
            return
            
        if (@_mapping @e2node(element).type)(element, 1, value)
            console.log "set #{group}->#{name} to '#{value}'"

    getElementValue: (element) ->
        (@_mapping @e2node(element).type)(element)

    # A signature for each method in the map:
    #
    #   foo(element, operation, value = null)
    #
    # where operation is a boolean: 0 for reading, 1 for setting a
    # value. Returns the value if operation == 1 or null on error.
    _mapping: (type) ->
        {
            'char*' : @pString,
            'int' : @pInt,
            'list' : @pList,
            'bool' : @pBool
        }[type] || throw new Error "no mapping method for type '#{type}'"

    pString: (element, operation, value) ->
        return null if !element
        
        return element.value if !operation
        element.value = value
        true

    pInt: (element, operation, value) =>
        @pString element, operation, value

    pList: (element, operation, value) =>
        return null if !element
        
        if !operation # get
            return element.value if element.type == 'select-one'
            return (idx.value for idx in element.selectedOptions)
        else # set
            if element.type == 'select-one'
                element.value = value
                return true

            # clean all selection
            element.selectedIndex = -1
            # make new
            idx.selected = true for idx in element.options when idx.text in value
            true

    pBool: (element, operation, value) ->
        return null if !element
        
        return element.checked if !operation
        element.checked = value
        true

    # Transform uid to a hash with a particular preference node in @spec.
    e2node: (element) ->
        [group, name, eClass] = uidParse element
        @spec[group][name]

    control2e: (element) ->
        type = @e2node(element).type
        [group, name, eClass] = uidParse element
        uid =  @ws.drw.uid(group, name, type)
        document.querySelector "[id='#{uid}']"

errx = (msg) ->
    insertHtml "<b>Error:</b> #{msg}"
    alert "Error: #{msg}"

insertHtml = (html) ->
    document.querySelector('div[id="preferences"]').innerHTML = html

uidParse = (element) ->
    throw new Error "no uid on #{element.tagName}" unless uid = element.id
    uid.split('|')

mybind = (pref) ->
    # help buttons
    e = document.querySelectorAll '[class="bHelp"]'
    for idx in e
        idx.addEventListener 'mouseover', ->
            bHelpCallback(pref, this)
        , false
        idx.onclick = -> false

    # default buttons
    e = document.querySelectorAll '[class="bDefault"]'
    for idx in e
        idx.addEventListener 'click', ->
            bDefaultCallback(pref, this)
        , false

bHelpCallback = (pref, anchor) ->
    anchor.title = pref.e2node(anchor).help ? "Huh?"

bDefaultCallback = (pref, button) ->
    pref.setElement pref.control2e(button), pref.e2node(button).default

# main
window.onload = ->
    if typeof weakspec == 'undefined' || weakspec == null
        errx "File 'options.weakspec.js' not loaded"
        return
        
    try
        ws = new WeakSpec weakspec
    catch e
        errx "in spec: #{e.message}"
        return

    insertHtml ws.toHtml()
    document.querySelector('[id="searchbox"] input').focus()
    
    pref = new EPref ws
    mybind pref