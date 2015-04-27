# 
# Copyright (c) 2015, Matti Katila
#       Ported from the Libvob code Copyright (c) 2003, Janne Kujala and Tuomas J. Lukka 
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



class Shader


    constructor: (gl)->
        @programs = []

        # Band-like texture

        # Interpolate between three colors:
        # d0 = t0 . r0
        # d1 = t1 . r1
        # lerp(d1, lerp(d0, c0, c1), c2)
        # The alpha value is computed as d0^2 - d1^2
        # Interpolate between three colors using two dot products
        @programs.push @_make_program(gl,
            # Vertex shader
            "attribute vec2 a_position;\n" +
            "attribute vec2 a_texCoord0;\n" +
            "attribute vec2 a_texCoord1;\n" +
            "uniform vec2 u_resolution;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "uniform vec4 u_skew0[2];\n" +
            "uniform vec4 u_skew1[2];\n" +
            "vec2 doot(vec4 skew[2], vec4 coords){\n" +
            "    return vec2(skew[0].x*coords.x + skew[0].y*coords.y + skew[0].z*coords.z + skew[0].w*coords.w,skew[1].x*coords.x + skew[1].y*coords.y + skew[1].z*coords.z + skew[1].w*coords.w );\n" +
            "}\n" +
            "void main() {\n" +
            "  // convert the rectangle from pixels to 0.0 to 1.0\n" +
            "  vec2 zeroToOne = a_position / u_resolution;\n" +
            "  // convert from 0->1 to 0->2\n" +
            "  vec2 zeroToTwo = zeroToOne * 2.0;\n" +
            "  // convert from 0->2 to -1->+1 (clipspace)\n" +
            "  vec2 clipSpace = zeroToTwo - 1.0;\n" +
            "  gl_Position = vec4(clipSpace, 0, 1);\n" +
            "  tc0 = doot(u_skew0, vec4(a_texCoord0.xy,0,1));\n" +
            "  tc1 = doot(u_skew1, vec4(a_texCoord1.xy,0,1));\n" +
            "}\n",
            # Fragment shader
            "precision highp float;\n" +
            "uniform sampler2D tex0;\n" +
            "uniform sampler2D tex1;\n" +
            "uniform vec3 color0;\n" +
            "uniform vec3 color1;\n" +
            "uniform vec3 color2;\n" +
            "uniform vec3 r0;\n" +
            "uniform vec3 r1;\n" +
            "uniform float trans;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "void main(){\n" +
            "    vec3 t0 = vec3(texture2D(tex0, tc0));\n" +
            "    vec3 t1 = vec3(texture2D(tex1, tc1));\n" +
            "    float spare0 = dot(t0, t1);\n" +
            "    float spare1 = spare0 * spare0;\n" +
            "    float ef = spare1 * dot(t0, r0);\n" +
            "    vec3 color = mix(color0, color1, ef);\n" +
            "    gl_FragColor = vec4(color.rgb, 1);\n" +
            "    if (trans > 0.0)\n" +
            "        gl_FragColor = vec4(color.rgb, color.b-trans);\n" +
            "}\n"
        )

            

        @programs.push @_make_program(gl,
            # Vertex shader
            "attribute vec2 a_position;\n" +
            "attribute vec2 a_texCoord0;\n" +
            "attribute vec2 a_texCoord1;\n" +
            "uniform vec2 u_resolution;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "uniform vec4 u_skew0[2];\n" +
            "uniform vec4 u_skew1[2];\n" +
            "vec2 doot(vec4 skew[2], vec4 coords){\n" +
            "    return vec2(skew[0].x*coords.x + skew[0].y*coords.y + skew[0].z*coords.z + skew[0].w*coords.w,skew[1].x*coords.x + skew[1].y*coords.y + skew[1].z*coords.z + skew[1].w*coords.w );\n" +
            "}\n" +
            "void main() {\n" +
            "  // convert the rectangle from pixels to 0.0 to 1.0\n" +
            "  vec2 zeroToOne = a_position / u_resolution;\n" +
            "  // convert from 0->1 to 0->2\n" +
            "  vec2 zeroToTwo = zeroToOne * 2.0;\n" +
            "  // convert from 0->2 to -1->+1 (clipspace)\n" +
            "  vec2 clipSpace = zeroToTwo - 1.0;\n" +
            "  gl_Position = vec4(clipSpace, 0, 1);\n" +
            "  tc0 = doot(u_skew0, vec4(a_texCoord0.xy,0,1));\n" +
            "  tc1 = doot(u_skew1, vec4(a_texCoord1.xy,0,1));\n" +
            "}\n",
            # Fragment shader
            # Fraction-line color interpolate
                
            # SPARE0 <- (TEX0 . CONST0)
            # SPARE1 <- (TEX1 . CONST1)
            # PRI_COL <- lerp(SPARE0, PRI_COL, SEC_COL)
            # SPARE1.alpha <- SPARE0^2 - SPARE1^2
            # lerp(SPARE1, PRI_COL, FOG)
            "precision highp float;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "uniform sampler2D tex0;\n" +
            "uniform sampler2D tex1;\n" +
            "uniform vec3 color0;\n" +
            "uniform vec3 color1;\n" +
            "uniform vec3 color2;\n" +
            "uniform float trans;\n" +
            "uniform vec3 r0;\n" +
            "uniform vec3 r1;\n" +
            "void main(){\n" +
            "    vec3 t0 = vec3(texture2D(tex0, tc0));\n" +
            "    vec3 t1 = vec3(texture2D(tex1, tc1));\n" +
            "    float spare0 = dot(t0, r0);\n" +
            "    float spare1 = dot(t1, r1);\n" +
            "    vec3 tmp = mix(color0, color1, spare0);\n" +
            "    vec4 color = vec4(mix(tmp, color2, spare1).rgb, 1);\n" +
            "    color.a = 1.0;\n" +
            "    if (trans > 0.0)\n" +
            "        color.a = abs(spare0*spare0 - spare1*spare1);\n" +

            "    gl_FragColor = color;\n" +
            #"    gl_FragColor = vec4(spare1, spare1, spare1, 1);\n" +
            "}\n"
        )



        # Interpolate on the fraction line c0,c1,c2:
        # d0 = t0 . t1
        # c(d0) =
        #    -1 -> c0
        #     0 -> c1
        #    +1 -> c2

        # lerp(d1, lerp(d0, c0, c1), c2)
        # The alpha value is computed as d0^2 - d1^2
        @programs.push @_make_program(gl,
            # Vertex shader
            "attribute vec2 a_position;\n" +
            "attribute vec2 a_texCoord0;\n" +
            "attribute vec2 a_texCoord1;\n" +
            "uniform vec2 u_resolution;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "uniform vec4 u_skew0[2];\n" +
            "uniform vec4 u_skew1[2];\n" +
            "vec2 doot(vec4 skew[2], vec4 coords){\n" +
            "    return vec2(skew[0].x*coords.x + skew[0].y*coords.y + skew[0].z*coords.z + skew[0].w*coords.w,skew[1].x*coords.x + skew[1].y*coords.y + skew[1].z*coords.z + skew[1].w*coords.w );\n" +
            "}\n" +
            "void main() {\n" +
            "  // convert the rectangle from pixels to 0.0 to 1.0\n" +
            "  vec2 zeroToOne = a_position / u_resolution;\n" +
            "  // convert from 0->1 to 0->2\n" +
            "  vec2 zeroToTwo = zeroToOne * 2.0;\n" +
            "  // convert from 0->2 to -1->+1 (clipspace)\n" +
            "  vec2 clipSpace = zeroToTwo - 1.0;\n" +
            "  gl_Position = vec4(clipSpace, 0, 1);\n" +
            "  tc0 = doot(u_skew0, vec4(a_texCoord0.xy,0,1));\n" +
            "  tc1 = doot(u_skew1, vec4(a_texCoord1.xy,0,1));\n" +
            "}\n",
            # Fragment shader
            # Fraction-line color interpolate
                
            # SPARE0 <- (TEX0 . TEX1)  
            # SPARE1 <- -(TEX0 . TEX1) 
            # PRI_COL <- lerp(SPARE1, SEC_COL, PRI_COL)
            # lerp(SPARE0, PRI_COL, FOG)
            # SPARE1.alpha <- TEX0.b * CONST0.b + TEX1.b * CONST1.b
            "precision highp float;\n" +
            "varying vec2 tc0;\n" +
            "varying vec2 tc1;\n" +
            "uniform sampler2D tex0;\n" +
            "uniform sampler2D tex1;\n" +
            "uniform vec3 color0;\n" +
            "uniform vec3 color1;\n" +
            "uniform vec3 color2;\n" +
            "uniform float trans;\n" +
            "uniform vec3 r0;\n" +
            "uniform vec3 r1;\n" +
            "void main(){\n" +
            "    vec3 t0 = vec3(texture2D(tex0, tc0));\n" +
            "    vec3 t1 = vec3(texture2D(tex1, tc1));\n" +
            "    float spare0 = dot(t0, t1);\n" +
            "    float spare1 = -spare0;\n" +
            "    vec3 tmp = mix(color0, color1, spare1);\n" +
            "    vec4 color = vec4(mix(tmp, color2, spare1).rgb, 1);\n" +
            "    if (trans > 0.0)\n" +
            "        color.a = t0.b * r0.b + t1.b * r1.b;\n" +
            "    gl_FragColor = color;\n" +
            "}\n"
        )

    setup: (gl, ind, obj)->
        #console.log(obj)
        program = @programs[ind]
        gl.useProgram(program)

        # set the resolution
        resolutionLocation = gl.getUniformLocation(program, "u_resolution")
        gl.uniform2f(resolutionLocation, obj.u_resolution.width, obj.u_resolution.height)


        # provide texture coordinates for the rectangle.
        texCoordLocation = gl.getAttribLocation(program, "a_texCoord0");
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

        # provide texture coordinates for the rectangle.
        texCoordLocation = gl.getAttribLocation(program, "a_texCoord1");
        texCoordBuffer2 = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer2)
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
          0.0,  0.0,
          1.0,  0.0,
          0.0,  1.0,
          0.0,  1.0,
          1.0,  0.0,
          1.0,  1.0]), gl.STATIC_DRAW)
        gl.enableVertexAttribArray(texCoordLocation)
        gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0)

        # set textures
        tex0 = gl.getUniformLocation(program, "tex0")
        tex1 = gl.getUniformLocation(program, "tex1")

        gl.activeTexture(gl.TEXTURE0)
        #gl.enable(gl.TEXTURE_2D)
        gl.bindTexture(gl.TEXTURE_2D, obj.tex0)

        gl.activeTexture(gl.TEXTURE1)
        #gl.enable(gl.TEXTURE_2D)
        gl.bindTexture(gl.TEXTURE_2D, obj.tex1)

        gl.uniform1i(tex0, 0)
        gl.uniform1i(tex1, 1)

        # set coords
        s0 = gl.getUniformLocation(program, "u_skew0")
        gl.uniform4fv(s0, obj.coords0)
        s1 = gl.getUniformLocation(program, "u_skew1")
        gl.uniform4fv(s1, obj.coords1)


        # set colors
        color0 = gl.getUniformLocation(program, "color0")
        gl.uniform3f(color0, obj.c0[0], obj.c0[1], obj.c0[2])
        color1 = gl.getUniformLocation(program, "color1")
        gl.uniform3f(color1, obj.c1[0], obj.c1[1], obj.c1[2])
        color2 = gl.getUniformLocation(program, "color2")
        gl.uniform3f(color2, obj.c2[0], obj.c2[1], obj.c2[2])

        # set random vectors
        r0 = gl.getUniformLocation(program, "r0")
        gl.uniform3f(r0, obj.r0[0], obj.r0[1], obj.r0[2])
        r1 = gl.getUniformLocation(program, "r1")
        gl.uniform3f(r1, obj.r1[0], obj.r1[1], obj.r1[2])

        # set transparency
        t = gl.getUniformLocation(program, "trans")
        gl.uniform1f(t, obj.trans);

        buffer = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
        attr = gl.getAttribLocation(program, "a_position");
        gl.enableVertexAttribArray(attr)
        gl.vertexAttribPointer(attr, 2, gl.FLOAT, false, 0, 0)


        
    _make_program: (gl, vertex, shader) ->
        program = gl.createProgram()

        program.vs = gl.createShader(gl.VERTEX_SHADER)
        gl.shaderSource(program.vs, vertex)

        program.fs = gl.createShader(gl.FRAGMENT_SHADER)
        gl.shaderSource(program.fs, shader)

        gl.compileShader(program.vs)
        if (!gl.getShaderParameter(program.vs, gl.COMPILE_STATUS))
            alert(gl.getShaderInfoLog(program.vs))
            console.trace()
            return null
        gl.compileShader(program.fs)
        if (!gl.getShaderParameter(program.fs, gl.COMPILE_STATUS))
            alert(gl.getShaderInfoLog(program.fs))
            console.trace()
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
        #gl.useProgram(program)
        program

