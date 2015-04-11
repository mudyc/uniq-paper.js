/*
Texture_gettexture.cxx
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

using std::cout;

#include "Texture.hxx"

namespace Vob { namespace Texture {

#include "Texture_decl.generated.hxx"

Texture *Texture::getTexture(const char *type) {
#include "Texture_const.generated.cxx"
  cout << "Unknown texture type " << type << "\n";
  abort();
}
}}


