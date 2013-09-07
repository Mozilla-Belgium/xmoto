class Level

  constructor: ->
    # Context
    canvas  = $('#game').get(0)
    @ctx = canvas.getContext('2d')

    # Assets manager
    @assets        = new Assets()

    # Box2D World
    @physics       = new Physics(this)
    @world         = @physics.world

    # Inputs
    @input         = new Input(this)

    # Moto (level independant)
    @moto          = new Moto(this)

    # Level dependent objects
    @infos         = new Infos(this)
    @sky           = new Sky(this)
    @blocks        = new Blocks(this)
    @limits        = new Limits(this)
    @layer_offsets = new LayerOffsets(this)
    @script        = new Script(this)
    @entities      = new Entities(this)

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "data/Levels/#{file_name}",
      dataType: "xml",
      success:  @load_level
      async:    false
      context:  @
    })

  load_level: (xml) ->
    # Level dependent objects
    @infos        .parse(xml).init()
    @sky          .parse(xml).init()
    @blocks       .parse(xml).init()
    @limits       .parse(xml).init()
    @layer_offsets.parse(xml).init()
    @script       .parse(xml).init()
    @entities     .parse(xml).init()

    # Moto (level independant)
    @moto.init()

  init_canvas: ->
    @canvas  = $('#game').get(0)
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = @canvas.width * (@limits.size.y / @limits.size.x)

    @scale =
      x:   @canvas_width  / @limits.size.x
      y: - @canvas_height / @limits.size.y

    @translate =
      x: - @limits.screen.left
      y: - @limits.screen.top

  init_input: ->
    @input.init()

  display: ->
    @init_canvas() if not @canvas

    $('#game').attr('height', @canvas_height)

    @ctx.scale(@scale.x, @scale.y)
    @ctx.translate(@translate.x, @translate.y)

    @ctx.lineWidth = 0.01

    @sky     .display(@ctx)
    @limits  .display(@ctx)
    @blocks  .display(@ctx)
    @entities.display(@ctx)
    @moto    .display(@ctx)
