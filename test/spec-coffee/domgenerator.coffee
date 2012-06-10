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
        
    it 'must create p', ->
        @p1 = @DG.n null, 'p', { 'class' : '>"', 'id' : 'p1' }
        @p1.insaf @root
        (expect 'P').toEqual document.getElementById('root').childNodes[0].tagName
        
    it 'must populate dom', ->
        @p1 = @DG.n null, 'p', { 'class' : '>"', 'id' : 'p1' }

        div1 = @DG.n @p1, 'div', {"id" : "d1"}, ->
            @d.n this, 'span', {"id" : "span1"}, ->
                @d.n this, 'span', {"id" : "span2"}, ->
                    @d.t this, "text 1"
                    @d.t this, "text 2"

        div2 = @DG.n @p1, 'div', {"id" : "d2"}

        @p1.insaf @root

        (expect @p1.node).toEqual document.getElementById('d1').parentNode
        (expect 'SPAN').toEqual document.getElementById('span1').childNodes[0].tagName
        (expect 2).toEqual document.getElementById('span2').childNodes.length
        (expect @p1.node).toEqual document.getElementById('d2').parentNode
