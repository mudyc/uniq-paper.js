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



# matrix

det = (mat)->
    return (+ mat[0][0] * (mat[1][1] * mat[2][2] - mat[1][2] * mat[2][1]) \
            - mat[0][1] * (mat[1][0] * mat[2][2] - mat[1][2] * mat[2][0]) \
            + mat[0][2] * (mat[1][0] * mat[2][1] - mat[1][1] * mat[2][0]))

matvecmul = (mat, v)->
    return [ mat[0][0] * v[0] + mat[0][1] * v[1] + mat[0][2] * v[2],
             mat[1][0] * v[0] + mat[1][1] * v[1] + mat[1][2] * v[2],
             mat[2][0] * v[0] + mat[2][1] * v[1] + mat[2][2] * v[2] ]


# spaces

# CIE1931 x,y-chromaticity coordinates of the
# red, green and blue phosphors of the monitor
# used in RGB <-> XYZ conversions

R = [.64,.33] # these are the HDTV/sRGB/EBU/ITU primaries
G = [.30,.60]
B = [.15,.06]

# Chromaticity coordinates of the white point (i.e., R = G = B = 1) --
# this determines the relative luminances of the primaries
# W = .312713,.329016 # = D65 standard illuminant
W = [.3127268660,.3290235126] # = D65 standard illuminant [CIE 15.2, p.55]

# The gamma and offset used for converting linear RGB to monitor RGB
gamma = 2.4 # sRGB standard
offset = .055 

# Compute z-coordinates
R = [R[0], R[1], 1 - R[0] - R[1]]
G = [G[0], G[1], 1 - G[0] - G[1]]
B = [B[0], B[1], 1 - B[0] - B[1]]
W = [W[0], W[1], 1 - W[0] - W[1]]

# Compute luminance weights for the primaries using the white point
Wr = (R[1] * det([W,G,B])) / (W[1] * det([R,G,B]))
Wg = (G[1] * det([R,W,B])) / (W[1] * det([R,G,B]))
Wb = (B[1] * det([R,G,W])) / (W[1] * det([R,G,B]))

inUnit = (vec)->
    #"""Tests whether the vector is inside the unit cube [0,1]^n"""
    return jQuery.map(vec, (x)-> if 0<x<1 then undefined else 1).length == 0


# The uncorrected display gamma of PC's is typically 2.2, i.e.,
# RGB values map to physical intensities with an exponent of 2.2.
# So, gamma correction of 2.2 (or 2.4 with .055 offset)
# here should result in linear intensity.

linear_to_monitor = (rgb)->
    f = (x)->
        if x < 0
            return -f(-x)
        if offset == 0
            return x**(1.0/gamma)

        # Use a linear segment near zero
        t = offset / (gamma - 1)
        t2 = (t * gamma / (1 + offset))**gamma
        c = t / (t * gamma / (1 + offset))**gamma
        if x < t2
            return x * c
        
        return x**(1.0/gamma) * (1 + offset) - offset

    return [ f(rgb[0]), f(rgb[1]), f(rgb[2]) ]

clampSat = (rgb)->
    #"""Clamp an RGB color keeping hue and lightness constant"""

    if inUnit(rgb)
        return rgb

    [Y,S,T] = RGBtoYST(rgb)

    r = maxYSTsat([Y,S,T])

    return YSTtoRGB([Y,r*S,r*T])


# The YST color space below is a linear color space with 
# a luminance component and a color plane vector whose angle and
# radius specify the hue and saturation, respectively.
#
# The Y component is the CIE Y luminance and
# the ST-plane has the RGB primaries 120 (R = 0, G = 120, B = 240)
# degrees apart at radius 1.
#    
# Luminance weights of the RGB primaries used in YST color space
# functions:
#Wr = 0.212671 
#Wg = 0.715160
#Wb = 0.072169
# Note: the weigths are computed from the values specified at the
#       beginning of this file
# Note: the YST color space is device dependent unless
#       a standardized RGB space is used

YSTtoRGB = (v)->
    mat =  [ [1, Wg+Wb,    (Wb - Wg) / Math.sqrt(3) ],
             [1,   -Wr,  (2*Wb + Wr) / Math.sqrt(3) ],
             [1,   -Wr, -(2*Wg + Wr) / Math.sqrt(3) ] ]
    
    return matvecmul(mat, v)

RGBtoYST = (v)->
    mat = [[ Wr, Wg, Wb ],
           [ 1, -.5, -.5],
           [ 0, .5*Math.sqrt(3), -.5*Math.sqrt(3) ]]

    return matvecmul(mat, v)

maxYSTsat = (YST)->
    #"""Return the maximum saturation factor in RGB cube of the given color"""

    # Split into "lightness" and "color" components
    Y = YSTtoRGB([YST[0],0,0])
    vec = YSTtoRGB([0,YST[1],YST[2]])

    #assert 0 <= Y[0] == Y[1] == Y[2] <= 1

    return Math.min( ((vec[0] > 0) - Y[0]) / vec[0],
                     ((vec[1] > 0) - Y[1]) / vec[1],
                     ((vec[2] > 0) - Y[2]) / vec[2] )


window.LtoY = (L)->
    # """
    # Convert perceptual lightness (CIE L*) into linear luminance
    # L: lightness between 0 and 100
    # returns: luminance between 0 and 1
    # """
    if L <= 8
        return L * (27.0 / 24389)
    else
        return Math.pow((L + 16.0) / 116, 3.0)



