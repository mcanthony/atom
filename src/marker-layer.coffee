Marker = require './marker'

module.exports =
class MarkerLayer
  constructor: (displayBuffer, bufferMarkerLayer) ->
    @displayBuffer = displayBuffer
    @bufferMarkerLayer = bufferMarkerLayer
    @markers = {}

  markScreenRange: (range, options) ->
    bufferRange = @bufferRangeForScreenRange(range)
    @markBufferRange(bufferRange, options)

  markBufferRange: (range, options) ->
    @getMarker(@bufferMarkerLayer.markRange(range, options).id)

  markScreenPosition: (screenPosition, options) ->
    @markBufferPosition(@bufferPositionForScreenPosition(screenPosition), options)

  markBufferPosition: (bufferPosition, options) ->
    @getMarker(@bufferMarkerLayer.markPosition(bufferPosition, options).id)

  destroyMarker: (id) ->
    @bufferMarkerLayer.destroyMarker(id)
    delete @markers[id]

  findMarkers: (params) ->
    params = @translateToBufferMarkerParams(params)
    @bufferMarkerLayer.findMarkers(params).map (bufferMarker) => @getMarker(bufferMarker.id)

  getMarker: (id) ->
    marker = @markers[id]
    unless marker
      if bufferMarker = @bufferMarkerLayer.getMarker(id)
        marker = new Marker(bufferMarker, this)
        @markers[id] = marker
    marker

  getMarkers: ->
    @bufferMarkerLayer.getMarkers().map (bufferMarker) =>
      @getMarker(bufferMarker)

  findMarkers: (params) ->
    params = translateToBufferMarkerParams(params, @displayBuffer)
    @bufferMarkerLayer.findMarkers(params).map (bufferMarker) =>
      @getMarker(bufferMarker.id)

  translateToBufferMarkerParams: (params) ->
    bufferMarkerParams = {}
    for key of params
      value = params[key]
      switch (key)
        when 'startBufferRow'
          key = 'startRow'
        when 'endBufferRow'
          key = 'endRow'
        when 'startScreenRow'
          key = 'startRow'
          value = @bufferRowForScreenRow(value)
        when 'endScreenRow'
          key = 'endRow'
          value = @bufferRowForScreenRow(value)
        when 'intersectsBufferRowRange'
          key = 'intersectsRowRange'
        when 'intersectsScreenRowRange'
          key = 'intersectsRowRange'
          value[0] = @bufferRowForScreenRow(value[0])
          value[1] = @bufferRowForScreenRow(value[1])
        when 'containsBufferRange'
          key = 'containsRange'
        when 'containsBufferPosition'
          key = 'containsPosition'
        when 'containedInBufferRange'
          key = 'containedInRange'
        when 'containedInScreenRange'
          key = 'containedInRange'
          value = @bufferRangeForScreenRange(value)
        when 'intersectsBufferRange'
          key = 'intersectsRange'
        when 'intersectsScreenRange'
          key = 'intersectsRange'
          value = @bufferRangeForScreenRange(value)
      bufferMarkerParams[key] = value
    bufferMarkerParams

  bufferRowForScreenRow: (row) -> displayBuffer.bufferRowForScreenRow(row)
  screenRowForBufferRow: (row) -> displayBuffer.screenRowForBufferRow(row)
  bufferRangeForScreenRange: (range) -> displayBuffer.bufferRangeForScreenRange(range)
  screenRangeForBufferRange: (range) -> displayBuffer.screenRangeForBufferRange(range)
  bufferPositionForScreenPosition: (position) -> displayBuffer.bufferPositionForScreenPosition(position)
  screenPositionForBufferPosition: (position) -> displayBuffer.screenPositionForBufferPosition(position)
