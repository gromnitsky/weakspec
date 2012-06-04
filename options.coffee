# A hash with user's preferences.
WeakSpec.pref = widget?.preferences || {}

errx = (msg) ->
    insertHtml "<b>Error:</b> #{msg}"
    alert "Error: #{msg}"

insertHtml = (html) ->
    document.querySelector('div[id="preferences"]').innerHTML = html

# Transform uid to a hash with a particular preference node in weakspec.
uid2weakspecNode = (element) ->
    throw new Error 'no uid on #{element.tagName}' unless uid = element.id
    [group, name, eClass] = uid.split('|')
    weakspec[group][name]

mybind = ->
    # help buttons
    e = document.querySelectorAll '[class="bHelp"]'
    for idx in e
        idx.addEventListener 'mouseover', bHelpCallback, false
        idx.onclick = -> false

bHelpCallback = ->
    this.title = uid2weakspecNode(this).help ? "Huh?"

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
    mybind()