# utils

window.nextGaussian = ()->
    loop
       v1 = 2 * Math.random() - 1;   # between -1.0 and 1.0
       v2 = 2 * Math.random() - 1;   # between -1.0 and 1.0
       s = v1 * v1 + v2 * v2
       break if !(s >= 1 || s == 0)
     multiplier = Math.sqrt(-2 * Math.log(s)/s)
     return v1 * multiplier

window.shuffle = (a) ->
    i = a.length
    while --i > 0
        j = ~~(Math.random() * (i + 1))
        t = a[j]
        a[j] = a[i]
        a[i] = t
    a

class Colors
    constructor: (gl, seed) ->
        colors = 8
        minlum = 80
        blend = 0
        
        Math.seedrandom(seed)

        huerange = nextGaussian() * 90

        # Note: This color sampling scheme only produces
        # palettes with similar colors.
        # It could be nice to have other schemes
        # with, e.g., complementary colors.

        # Add orange color to the color circle
        getangle = (f)->
            # 0 = red, 120 = green, 240 = blue
            angles = [ 0, 30, 60, 120, 180, 240, 300, 360 ]
            n = angles.length - 1
            f *= n / 360.0
            index = Math.round(f) % n
            fract = f - Math.round(f)
            return (1 - fract) * angles[index] + fract * angles[index + 1]

        hue0 = Math.random() * 360
        hues = [hue0, hue0 + huerange] 
        hues = hues.concat(hue0 + Math.random() * huerange for i in [2...colors])
        hues = jQuery.map(hues, getangle)
        shuffle(hues)

        # Take one half dark colors and one half light colors
        lumrange = 100 - minlum
        if colors == 1
            # Use the full luminance range for solid color backgrounds
            x = Math.random()
            # Weight lower luminances more
            x = (1 - Math.sqrt(1-x))
            lums = [minlum + x * lumrange]
        else
            lums = (minlum + Math.random() * lumrange/2 for i in [0...(colors+1)/2])
            lums = lums.concat(minlum + (1 + Math.random()) * lumrange/2 for i in [(colors+1)/2...colors])

        # Sample saturation:
        #  - take the most saturated color 2/3 of the time
        #    and a dull color 1/3 of the time
        sats = ((1 - (1 - (1 - Math.random())**2) * (Math.random() < .333)) \
                for i in [0...colors])

        # Construct colors and clamp to RGB cube keeping hue and luminance constant
        yst = ( [ LtoY(lums[i]), 
                  sats[i] * Math.cos(hues[i] * Math.PI / 180), 
                  sats[i] * Math.sin(hues[i] * Math.PI / 180) ] \
                for i in [0...colors])

        col = ( linear_to_monitor(clampSat(YSTtoRGB(c))) for c in yst)
        shuffle(col)

        if blend > 0
            col = ( (blend * 1 + (1 - blend) * c for c in cc) for cc in col)

        #if dbg:
        #    print "ANGLE=", self._AB_angle(col), "AREA=", self._AB_area(col)*100

        this.colors = (c.join(' ') for c in col)
        this.colorarrs = col

        this.randvecs = ([Math.random(), Math.random(), Math.random()] for i in [0...15])

        console.log(hues, lums, sats, yst , col, this)

    get_color: (idx)-> this.colorarrs[idx]
    get_rand: (idx)-> this.randvecs[idx]


class TexGenXYRepeatUnit
    constructor: ()->
        vecs = null
        scale = .3
        scale_log_stddev = 0.4
        angle_stddev = .065
        lendiff_mean = 0
        lendiff_stddev = .1

        if vecs != null
            this.vecs = vecs
            return

        # The angle between the basis vectors
        angle = (.25 + angle_stddev*nextGaussian()) * 2 * Math.PI
        angle *= 1 - 2 * (Math.random()<0.5)

        # The angle of the first basis vector
        as = Math.random() * 2 * Math.PI
        # And the angle of the second basis vector
        at = as + angle

        # Logarightm of the random scale factor
        m0 = scale_log_stddev * nextGaussian()

        # The difference between basis vector lengths
        m = lendiff_mean + lendiff_stddev * nextGaussian()

        # The basis vector lengths
        rs = scale * Math.exp(m0 + m)
        rt = scale * Math.exp(m0 - m)

        # The vectors that give x and y when dotted with (s, t, 0, 1)
        this.vecs = [[ rs * Math.cos(as), rt * Math.cos(at)],
                     [ rs * Math.sin(as), rt * Math.sin(at)]]



class PMill
    numpasses = 3 # could be less even
    constructor: ()->

    getPaper: (seed)->
        numcolors = 8
        minlum = 80
        blend = 0
        vecs = undefined

        colors = new Colors(gl, Math.random())

        rootrep = TexGenXYRepeatUnit(rng, scale = 60 * scaleFactor, vecs = vecs)
        passes = [ { "trans" : 0, "emboss" : 0 },
                   { "trans" : .5, "emboss" : 0 },
                   { "trans" : .9375, "emboss" : 0 },
                   #{ "trans" : 0, "emboss" : 1 },
                  ][0:numpasses]
        seeds = (Math.random()*2000000000 for foo in passes)


