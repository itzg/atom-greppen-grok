
module.exports =
class GrokExpression

  placeholders: []
  reOverall: undefined

  constructor: (pattern) ->
    rePlaceholders = /%{(.+?)}/g

    @placeholders = while placeholderMatch = rePlaceholders.exec(pattern)
      new GrokPlaceholder(placeholderMatch[1])

    @reOverallPattern = pattern.replace(/%{.+?}/g, '(.+?)')

  hasPlaceholders: ->
    @placeholders.length > 0

  getPlaceholderNames: ->
    (p.name for p in @placeholders)

  exec: (str) ->
    re = new RegExp(@reOverallPattern, 'g')
    match = re.exec(str)

    return {matched: false} if match == null

    response =
      matched: true
      trimmedAs: match[0]

    if (@placeholders.length > 0)
      response.values = {}

      for p, i in @placeholders
        response.values[p.name] = match[i+1]

    return response

class GrokPlaceholder

  constructor: (@name) ->
