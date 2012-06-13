# An DB abstraction layer upon Opera widget.preferences object.
# See also http://www.w3.org/TR/webstorage/#the-storage-interface

root = exports ? this

class root.ExtStorage

    constructor: ->
        @db = widget?.preferences || {}

    raw: ->
        @db
    
    _getGroup: (group) ->
        try
            g = JSON.parse @db[group]
        catch e
            return {}
        g || {}
                        
    get: (group, name) ->
        g = @_getGroup group
        if g[name] == undefined then null else g[name]

    set: (group, name, value) ->
        g = @_getGroup group
        g[name] = value
        @db[group] = JSON.stringify g

    clean: ->
        if widget?
            @db.clear()
        else
            delete @db[k] for k,v of @db

    size: ->
        (Object.keys @db).length

    # Doesn't work outside of Opera extensions.
    @Get: (group, name) ->
        (new root.ExtStorage()).get group, name

    # Doesn't work outside of Opera extensions.
    @Set: (group, name, value) ->
        (new root.ExtStorage()).set group, name, value
        
