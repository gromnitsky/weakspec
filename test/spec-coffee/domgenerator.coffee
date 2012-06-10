describe 'DomGenerator', ->

    beforeEach ->
        body = document.getElementsByTagName("body")[0]

        old_div = document.getElementById('root')
        old_div?.parentNode.removeChild old_div
        
        div = document.createElement("div")
        div.id = 'root'
        @root = body.appendChild div

        @DG = DomGenerator
        @p1?.parentNode.removeChild @p1
        
    # it 'must be a nice tree', ->
    #     start = @dg.parent
        
    #     @dg.n('p', {'class' : '>"', 'id' : 'bro'}, null, ->
    #         @n('span', {'id' : 'bro2'}, null, ->
    #             @n 'span', {'id' : 'bro3'}, null, ->
    #                 @t 'what do you care?'
    #         ).t('ahoi!')
    #     ).t('baloi!', null, ->
    #         @t 'manoi!'
    #     ).n('b').t('do you like it?')
        
    #     @dg.t('I mean, like this?', @dg.parent.parentNode)

    #     bro = document.getElementById 'bro'
    #     (expect '>"').toEqual bro.getAttribute('class')
    #     (expect 'bro').toEqual bro.getAttribute('id')
        
    #     (expect start).toEqual bro.parentNode
    #     (expect 'baloi!').toEqual bro.childNodes[1].textContent
    #     (expect 'manoi!').toEqual bro.childNodes[2].textContent

    #     (expect 'B').toEqual document.getElementById('bro').childNodes[3].tagName
    #     (expect 'do you like it?').toEqual document.getElementById('bro').childNodes[3].childNodes[0].textContent
        
    #     (expect 'I mean, like this?').toEqual bro.childNodes[4].textContent

    it 'must create p', ->
        @p1 = @DG.n null, 'p', { 'class' : '>"', 'id' : 'p1' }
        @p1.insaf @root
        (expect 'P').toEqual document.getElementById('root').childNodes[0].tagName
        
    it 'must populate dom', ->
        @p1 = @DG.n null, 'p', { 'class' : '>"', 'id' : 'p1' }
        @p1.insaf @root

        div1 = @DG.n @p1, 'div', {"id" : "d1"}, ->
            @d.n this, 'span', {"id" : "span1"}, ->
                @d.n this, 'span', {"id" : "span2"}, ->
                    @d.t this, "text 1"
                    @d.t this, "text 2"

        div2 = @DG.n @p1, 'div', {"id" : "d2"}

        (expect @p1.node).toEqual document.getElementById('d1').parentNode
        (expect 'SPAN').toEqual document.getElementById('span1').childNodes[0].tagName
        (expect 2).toEqual document.getElementById('span2').childNodes.length
        (expect @p1.node).toEqual document.getElementById('d2').parentNode
