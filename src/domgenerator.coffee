root = exports ? this

class root.DomGenerator

    constructor: ->
        @nodes = []

    n: (name, attr, child) ->
        html = "<#{name} #{attr}>"
        @nodes.push html
        child.call(this, this) if child
        @nodes.push "</#{name}>"
        
        this

    t: (text, child) ->
        html = text
        @nodes.push html
        child.call(this, this) if child

        this

    toString: ->
        s = ''
        s += idx for idx in @nodes
        s