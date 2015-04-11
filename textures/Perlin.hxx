/*
Perlin.hxx
 *    
 *    Copyright (c) 2003, Tuomas J. Lukka and Janne Kujala
 *    
 *    This file is part of Gzz.
 *    
 *    Gzz is free software; you can redistribute it and/or modify it under
 *    the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *    
 *    Gzz is distributed in the hope that it will be useful, but WITHOUT
 *    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 *    Public License for more details.
 *    
 *    You should have received a copy of the GNU General
 *    Public License along with Gzz; if not, write to the Free
 *    Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 *    MA  02111-1307  USA
 *    
 *    
 */
/*
 * Written by Tuomas J. Lukka and Janne Kujala
 */


#ifndef GZZ_PERLIN_HXX
#define GZZ_PERLIN_HXX

namespace Vob {
/** Perlin's noise function &amp; co.
 * This package contains various functions useful for procedural
 * texturing.
 * <p>Note by Tjl:
 * This code has been taken from the CD distributed with
 * Texturing&Modeling 2nd edition. Ken Perlin also distributes
 * this on his home page.
 * No license has been specified in this code or on the web page, 
 * so I'm assuming it's freely distributable and including it here.
 * If this is not the case, please inform me and I will remove it promptly.
 * <p>
 */
namespace Perlin {
    float bias(float a, float b) ;
    float gain(float a, float b) ;

    float turbulence(float *v, float freq) ;
    float noise(float vec[], int len) ;
    float noise1(float arg);
    float noise2(float vec[]);
    float noise2(float vec[], float der[]);
    float noise3(float vec[]);

    float voronoise3_spot(float vec[3], float jitter, float maxdist) ;
    void voronoise3(float vec[3], float jitter, float *fo1, float *fo2, float *fd) ;
    float cellnoise3(float vec[3]) ;
    float smoothstep(float low, float high, float x) ;
    float fBm(float *v, int octaves, float lacu, float gain) ;
    float faBm(float *v, int octaves, float lacu, float gain) ;

    inline float noise(float arg) { return noise1(arg); }
    inline float noise(float arg1, float arg2) { 
      float par[2] = {arg1, arg2};
      return noise2(par); 
    }
    inline float noise(float arg1, float arg2, float arg3) { 
        float par[3] = {arg1, arg2, arg3};
        return noise3(par); 
    }

    inline float smooth_step(float t) {
	if(t <= 0) return 0;
	if(t >= 1) return 1;
	return ( t * t * (3. - 2. * t) );
    }
    inline float smooth_step(float t, float low, float high) {
	return smooth_step( (t-low) / (high-low) );
    }

}
}

#endif
