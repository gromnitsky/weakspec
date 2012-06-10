root = exports ? this

class root.DomGenerator

    constructor: (@parent = null) ->
        @node = null
        @d = root.DomGenerator

    @n: (parent, name, attr, nested) ->
        throw new Error "cannot create a node without a name" unless name
        
        dg = new root.DomGenerator parent
        dg.node = dg.createNode name, attr
        dg.insaf parent?.node

        nested.call dg if nested
        
        dg

    @t: (parent, string) ->
        throw new Error "cannot create a text without a string" unless string

        dg = new root.DomGenerator parent
        dg.node = dg.createText string
        dg.insaf parent?.node
        dg

    # return a DOM element
    createNode: (name, attr) ->
        node = document.createElement name
        node.setAttribute(k, v) for k,v of attr
        node

    # return a DOM element
    createText: (string) ->
        document.createTextNode string

    # parentNode -- a DOM element
    insaf: (parentNode) ->
        return unless parentNode
        
        parentNode.appendChild @node
        @parent = parentNode
