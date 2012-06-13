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

    # Save current value of the element to DB
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
            'string' : @peStringCallback
            'number' : @peStringCallback # yup
            'list' : @peListCallback
            'bool' : @peBoolCallback
            'text' : @peStringCallback # yup
            'color' : @peStringCallback # yup
            'email' : @peStringCallback # yup
            'datetime' : @peStringCallback # yup
            'date' : @peStringCallback # yup
            'week' : @peStringCallback # yup
            'time' : @peStringCallback # yup
        }[type] || throw new Error "no mapping method for type '#{type}'"

    peStringCallback: (element, operation, value) ->
        return null if !element

        return element.value if !operation
        element.value = value
        true

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

errx = (msg) ->
    insertHtml "<p class='error'><b>Error:</b> #{msg}</p>"

insertHtml = (html) ->
    innerPoint().innerHTML = html

innerPoint = ->
    document.querySelector('div[id="preferences"]')

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

        e = document.querySelectorAll '[class="bDefault"]'
        idx.click() for idx in e
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
        insertHtml "<p class='error'>
        You've deleted any preferences for this extension.<br/><br/>
        Please close this window.</p>
        <p>
        <img class='right' alt='A malcontent frog' src='data:image/png;base64,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'>
        </p>"
    , false

    # dump button
    (document.querySelector "[id='dump']").addEventListener 'click', ->
        console.log pref.storage.raw()
    , false

bHelpCallback = (pref, anchor) ->
    anchor.title = pref.e2spec(anchor).help ? "Huh?"

bDefaultCallback = (pref, button) ->
    console.log 'DEFAULT'
    pref.setElement pref.control2e(button), pref.e2spec(button).default

bSubmitCallback = (pref, form, event) ->
    return unless form.checkValidity()

    console.log 'SUBMIT'
    event?.preventDefault()
    e = form.querySelectorAll "[class='pref']"
    pref.saveElementValue idx for idx in e

bResetCallback = (pref, form, event) ->
    console.log 'RESET'
    event.preventDefault()
    e = form.querySelectorAll "[class='pref']"
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

    insertHtml ''
    innerPoint().appendChild idx for idx in ws.toDomElements()

    pref = new EPref ws
    mybind pref
