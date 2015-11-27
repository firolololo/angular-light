
Test('fast-binding 0', 'fast-binding-0').run ($test, alight) ->
    $test.start 10

    el = document.createElement 'div'
    el.innerHTML = '''
        root={{rootValue}}
        <span attr0="a{{attr0}}" attr1="value1" attr2="{{attr2}}a">child0={{child0}}</span>
        <span>no bind</span>
        <span attr3="a{{attr3}}a">{{child2}}-from-child</span>
    '''

    getText = ->
        el.innerText.trim().replace /[\s\n]/ig, ' '

    cd = alight.ChangeDetector
        rootValue: 'unix'
        child0: 'linux'
        child2: 'ubuntu'
        attr0: '000'
        attr2: '222'
        attr3: '333'

    fb = new alight.core.fastBinding el
    fb.bind cd, el

    $test.equal getText(), 'root=unix child0=linux no bind ubuntu-from-child'
    $test.equal el.childNodes[1].attributes.attr0.value, 'a000'
    $test.equal el.childNodes[1].attributes.attr1.value, 'value1'
    $test.equal el.childNodes[1].attributes.attr2.value, '222a'
    $test.equal el.childNodes[5].attributes.attr3.value, 'a333a'

    cd.scope.rootValue = 'new one'
    cd.scope.child2 = 'second'
    cd.scope.attr0 = 'first'
    cd.scope.attr2 = 'second'
    cd.scope.attr3 = 'third'
    cd.scan ->

        $test.equal getText(), 'root=new one child0=linux no bind second-from-child'
        $test.equal el.childNodes[1].attributes.attr0.value, 'afirst'
        $test.equal el.childNodes[1].attributes.attr1.value, 'value1'
        $test.equal el.childNodes[1].attributes.attr2.value, 'seconda'
        $test.equal el.childNodes[5].attributes.attr3.value, 'athirda'
        $test.close()


Test('fast-binding-1').run ($test, alight) ->
    $test.start 2

    el = ttDOM """
        <div al-repeat="it in list">
            <i>a-{{it.name}}</i>
            <i>b-{{foo(it.value)}}</i>
            <i>c-{{it.value | double}}</i>
            <i>d-{{=it.name}}</i>
            <i>e-{{#dd it.name}}</i>
        </div>
    """

    alight.filters.double = ->
        (x) ->
            x*2

    alight.text.dd = (callback, expression, cd, env) ->
        value = cd.eval expression
        env.setter value+value

    cd = alight.ChangeDetector
        list: [
            {name: 'l', value: 5}
            {name: 'u', value: 7}
            {name: 'd', value: 11}
        ]
        foo: (x) ->
            x*2

    alight.bind cd, el

    $test.equal ttGetText(el), 'a-l b-10 c-10 d-l e-ll ' + 'a-u b-14 c-14 d-u e-uu ' + 'a-d b-22 c-22 d-d e-dd'
    
    cd.scope.list[1] =
        name: 'x'
        value: 3
    cd.scan()
    $test.equal ttGetText(el), 'a-l b-10 c-10 d-l e-ll ' + 'a-x b-6 c-6 d-x e-xx ' + 'a-d b-22 c-22 d-d e-dd'

    $test.close()
