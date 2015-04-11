/*
Texture_pipetexture.cxx
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
#include <vector>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <iostream>
#include <errno.h>

using std::cerr;
using std::string;

#include "Texture.hxx"

namespace Vob { namespace Texture {



class PipeTexture : public Texture {
    string name;
public:
    PipeTexture(string n):name(n) { }
  virtual void render(TextureParam *params, 
		      int width, int height, int depth, int components, float *data) {
      string s;
      s += "../libvob/src/texture/";
      s += name;
      s += ".bin ";

      char wbuf[256];
      sprintf(wbuf, "%d %d %d %d ",
		width, height, depth, components);

      s += wbuf;
      s += params->getParamString();

      //DBG(dbg) << "popen: "<<s<<"\n";

      // XXX SECURITY
      FILE *f = popen(s.c_str(), "r");

      if(f == 0) {
	  cerr << "POPEN FAILED!!! "<<s<<"\n"<<strerror(errno)<<"\n";
	  return;
      }

      fread(data, sizeof(float), width * height * depth * components, f);

      pclose(f);

  }

  virtual ~PipeTexture() {
  }
};

Texture *Texture::getTexture(const char *type) {
    return new PipeTexture(string(type));
}

}}



