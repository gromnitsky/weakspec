# Pref DOM elements (PE): live in groups (GOE). Every GOE have at least 1
# PE.
# 
# Control DOM elements (CE):
#
#   default button       -- corresponds to 1 PE
#   help link            -- corresponds to 1 PE
#   save & reset buttons -- belongs to GOE
#
# DB -- an Opera widget's preferences database.

class EPref

    # ws -- WeakSpec object
    constructor: (@ws) ->
        @spec = ws.spec
        # Opera DB
        @storage = new ExtStorage()

        for group, prefs of @spec
            for name, instr of prefs
                if !(@storage.get group, name)
                    @storage.set group, name, instr.default
                else
                    # if DB contains invalid value (not conforming to
                    # @spec), delete it and use the default from the @spec.
                    if !@ws.validate group, name, @storage.get(group, name)
                        console.warn "#{group}->#{name}: invalid value '#{@storage.get(group, name)}'; reverting to default"
                        @storage.set group, name, instr.default
    
        # update DOM to current preferences values
        e = document.querySelectorAll '[class="pref"]'
        @setElement idx, @e2db idx for idx in e

    # element -- DOM node
    setElement: (element, value) ->
        # we don't validate value because we rely on a html5 browser
        # validation; it should be safe, because the spec cannot contain
        # invalid values & initial validation of the DB is done in the
        # constructor.
        if (@_mapping @e2spec(element).type)(element, 1, value)
            [group, name, eClass] = uidParse element
            console.log "set #{group}->#{name} to '#{value}'"
            true
        else
            false

    # element -- DOM node
    getElementValue: (element) ->
        (@_mapping @e2spec(element).type)(element)

    # Save current value of element into DB
    # 
    # element -- DOM node
    saveElementValue: (element) ->
        [group, name, eClass] = uidParse element
        @storage.set group, name, @getElementValue(element)
        console.log "SAVED #{group}->#{name}"

    # A signature for each method in the map:
    #
    #   foo(element, operation, value = null)
    #
    # where element is a DOM node; operation is a boolean: 0 for
    # reading, 1 for setting a value. Returns the value if operation ==
    # 1 or null on error.
    _mapping: (type) ->
        {
            'char*' : @peStringCallback,
            'int' : @peIntCallback,
            'list' : @peListCallback,
            'bool' : @peBoolCallback
        }[type] || throw new Error "no mapping method for type '#{type}'"

    peStringCallback: (element, operation, value) ->
        return null if !element
        
        return element.value if !operation
        element.value = value
        true

    peIntCallback: (element, operation, value) =>
        @peStringCallback element, operation, value

    peListCallback: (element, operation, value) =>
        return null if !element
        
        if !operation # get
            return element.value if element.type == 'select-one'
            # Return an array of selected options for HTML select. We
            # are not using 'new' selectedOptions() due to its brain
            # dead behaviour in 11.64.
            (idx.value for idx in element.options when idx.selected)
        else # set
            if element.type == 'select-one'
                element.value = value
                return true

            # clean all selection
            element.selectedIndex = -1
            # make new
            idx.selected = true for idx in element.options when idx.text in value
            true

    peBoolCallback: (element, operation, value) ->
        return null if !element
        
        return element.checked if !operation
        element.checked = value
        true

    # Return a spec (a hash) for the particular PE (CE that corresponds
    # to PE will fit too).
    #
    # element -- DOM node
    e2spec: (element) ->
        [group, name, eClass] = uidParse element
        @spec[group][name]


    # Return a current value for a PE from the DB
    #
    # element -- DOM node
    e2db: (element) ->
        [group, name, eClass] = uidParse element
        @storage.get group, name

    # Return a PE to which the CE corresponds to.
    #
    # element -- DOM node
    control2e: (element) ->
        type = @e2spec(element).type
        [group, name, eClass] = uidParse element
        uid =  @ws.drw.uid(group, name, type)
        document.querySelector "[id='#{uid}']"

    # Return all PEs of the GOE that the element belongs to.
    #
    # element -- DOM node
    e2groupElements: (element) ->
        gid = @ws.drw.uid2groupUid element.id
        document.querySelectorAll "[id='#{gid}'] [class='pref']"

errx = (msg) ->
    insertHtml "<b>Error:</b> #{msg}"
    alert "Error: #{msg}"

insertHtml = (html) ->
    document.querySelector('div[id="preferences"]').innerHTML = html

# element -- DOM node
uidParse = (element) ->
    throw new Error "no uid on #{element.tagName}" unless uid = element.id
    uid.split('|')

# pref -- EPref object
mybind = (pref) ->
    # help buttons
    e = document.querySelectorAll '[class="bHelp"]'
    for idx in e
        idx.addEventListener 'mouseover', ->
            bHelpCallback pref, this
        , false
        idx.onclick = -> false

    # default buttons
    e = document.querySelectorAll '[class="bDefault"]'
    for idx in e
        idx.addEventListener 'click', ->
            bDefaultCallback pref, this
        , false

    # form submition & reset
    e = document.querySelectorAll 'form'
    for idx in e
        idx.addEventListener 'submit', (event) ->
            bSubmitCallback pref, this, event
        , false
        idx.addEventListener 'reset', (event) ->
            bResetCallback pref, this, event
        , false

    # save button
    (document.querySelector "[id='save']").addEventListener 'click', ->
        return unless confirm "Are you sure?"

        e = document.querySelectorAll "form input[type='submit']"
        idx.click() for idx in e
    , false

    # reset button
    (document.querySelector "[id='reset']").addEventListener 'click', ->
        return unless confirm "Are you sure?"

        e = document.querySelectorAll "form"
        idx.reset() for idx in e
    , false

    # clean button
    (document.querySelector "[id='clean']").addEventListener 'click', ->
        return unless confirm "This will delete all preferences for this " +
        "extension from Opera. After that it'll be the same as if you have " +
        "installed this extension for the first time.\n\n" +
        "Are you sure?"

        pref.storage.clean()
        
        document.querySelector('[id="menu"]').hidden = true
        document.querySelector('[id="controls"]').hidden = true
        insertHtml "You've deleted any preferences for this extension.<br/>
        <b>Please close this window.</b>"
    , false

    # dump button
    (document.querySelector "[id='dump']").addEventListener 'click', ->
        console.log pref.storage.raw()
    , false

bHelpCallback = (pref, anchor) ->
    anchor.title = pref.e2spec(anchor).help ? "Huh?"

bDefaultCallback = (pref, button) ->
    pref.setElement pref.control2e(button), pref.e2spec(button).default

bSubmitCallback = (pref, form, event) ->
    return unless form.checkValidity()

    console.log 'SUBMIT'
    event?.preventDefault()
    e = pref.e2groupElements form
    pref.saveElementValue idx for idx in e

bResetCallback = (pref, form, event) ->
    console.log 'RESET'
    event.preventDefault()
    e = pref.e2groupElements form
    pref.setElement idx, pref.e2db idx for idx in e


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
    
    pref = new EPref ws
    mybind pref