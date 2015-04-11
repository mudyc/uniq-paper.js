/*
Texture.cxx
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

using std::string;

using namespace std;
struct Param {
  string name;
  string value;
};

class TextureParamImpl {
public:
  const Param *findParam(const char *name) const {
    for (unsigned i = 0; i < paramList.size(); i++) {
      if (paramList[i].name.compare(name) == 0) {
	return &paramList[i];
      }
    }
    return NULL;
  }

  void setParam(const char *name, const char *value) {
    for (unsigned i = 0; i < paramList.size(); i++)
      if (paramList[i].name.compare(name) == 0) {
	paramList[i].value = value;
	return;
      }
    Param newparam = { name, value };
    paramList.insert(paramList.end(), newparam);
  }

  string getParamString() {
      string ret;
      for(unsigned i=0; i<paramList.size(); i++) {
	  if(i>0) ret += " ";
	  ret += paramList[i].name;
	  ret += " ";
	  ret += paramList[i].value;
      }
      return ret;
  }

protected:
  vector<Param> paramList;
};


TextureParam::TextureParam() : impl(new TextureParamImpl) {} 
TextureParam::~TextureParam() { delete impl; }
string TextureParam::getParamString() { return impl->getParamString(); }


float TextureParam::getFloat(const char *name, float def) const { 
  const Param* p = impl->findParam(name); 
  return p ? atof(p->value.c_str()) : def; 
};

const char *TextureParam::getString(const char *name, const char *def) const { 
  const Param* p = impl->findParam(name); 
  return p ? p->value.c_str() : def; 
};

void TextureParam::setParam(const char *name, const char *value) {
  impl->setParam(name, value);
}

int TextureParam::getStringEnum(const char *name, int def, ...) const {
    const char *value = getString(name, "");
    if(!value) return def;
    const char *p;
    va_list ap;
    va_start(ap, def);
    int i;
    for (i = 0; (p = va_arg(ap, const char *)); i++) {
      if (strcmp(value, p) == 0) {
	va_end(ap);
	return i;
      }
    }
    va_end(ap);
    return def;
}

Texture::~Texture() { }
}}
