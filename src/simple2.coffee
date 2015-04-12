error = console.log
errFn = error

loadProgram = (gl, shaders, opt_attribs, opt_locations, opt_errorCallback) ->
    errFn = console.log #opt_errorCallback || error;
    program = gl.createProgram();
    for ii in shaders
        gl.attachShader(program, ii);

    if (opt_attribs)
        for ii in opt_attribs
            gl.bindAttribLocation(
                program,
                if opt_locations then opt_locations[ii] else ii,
                opt_attribs[ii]);

    gl.linkProgram(program);

    # Check the link status
    linked = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (!linked)
        # something went wrong with the link
        lastError = gl.getProgramInfoLog (program);
        console.log(lastError)
        #errFn("Error in program linking:" + lastError);
  
        gl.deleteProgram(program);
        return null
    return program

window.createProgram = loadProgram

createProgramFromScripts = (gl, shaderScriptIds, opt_attribs, opt_locations, opt_errorCallback) ->
  shaders = []
  for ii in shaderScriptIds
    shaders.push(createShaderFromScript(
        gl, shaderScriptIds[ii], gl[defaultShaderType[ii]], opt_errorCallback));

  return loadProgram(gl, shaders, opt_attribs, opt_locations, opt_errorCallback);



getShader = (gl, id) ->
      shaderScript = document.getElementById(id)
      if !shaderScript
          return null

      str = ""
      k = shaderScript.firstChild
      while (k)
          if (k.nodeType == 3)
              str += k.textContent
          k = k.nextSibling

      shader = null
      if (shaderScript.type == "x-shader/x-fragment")
          shader = gl.createShader(gl.FRAGMENT_SHADER)
      else if (shaderScript.type == "x-shader/x-vertex")
          shader = gl.createShader(gl.VERTEX_SHADER)
      else
          return null
      console.log(str)
      gl.shaderSource(shader, str)
      gl.compileShader(shader)

      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
          alert(gl.getShaderInfoLog(shader))
          return null
      console.log('sh')
      return shader

createShaderFromScriptElement = getShader





makeTexture = (imageData) ->
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, imageData.width, imageData.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, imageData.data)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER,
                   if generateMipmaps > 1 then gl.LINEAR_MIPMAP_LINEAR else gl.LINEAR);
  if(generateMipmaps)
    gl.generateMipmap(gl.TEXTURE_2D);


#$(document).ready(()->
#  tex = new NamedTextures()
  #console.log(tex)
  #tex.instantiate('pyramid') #'rgbw1')
  #$.get()
#)

setRectangle = (gl, x, y, width, height) ->
    x1 = x
    x2 = x + width
    y1 = y
    y2 = y + height
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
        x1, y1,
        x2, y1,
        x1, y2,
        x1, y2,
        x2, y1,
        x2, y2]), gl.STATIC_DRAW)


run_programs = (gl) ->
    program = gl.createProgram()

    program.vs = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource(program.vs,
        "attribute vec2 a_position;\n" +
        "attribute vec2 a_texCoord;\n" +
        "uniform vec2 u_resolution;\n" +
        "varying vec2 tc;\n" +
        "void main() {\n" +
        "  // convert the rectangle from pixels to 0.0 to 1.0\n" +
        "  vec2 zeroToOne = a_position / u_resolution;\n" +
        "  // convert from 0->1 to 0->2\n" +
        "  vec2 zeroToTwo = zeroToOne * 2.0;\n" +
        "  // convert from 0->2 to -1->+1 (clipspace)\n" +
        "  vec2 clipSpace = zeroToTwo - 1.0;\n" +
        "  gl_Position = vec4(clipSpace, 0, 1);\n" +
        "  tc = a_texCoord;\n" +
        "}\n")

    program.fs = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource(program.fs,
                "precision highp float;\n" +
                "uniform sampler2D tex;\n" +
                "varying vec2 tc;\n" +
                "void main(){\n" +
                "    vec4 tmp = texture2D(tex, tc);\n" +
                "    tmp.a = 1.0;\n" +
                "    gl_FragColor = tmp;\n" +
                "}\n")


    gl.compileShader(program.vs)
    if (!gl.getShaderParameter(program.vs, gl.COMPILE_STATUS))
        alert(gl.getShaderInfoLog(program.vs))
        return null
    gl.compileShader(program.fs)
    if (!gl.getShaderParameter(program.fs, gl.COMPILE_STATUS))
        alert(gl.getShaderInfoLog(program.fs))
        return null

    gl.attachShader(program, program.vs)
    gl.attachShader(program, program.fs)

    gl.deleteShader(program.vs)
    gl.deleteShader(program.fs)
    
    #gl.bindAttribLocation(program, 0, "vertex")
    gl.linkProgram(program)
    linked = gl.getProgramParameter(program, gl.LINK_STATUS);
    if !linked
        lastError = gl.getProgramInfoLog (program)
        console.log(lastError)
        return null
    gl.useProgram(program)
    program

main = () ->
    console.log("ASDFADSF")
    # Get A WebGL context
    canvas = document.getElementById("canvas")
    gl = canvas.getContext("experimental-webgl")
    window.gl = gl;

    console.log(canvas, gl)

    nt = new NamedTextures(gl)

    console.log('got ready')

    program = run_programs(gl)

    # set the resolution
    resolutionLocation = gl.getUniformLocation(program, "u_resolution")
    gl.uniform2f(resolutionLocation, canvas.width, canvas.height)


    texCoordLocation = gl.getAttribLocation(program, "a_texCoord");

    # provide texture coordinates for the rectangle.
    texCoordBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
      0.0,  0.0,
      1.0,  0.0,
      0.0,  1.0,
      0.0,  1.0,
      1.0,  0.0,
      1.0,  1.0]), gl.STATIC_DRAW)
    gl.enableVertexAttribArray(texCoordLocation)
    gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0)


    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    attr = gl.getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(attr)
    gl.vertexAttribPointer(attr, 2, gl.FLOAT, false, 0, 0)

    x = y = 0
    w = h = 150
    idx = 0
    for t in nt.get_names()
        gl.bindTexture(gl.TEXTURE_2D, nt.get_tex(t))
        setRectangle(gl, x,y,w,h)
        x += w
        idx += 1
        if idx % 4 == 0
           y += h
           x = 0

        gl.drawArrays(gl.TRIANGLES, 0, 6)

    colors = new Colors(gl, Math.random())
    sh = new Shader(gl)
    sh.setup(gl, 0, {
        tex0: nt.get_random_tex(),
        tex1: nt.get_random_tex(),
        u_resolution: {
          width: canvas.width,
          height: canvas.height,
        },
        c0: colors.get_color(0),
        c1: colors.get_color(1),
        c2: colors.get_color(2),
        r0: colors.get_rand(0),
        r1: colors.get_rand(1),
    })
    setRectangle(gl, 50,50,300,300)

    gl.enable(gl.BLEND)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.disable(gl.DEPTH_TEST)

    gl.drawArrays(gl.TRIANGLES, 0, 6)


  

window.onload = main



