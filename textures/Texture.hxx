/*
Texture.hxx
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

#ifndef __TEXTURE_HXX
#define __TEXTURE_HXX

#include <string>

namespace Vob {

/** Pre-rendered procedural textures.
 */
namespace Texture {

class TextureParamImpl;

class TextureParam {
public:
  virtual float getFloat(const char *name, float def = 0) const; 
  virtual const char *getString(const char *name, const char *def = 0) const;
  virtual void setParam(const char *name, const char *value);

  /** Get the index of the parameter value in the null terminated enum list */
  int getStringEnum(const char *name, int def, /* enum values */ ...) const;

  std::string getParamString();

  TextureParam();
  virtual ~TextureParam(); 

protected:
  TextureParamImpl *impl;
};

class Texture {
public:
  virtual void render(TextureParam *params, 
		      int width, int height, int depth, int components, float *data) = 0;

  virtual ~Texture() = 0;
  static Texture *getTexture(const char *type);
};
}
}

#include "Perlin.hxx"

#endif
