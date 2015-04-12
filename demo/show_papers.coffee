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

    nt = new NamedTextures(gl)
    sh = new Shader(gl)

    x = y = 0
    w = h = 300
    idx = 0
    for t in [0..10]
        colors = new Colors(gl, Math.random())
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
        setRectangle(gl, x,y,w,h)
        x += w
        idx += 1
        if idx % 5 == 0
           y += h
           x = 0

        gl.enable(gl.BLEND)
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        gl.disable(gl.DEPTH_TEST)

        gl.drawArrays(gl.TRIANGLES, 0, 6)


window.onload = main



