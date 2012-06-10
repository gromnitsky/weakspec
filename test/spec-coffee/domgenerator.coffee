describe 'DomGenerator', ->

    beforeEach ->
        body = document.getElementsByTagName("body")[0]
        div = document.createElement("div")
        div.id = 'foo'
        div = body.appendChild div

        @dg = new DomGenerator div

    afterEach ->
#        @div.parentNode.removeChild @div

    it 'must be a nice tree', ->
        start = @dg.parent
        
        @dg.n('p', {'class' : '>"', 'id' : 'bro'}, null, ->
            @n('span', {'id' : 'bro2'}, null, ->
                @n 'span', {'id' : 'bro3'}, null, ->
                    @t 'what do you care?'
            ).t('ahoi!')
        ).t('baloi!', null, ->
            @t 'manoi!'
        ).n('b').t('do you like it?')
        
        @dg.t('I mean, like this?', @dg.parent.parentNode)

        bro = document.getElementById 'bro'
        (expect '>"').toEqual bro.getAttribute('class')
        (expect 'bro').toEqual bro.getAttribute('id')
        
        (expect start).toEqual bro.parentNode
        (expect 'baloi!').toEqual bro.childNodes[1].textContent
        (expect 'manoi!').toEqual bro.childNodes[2].textContent

        (expect 'B').toEqual document.getElementById('bro').childNodes[3].tagName
        (expect 'do you like it?').toEqual document.getElementById('bro').childNodes[3].childNodes[0].textContent
        
        (expect 'I mean, like this?').toEqual bro.childNodes[4].textContent
        