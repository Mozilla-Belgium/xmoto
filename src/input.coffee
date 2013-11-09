class Input

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  init: ->
    @disable_scroll()
    @init_keyboard()

  disable_scroll: ->
    # Disable up, down, left, right to scroll
    # left: 37, up: 38, right: 39, down: 40, spacebar: 32, pageup: 33, pagedown: 34, end: 35, home: 36
    keys = [37, 38, 39, 40, 32]

    preventDefault = (e) ->
      e = e || window.event
      if e.preventDefault
        e.preventDefault()
      e.returnValue = false

    keydown = (e) ->
      for i in keys
        if e.keyCode == i
          preventDefault(e)
          return

    document.onkeydown = keydown

  init_keyboard: ->
    window.addEventListener('deviceorientation', (event) =>
      #alert()
      if event.beta > 12
        @left = true
        @right = false
        @value = Math.min(event.beta, 80)
      else if event.beta < -12 and event.beta > -80
        @right = true
        @left = false
        @value = Math.max(event.beta, -80)
      else
        @right = false
        @left = false
#
      #if event.gamma > 50
      #  @down = true
      #else if event.gamma < 30
      #  @up = true
    )

    $("#left").on("touchstart", =>
      @up = true
    )
    $("#left").on("touchend", =>
      @up = false
    )

    $("#right").on("touchstart", =>
      @down = true
    )
    $("#right").on("touchend", =>
      @down = false
    )

    $("#debug").on("touchstart", =>
      @level.restart()
    )

    $(document).off('keydown')
    $(document).on('keydown', (event) =>
      switch(event.which || event.keyCode)
        when 38
          @up = true
        when 40
          @down = true
        when 37
          @left = true
        when 39
          @right = true
        when 13
          @level.restart()
        when 32
          @level.flip_moto() if not @level.moto.dead
    )

    $(document).on('keyup', (event) =>
      switch(event.which || event.keyCode)
        when 38
          @up = false
        when 40
          @down = false
        when 37
          @left = false
        when 39
          @right = false
    )

  move_moto: ->
    force = 24.1
    moto  = @level.moto
    rider = moto.rider

    if not @level.moto.dead
      # Accelerate
      if @up
        moto.left_wheel.ApplyTorque(- moto.mirror * force/3)

      # Brakes
      if @down
        # block right wheel velocity
        v_r = moto.right_wheel.GetAngularVelocity()
        moto.right_wheel.ApplyTorque((if Math.abs(v_r) >= 0.001 then -2*v_r))

        # block left wheel velocity
        v_l = moto.left_wheel.GetAngularVelocity()
        moto.left_wheel.ApplyTorque((if Math.abs(v_l) >= 0.001 then -v_l))

      # Back wheeling
      if @left
        if @value
          moto.body.ApplyTorque(@value/2.8)
          moto.rider.torso.ApplyTorque(@value/2.8)
        else
          moto.body.ApplyTorque(force/3.0)
          moto.rider.torso.ApplyTorque(force/3.0)

      # Front wheeling
      if @right
        if @value
          moto.body.ApplyTorque(@value/2.8)
          moto.rider.torso.ApplyTorque(@value/2.8)
        else
          moto.body.ApplyTorque(-force/3.0)
          moto.rider.torso.ApplyTorque(-force/3.0)

    if not @up and not @down
      # Engine brake
      v = moto.left_wheel.GetAngularVelocity()
      @level.moto.left_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/10))

      # Friction on right wheel
      v = moto.right_wheel.GetAngularVelocity()
      @level.moto.right_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/100))

    # Left wheel suspension
    moto.left_prismatic_joint.SetMaxMotorForce(8+Math.abs(800*Math.pow(moto.left_prismatic_joint.GetJointTranslation(), 2)))
    moto.left_prismatic_joint.SetMotorSpeed(-3*moto.left_prismatic_joint.GetJointTranslation())

    # Right wheel suspension
    moto.right_prismatic_joint.SetMaxMotorForce(4+Math.abs(800*Math.pow(moto.right_prismatic_joint.GetJointTranslation(), 2)))
    moto.right_prismatic_joint.SetMotorSpeed(-3*moto.right_prismatic_joint.GetJointTranslation())

    # No more articulation feedback, gravity does its job !

    #articulations = [ rider.ankle_joint, rider.wrist_joint, rider.knee_joint,
    #                  rider.elbow_joint, rider.shoulder_joint, rider.hip_joint ]
    #
    ## Articulations of the rider ("suspension")
    #if not @left and not @right
    #  for articulation in articulations
    #    angle = articulation.GetJointAngle()
    #    articulation.SetMaxMotorTorque(angle/2)
    #    articulation.SetMotorSpeed(angle/2)
    #
