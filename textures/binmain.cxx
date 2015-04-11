/*
binmain.cxx
 *    
 *    Copyright (c) 2003, Janne Kujala and Tuomas J. Lukka
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
 * Written by Janne Kujala and Tuomas J. Lukka
 */


#include <string>
#include <stdio.h>
#include <stdlib.h>

#include "Texture.hxx"

namespace Vob { namespace Texture {
    extern Texture *bin_texture;
}}
using namespace Vob::Texture;

bool bytes = false;

int main(int argc, char **argv) {

    if(argv[1][0] == '-') {
	// handle options
	if(argv[1][1] == 'b') bytes = true;
	else abort();
	argv ++;
    }
    //bytes = true;

    if(argc < 5)
	exit(2);
    int width = atoi(argv[1]);
    int height = atoi(argv[2]);
    int depth = atoi(argv[3]);
    int ncomp = atoi(argv[4]);

    TextureParam params;

    for(int i=5; i<argc-1; i+=2) {
	// fprintf(stderr, "Set param: '%s' '%s'\n", argv[i], argv[i+1]);
	params.setParam(argv[i], argv[i+1]);
    }

    int d = (depth==0 ? 1 : depth);

    float *data = new float[width*height*d*ncomp];
    for(int i=0; i<width*height*d*ncomp; i++)
	data[i] = 0.0001;
    bin_texture->render(&params, width, height, depth, ncomp, data);


    if(bytes) { 
	unsigned char *bdata = new unsigned char[width*height*d*ncomp];
	for(int i=0; i<width*height*d*ncomp; i++) {
	    int v = (int)( 255 * data[i] );
	    if(v > 255) v = 255;
	    if(v < 0) v = 0;
	    bdata[i] = v;
	}
	fwrite(bdata, sizeof(unsigned char), width*height*d*ncomp, stdout);
    } else {
	fwrite(data, sizeof(float), width*height*d*ncomp, stdout);
    }
}
