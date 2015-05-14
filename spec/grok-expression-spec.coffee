
GrokExpression = require '../lib/grok-expression'

describe 'GrokExpression suite', ->
  [grokExpression] = []

  describe 'when given no placeholders', ->

    beforeEach ->
      grokExpression = new GrokExpression('key=\\d+')

    it 'should have no placeholders', ->
      expect(grokExpression.hasPlaceholders()).toBeFalsy()
      expect(grokExpression.reOverallPattern).toEqual 'key=\\d+'

    it 'should match and be trimmed', ->
      result = grokExpression.exec('prefix key=5 postfix')
      expect(result.matched).toBeTruthy()
      expect(result.trimmedAs).toEqual 'key=5'

  describe 'when given a placeholder', ->
    beforeEach ->
      grokExpression = new GrokExpression('level=%{level}, direction=')

    it 'should have placeholders', ->
      expect(grokExpression.hasPlaceholders()).toBeTruthy()
      expect(grokExpression.getPlaceholderNames()).toEqual ['level']

    it 'should trim and extract', ->
      result = grokExpression.exec('prefix: level=info, direction=up')
      expect(result.matched).toBeTruthy()
      expect(result.trimmedAs).toEqual 'level=info, direction='
      expect(result.values.level).toEqual 'info'

  describe 'when given more than one placeholder', ->
    beforeEach ->
      grokExpression = new GrokExpression('level=%{level}, direction=%{direction}$')

    it 'should have placeholders', ->
      expect(grokExpression.hasPlaceholders()).toBeTruthy()
      expect(grokExpression.getPlaceholderNames()).toEqual ['level','direction']

    it 'should trim and extract', ->
      result = grokExpression.exec('prefix: level=info, direction=up')
      expect(result.matched).toBeTruthy()
      expect(result.trimmedAs).toEqual 'level=info, direction=up'
      expect(result.values.level).toEqual 'info'
      expect(result.values.direction).toEqual 'up'

    it 'should be fine with not matching', ->
      result = grokExpression.exec('prefix: time=later')
      expect(result.matched).toBeFalsy()
