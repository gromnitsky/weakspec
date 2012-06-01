drw = if module then module.exports else window

class drw.Drawer
    # spec must be validated with Pref* by WeakSpec
    constructor: (@spec) ->
        throw new Error 'no valid spec' unless @spec && @size > 1
            
    size: ->
        n = 0
        n++ for k of @spec
        n
        
    draw: ->
        ''
