
class NamedTextures

    textures = {}

    get_random_tex: ()->
        names = @get_names()
        textures[names[Math.floor(Math.random() * names.length)]]

    get_names: () -> [
        "rgbw1",
        "rgbw2",
        "rgbw3",
        "turb",
        "pyramid",
        "cone",
        "saw",
        "triangle",
        "rnd0",
        "rnd1",
        "rnd2",
        "stripe",
        "rnd0n",
        "rnd1n",
        "rnd2n"
    ]

    constructor: (gl) ->
        gl.getExtension('OES_texture_float')
        gl.getExtension('OES_float_linear')
        gl.getExtension('OES_half_float_linear')
        self = this


        for t in this.get_names()
            ( (t)->
                process = (data)->
                    
                    width = data.width
                    height = data.height
                    tex_type = data.type
                    ncomp = data.ncomp
                    buff = data.data

                    # for float texts only nearest is supported
                    data.magfilter = data.minfilter = 'NEAREST'
                    #arr = new Uint8Array(buff)
                    arr = new Float32Array(buff)
                    texture = gl.createTexture()
                    textures[t] = texture
                    gl.bindTexture(gl.TEXTURE_2D, texture)
                    #gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, arr)
                    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.FLOAT, arr)
                    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
                    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
                        
                    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, if data.magfilter == 'NEAREST' then gl.NEAREST else gl.LINEAR)
                    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, if data.minfilter == 'NEAREST' then gl.NEAREST else gl.LINEAR_MIPMAP_LINEAR)
                    if data.minfilter != 'NEAREST'
                        gl.generateMipmap(gl.TEXTURE_2D)

                    gl.bindTexture(gl.TEXTURE_2D, null)
                    #console.log('ready', t, width, height)
                    if self.get_names().length == Object.keys(textures).length
                        #console.log('ready')
                        $(self).trigger('ready')

                if TEX_DATA != undefined
                    for i in TEX_DATA
                        if i.name == t
                            process(i)
                else

                    $.getJSON('/texture/'+t, (data) ->
                        process(data)
                    )
            )(t)
        this
    get_tex: (name) -> textures[name]
