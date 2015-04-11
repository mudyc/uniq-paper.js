# 
# Copyright (c) 2003, Janne Kujala and Tuomas J. Lukka
# 
# This file is part of Libvob.
# 
# Libvob is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# Libvob is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General
# Public License along with Libvob; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA  02111-1307  USA
# 
# 


# Manage the textures for papers.
# Texture types are:
#  [standard]:
#	RGB2
#	RGB3
#  [NV2X]:
#	DP2
#	DP3
#	OFFS2
#	OFFS3


#import org.nongnu.libvob.gl
#import java
from math import exp

dbg = 0

texture_format = "RGBA"
texture_components = 4

isNV2X = 0

ptextures = {}

#from vob.paper.texcache import getCachedTexture

class NamedTexture:
    def __init__(self, dict):
        # Add default values below
        self.continuous = 1
        self.minfilter = "LINEAR_MIPMAP_LINEAR"
        self.magfilter = "LINEAR"
        self.maxaniso = ""
        #if org.nongnu.libvob.gl.GL.hasExtension("GL_EXT_texture_filter_anisotropic"):
        #    self.maxaniso = "2.0"

        
        # Update from specified values
        self.__dict__.update(dict)
        import itertools, struct
        from subprocess import Popen, PIPE
        print self.args
        args = map(str, ['./'+self.args[6]+'.bin'] + self.args[0:4] + self.args[7])
        print args
        output = Popen(args, stdout=PIPE)
        count = reduce(lambda x, y: x*y, filter(lambda x: x!=0, self.args[0:4]))
        print count
        #done = struct.unpack(str(count)+'B', output.stdout.read(count))
        done = struct.unpack(str(count)+'f', output.stdout.read(count*4))
        import json
        with open(self.name+'.json', 'w') as outfile:
            json.dump({
                'data': done,
                'width': self.args[0],
                'height': self.args[1],
                'depth': self.args[2],
                'ncomp': self.args[3],
                'type': self.args[4],
                'magfilter': self.magfilter,
                'minfilter': self.minfilter,
            }, outfile)

        with open(self.name+'.js', 'w') as outfile:
            outfile.write('var TEX_DATA = TEX_DATA || [];\n')
            outfile.write('TEX_DATA.push(\n')
            json.dump({
                'data': done,
                'width': self.args[0],
                'height': self.args[1],
                'depth': self.args[2],
                'ncomp': self.args[3],
                'type': self.args[4],
                'magfilter': self.magfilter,
                'minfilter': self.minfilter,
            }, outfile)
            outfile.write(');\n')
        

        # Generate textures lazily
        print "Generating texture: ", self.name, self.args
        if 0:
            print "Generating texture: ", self.name, self.args
            self.texture = getCachedTexture(self.args)

    def getTexId(self):
        if not hasattr(self, "texture"):
            if dbg:
                print "Generating texture: ", self.name, self.args
            self.texture = getCachedTexture(self.args)
            # XXX: FIXME: 1D/3D textures!!!
            target = "TEXTURE_2D"
	    self.texture.setTexParameter(target, "TEXTURE_WRAP_S", "REPEAT")
	    self.texture.setTexParameter(target, "TEXTURE_WRAP_T", "REPEAT")
	    self.texture.setTexParameter(target, "TEXTURE_MIN_FILTER", self.minfilter)
	    self.texture.setTexParameter(target, "TEXTURE_MAG_FILTER", self.magfilter)            
            if (self.maxaniso and (self.minfilter + self.magfilter).find("NEAREST")):
                self.texture.setTexParameter(target, "TEXTURE_MAX_ANISOTROPY_EXT", self.maxaniso)

        return self.texture.getTexId()

    def getName(self):
        return self.name


def getNamed(type, name):
    """Get a texture of the particular type
    with the given name.

    E.g. getNamed("RGB2", "turb")
    """

    for t in ptextures[type]:
	if t.getName() == name:
	    return t
    return None

