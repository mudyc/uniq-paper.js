# 
# Copyright (c) 2015, Matti Katila
# 
# This file is part of uniq-paper.js.
# 
# uniq-paper.js is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# uniq-paper.js is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General
# Public License along with uni-paper.js; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA  02111-1307  USA
# 
# 

dot = (a,b) ->
    [
        a[0*4+0]*b[0] + a[0*4+1]*b[1] + a[0*4+2]*b[2] + a[0*4+3]*b[3],
        a[1*4+0]*b[0] + a[1*4+1]*b[1] + a[1*4+2]*b[2] + a[1*4+3]*b[3],
        a[2*4+0]*b[0] + a[2*4+1]*b[1] + a[2*4+2]*b[2] + a[2*4+3]*b[3],
    ]

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


main = () ->
    # Get A WebGL context
    canvas = document.getElementById("canvas")
    gl = canvas.getContext("experimental-webgl")

    shader = new Shader(gl)
    program = shader._make_program(gl,
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
        "}\n",

        "precision highp float;\n" +
        "uniform sampler2D tex;\n" +
        "varying vec2 tc;\n" +
        "void main(){\n" +
        "    vec4 tmp = texture2D(tex, tc);\n" +
        "    tmp.a = 0.6;\n" +
        "    gl_FragColor = tmp;\n" +
        "}\n")

    gl.useProgram(program)

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

    # 1st tex
    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    attr = gl.getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(attr)
    gl.vertexAttribPointer(attr, 2, gl.FLOAT, false, 0, 0)

    nt = new NamedTextures(gl)
    gl.bindTexture(gl.TEXTURE_2D, nt.get_tex(nt.get_names()[0]))
    setRectangle(gl, 300,300, 300,300)
    gl.drawArrays(gl.TRIANGLES, 0, 6)



    # 2nd tex
    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    attr = gl.getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(attr)
    gl.vertexAttribPointer(attr, 2, gl.FLOAT, false, 0, 0)

    nt = new NamedTextures(gl)
    gl.bindTexture(gl.TEXTURE_2D, nt.get_tex(nt.get_names()[2]))
    #setRectangle(gl, 300,300, 300,300)
    #gl.drawArrays(gl.TRIANGLES, 0, 6)

    rootrep = new TexGenXYRepeatUnit().getRelated().texCoords2D()
    if rootrep.length < 12
        for i in [0,0,0,1]
            data.push(i)

    console.log(rootrep)
    maap = (vec)->
        jQuery.map(vec, (x)-> console.log(x); 300 + 300*x)
    xy00 = maap(dot(rootrep, [0,0,0,1]))
    xy10 = maap(dot(rootrep, [1,0,0,1]))
    xy01 = maap(dot(rootrep, [0,1,0,1]))
    xy11 = maap(dot(rootrep, [1,1,0,1]))
    
    console.log(xy00, xy01, xy10, xy11)

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
        xy00[0], xy00[1],
        xy10[0], xy10[1],
        xy01[0], xy01[1],
        xy01[0], xy01[1],
        xy10[0], xy10[1],
        xy11[0], xy11[1]]), gl.STATIC_DRAW)
    gl.drawArrays(gl.TRIANGLES, 0, 6)
    


  

window.onload = main



