
GrokExpression = require '../lib/grok-expression'

describe 'GrokExpression suite', ->
  [grokExpression] = []

  describe 'when given no placeholders', ->

    beforeEach ->
      grokExpression = new GrokExpression('key=\\d+')

    it 'should have no placeholders', ->
      expect(grokExpression.placeholders).toEqual []
      expect(grokExpression.reOverallPattern).toEqual 'key=\\d+'

    it 'should match and be trimmed', ->
      result = grokExpression.exec('prefix key=5 postfix')
      expect(result.matched).toBeTruthy()
      expect(result.trimmedAs).toEqual 'key=5'

  describe 'when given a placeholder', ->
    beforeEach ->
      grokExpression = new GrokExpression('level=%{level}, direction=')

    it 'should have placeholders', ->
      expect(grokExpression.placeholders.length).toEqual 1

    it 'should trim still', ->
      result = grokExpression.exec('prefix: level=info, direction=up')
      expect(result.matched).toBeTruthy()
      expect(result.trimmedAs).toEqual 'level=info, direction='
      expect(result.values.level).toEqual 'info'