initialized = 0
def init(texture_components, texture_format):
    """Creates and returns textures.""" # XXX need more doc here
    global initialized
    initialized = 1
    # global ptextures (return instead)


    # "scale": something like reciprocal of maximum derivative
    # "featurescale": reciprocal of the number of "features" on a unit length

    tres = 128
    ptextures["RGB2"] = map(NamedTexture, filter(lambda dict: dict["name"] in [
        "rgbw1",
        "rgbw2",
        "rgbw3",
        "turb",
        "pyramid",
        ##"checkerboard",
        "cone",
        ##"checkerboard2",
        "saw",
        "triangle",
        "rnd0",
        "rnd1",
        "rnd2",
        "stripe",
        "rnd0n",
        "rnd1n",
        "rnd2n",
        ], [
        {"name" : "rgbw1",
         "args" : [tres, tres, 0, texture_components, texture_format,
                   texture_format, "fnoise",
                   ["scale", ".43", "freq", "1", "df", ".3", "bias", "0.5", "seed", "2323" ]],
         "scale" : 1./2,
         "featurescale" : 1./2,
         },
        
        {"name" : "rgbw2",
         "args" : [tres, tres, 0, texture_components, texture_format,
                   texture_format, "fnoise",
                   ["scale", ".43", "freq", "1", "df", "1.2", "bias", "0.5" ]],
         "scale" : 1./2,
         "featurescale" : 1./4,
         },


        {"name" : "rgbw3",
         "args" : [tres, tres, 0, texture_components, texture_format,
                   texture_format, "fnoise",
                   ["scale", ".3", "freq", "1", "df", "1.9", "bias", "0.5",
                    "seed", "361", "aniso", "2"]],
         "scale" : 1./2,
         "featurescale" : 1./4,
         },

        {"name" : "turb",
         "args" : [tres, tres, 0, texture_components, texture_format,
                   texture_format, "fnoise",
                   ["turb", "1", "scale", ".3", "freq", "1",
                    "freq2", "100", "df", "1", "bias", "0"]],
         "scale" : 1./8,
         "featurescale" : 1./16,
         },
        
        {"name" : "pyramid",
         "args" : [64, 64, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "0"]],
         "scale" : 1./2,
         "featurescale" : 1./2,
         },
        
        {"name" : "checkerboard",
         "args" : [4, 4, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "1", "scale", ".5", "bias", ".5"]],
         "continuous" : 0,
         "scale" : 1./8,
         "featurescale" : 1./4,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },
        
        {"name" : "cone",
         "args" : [64, 64, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "2"]],
         "scale" : 1./2,
         "featurescale" : 1./2,
         },
        
        {"name" : "checkerboard2",
         "args" : [2, 2, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "3", "scale", ".5", "bias", ".5"]],
         "continuous" : 0,
         "scale" : 1./8,
         "featurescale" : 1./2,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },
        
        {"name" : "saw",
         "args" : [64, 64, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "4"]],
         "continuous" : 0,
         "scale" : 1./8,
         "featurescale" : 1.,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },
        
        {"name" : "triangle",
         "args" : [64, 64, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "5"]],
         "scale" : 1./2,
         "featurescale" : 1./2,
         },

        {"name" : "stripe",
         "args" : [2, 2, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "6", "scale", ".5", "bias", ".5"]],
         "continuous" : 0,
         "scale" : 1./8,
         "featurescale" : 1./2,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },

        {"name" : "rnd0",
         "args" : [2, 2, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "10"]],
         "continuous" : 0,
         "scale" : 1./2,
         "featurescale" : 1./2,
         },

        {"name" : "rnd1",
         "args" : [2, 4, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "11"]],
         "continuous" : 0,
         "scale" : 1./4,
         "featurescale" : 1./4,
         },

        {"name" : "rnd2",
         "args" : [4, 4, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "12"]],
         "continuous" : 0,
         "scale" : 1./4,
         "featurescale" : 1./4,
         },

        {"name" : "rnd0n",
         "args" : [2, 2, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "13"]],
         "continuous" : 0,
         "scale" : 1./2,
         "featurescale" : 1./2,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },

        {"name" : "rnd1n",
         "args" : [2, 4, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "14"]],
         "continuous" : 0,
         "scale" : 1./4,
         "featurescale" : 1./4,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },

        {"name" : "rnd2n",
         "args" : [4, 4, 0, texture_components, texture_format,
                   texture_format, "geometric", ["type", "7", "seed", "15"]],
         "continuous" : 0,
         "scale" : 1./4,
         "featurescale" : 1./4,
         "minfilter" : "NEAREST",
         "magfilter" : "NEAREST",
         },
]))

    ptextures["DOT2"] = map(NamedTexture, [ 
        { "name" : "dotprodn",
          "args" : [512, 512, 0, 2,
                    "SIGNED_HILO_NV", "HILO_NV",  # XXX signed
                    "noise", ["type", "normal", "freq", "10", "scale", "0.1"]]
          },
        
        { "name" : "dotprodt",
          "args" : [512, 512, 0, 2,
                    "SIGNED_HILO_NV", "HILO_NV",  # XXX signed
                    "noise", ["type", "turbulence", "freq", "40"]] },
        
        { "name" : "dotprodw",
          "args" : [512, 512, 0, 2,
                    "SIGNED_HILO_NV", "HILO_NV",  # XXX signed
                    "waves", ["abs", "1", "freq0", "2", "freq1", "3"]],
          },
        ])

    ptextures["DSDT"] = map(NamedTexture, [ 
        { "name" : "dsdtw1",
          "args" : [512, 512, 0, 2, "DSDT_NV", "DSDT_NV", "fnoise",
                    ["scale", ".43", "freq", "1", "df", ".3", "bias", "0.5",
                     "seed", "2323" ]],
          },
        ])

    ptextures["DSDT_HILO"] = map(NamedTexture,
                                 filter(lambda dict: dict["name"] in [
        "dsdt_w1",
        "dsdt_turb",
        "dsdt_pyramid",
        "dsdt_checkerboard",
        "dsdt_cone",
        "dsdt_saw",
        "dsdt_triangle",
        "dsdt_stripe",
        "dsdt_rnd0",
        "dsdt_rnd1",
        "dsdt_rnd2",
        "dsdt_rnd3",
        "dsdt_rnd4",
        ], [ 
        { "name" : "dsdt_w1",
          "args" : [tres, tres, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "fnoise",
                    ["scale", ".43", "freq", "1", "df", "1", "bias", "0.5",
                     "seed", "2323" ]],
          },
        { "name" : "dsdt_turb",
          "args" : [tres, tres, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "fnoise",
                    ["turb", "1", "scale", ".3", "freq", "1",
                     "freq2", "100", "df", "1", "bias", "0"]],
          },
        { "name" : "dsdt_pyramid",
          "args" : [64, 64, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "0", "scale", ".5"]],
          },
        { "name" : "dsdt_checkerboard",
          "args" : [4, 4, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "1", "scale", ".5"]],
          "minfilter" : "NEAREST",
          "magfilter" : "NEAREST",
          },
        { "name" : "dsdt_cone",
          "args" : [64, 64, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "2", "scale", ".5"]],
          },
        { "name" : "dsdt_saw",
          "args" : [64, 64, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "4"]],
          },
        { "name" : "dsdt_triangle",
          "args" : [64, 64, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "5"]],
          },
        { "name" : "dsdt_stripe",
          "args" : [2, 2, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "6"]],
          "minfilter" : "NEAREST",
          "magfilter" : "NEAREST",
          },
        { "name" : "dsdt_rnd0",
          "args" : [2, 2, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "7", "scale", "1", "seed", "100"]],
          },
        { "name" : "dsdt_rnd1",
          "args" : [4, 4, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "7", "scale", ".5", "seed", "101"]],
          },
        { "name" : "dsdt_rnd2",
          "args" : [8, 8, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "7", "scale", ".3", "seed", "102"]],
          },
        { "name" : "dsdt_rnd3",
          "args" : [16, 16, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "7", "scale", ".2", "seed", "103"]],
          },
        { "name" : "dsdt_rnd4",
          "args" : [32, 32, 0, 2, "SIGNED_HILO_NV", "HILO_NV", "geometric",
                    ["type", "7", "scale", ".1", "seed", "104"]],
          },
        ]))

    ptextures["FOOBAR"] = [ ptextures["RGB2"][-1] ]
    
    return ptextures    

