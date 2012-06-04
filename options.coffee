class EPref
    constructor: (@ws) ->
        @spec = ws.spec
        # A hash with user's preferences.
        @db = widget?.preferences || {}

        for group, prefs of @spec
            @db[group] = {} if !@db[group]
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
            @setValue idx, @db[group][name]

    setValue: (element, value) ->
        [group, name, eClass] = uidParse element
        if !@ws.validate group, name, value
            console.error "set #{group}->#{name}: invalid value '#{value}'"
            return
        console.log "set #{group}->#{name} to '#{value}'"
        

    # Transform uid to a hash with a particular preference node in @spec.
    uid2dbNode: (element) ->
        [group, name, eClass] = uidParse element
        @spec[group][name]
        

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

bHelpCallback = (pref, element) ->
    element.title = pref.uid2dbNode(element).help ? "Huh?"


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