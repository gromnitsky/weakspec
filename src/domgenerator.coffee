root = exports ? this

class root.DomGenerator

    constructor: (@parent) ->

    n: (name, attr, parent, childCallback) ->
        node = document.createElement name
        node.setAttribute(k, v) for k,v of attr

        p = if parent then parent else @parent
        p.appendChild node
        @parent = node

        if childCallback
            childCallback.call this
            @parent = node
    
        this

    t: (text, parent, siblingCallback) ->
        node = document.createTextNode text
        p = if parent then parent else @parent
        p.appendChild node
        # no parent nodes possible

        siblingCallback.call this if siblingCallback
        this