def getPaperTexture(type, gen):
    return selectRandom(ptextures[type], gen)


class Textures:
    textures = None
    last_paperopt = 0
    #paperopt = org.nongnu.libvob.gl.PaperOptions.instance()
    def __init__(self, seed):
        text_comps, text_form = texture_components, texture_format
        if not self.textures:
            self.paperInit()
            
	rnd = java.util.Random(seed)

        hyper = rnd.nextGaussian()*5

        self.probs = {}

        for type in ["RGB2"] + filter(lambda key: key != "RGB2", self.textures.keys()):
            self.probs[type] = []
            sum = 0

            for tex in self.textures[type]:
                prob = exp(rnd.nextGaussian() * hyper)
            
                self.probs[type].append(prob)
                sum += prob

            self.probs[type] = [ prob / sum for prob in self.probs[type] ]

            #print self.probs[type]

    def paperInit(self):
        if self.paperopt.use_opengl_1_1:
            text_comps, text_form = 2, 'LUMINANCE_ALPHA'
        else:
            text_comps, text_form = 4, 'RGBA'
            
        self.textures = init(text_comps, text_form)
        print self.textures
        if dbg:
            print "Textures created: components: %d, format: %s" % (text_comps, text_form)

        
    def getPaperTexture(self, type, gen):

        if self.last_paperopt != self.paperopt.use_opengl_1_1:
            self.paperInit()
            self.last_paperopt = self.paperopt.use_opengl_1_1

        index = 0

        t = gen.nextDouble()
        
        for p in self.probs[type]:
            t -= p
            if t < 0:
                #print self.textures[type][index].getName()
                return self.textures[type][index]
            index += 1

        print "Warning: null probability event occured"
        return self.textures[type][-1]
        

    def getPaperTextures(self, types, gen):
        return [ self.getPaperTexture(type, gen) for type in types ]



if __name__ == '__main__':
    text_comps, text_form = 4, 'RGBA'
    textures = init(text_comps, text_form)
