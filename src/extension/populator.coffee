root = exports ? this

es = require?('./extstorage') || root
httpreq = require?("xmlhttprequest")?.XMLHttpRequest || XMLHttpRequest

class root.WeakSpecPopulator

    constructor: (@file) ->
        # Opera DB
        @storage = new es.ExtStorage()

        @load @read(@file)
        @dbPopulate()

    read: (file) ->
        r = new httpreq()
        r.open "GET", file, false
        r.send null
        r.responseText

    load: (code) ->
        if code.length == 0
            throw new Error "Was '#{@file}' even read?"

        try
            eval code
            @spec = weakspec
        catch e
            throw new Error "#{@file} contains errors: #{e.message}"

    # Set default values in widget.preferences
    dbPopulate: ->
        throw new Error '@spec variable does not contain a weakspec' unless @spec

        for group, prefs of @spec
            for name, instr of prefs
                if (@storage.get group, name) == null
                    @storage.set group, name, instr.default
