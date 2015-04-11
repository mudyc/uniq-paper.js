GCCVER=3.3

.SUFFIXES: $(SUFFIXES) .dep .cxx .vobgenobj .transgenobj .vobdep .transdep .vobjniobj .transjniobj .vobgenjni .transgenjni .vobjnidep .transjnidep

#CXX=g++-$(GCCVER)
#CXXLINK=gcc-$(GCCVER)
CXX=g++
CXXLINK=g++

# Choose architecture
ARCHOPTS=-e 's/^model name.*Pentium III.*$$/-march=pentium3/' \
         -e 's/^model name.*Pentium(R) 4.*$$/-march=pentium4/' \
	 -e 's/^model name.*AMD Athlon(tm) XP.*$$/-march=athlon-xp/' \
	 -e 's/^model name.*AMD Athlon(tm) MP.*$$/-march=athlon-mp/' \
	 -e 's/^model name.*AMD Athlon(tm).*$$/-march=athlon/' \
         -e 's/^flags.*sse2.*$$/-mfpmath=sse -msse2/' \
         -e 's/^flags.*sse.*$$/-mfpmath=sse/' \
	 -e 's/^flags.*3dnow.*$$/-mfpmath=387 -m3dnow/' 
ARCH=$(shell [ ! -f /proc/cpuinfo ] || sed $(ARCHOPTS) -e "/^-/!d" /proc/cpuinfo)

# OPTIMIZE =  -O3 -ffast-math $(ARCH) -fomit-frame-pointer -foptimize-sibling-calls
# Better not omit frame pointer: java can sometimes show us where the problem is...

# OPTIMIZE =  -O3 -ffast-math $(ARCH) -foptimize-sibling-calls
# Disable ARCH for now, some crashes related to it
#OPTIMIZE =  -O3 -ffast-math -foptimize-sibling-calls

OPTIMIZE = -O0

# DBG=-g
DBG=

#CPPFLAGS = -I../include -I../../libvob-depends -I../../include $(EXTRAINCLUDE) -I../../callgl/include -I../../../callgl/include -I../../callgl/include/glwrapper -I../../../callgl/include/glwrapper -I../../glmosaictext/include -I../../../glmosaictext/include -I/usr/include/freetype2 `gdk-pixbuf-config --cflags`
CPPFLAGS=
CXXFLAGS = $(DBG) -Wall $(OPTIMIZE) $(CPPFLAGS)  
CCFLAGS = $(DBG) -Wall

SHARED = -shared

ifeq (,$(JAVAC))
	JAVAC=javac
endif

%.dep: %.cxx
	$(SHELL) -ec '$(CXX) -x c++ -M $(CPPFLAGS) $< \
                      | sed '\''s/\($*\)\.o[ :]*/\1.o $@ : /g'\'' > $@; \
                      [ -s $@ ] || rm -f $@'

%.vobjnidep: %.vobgenjni
	$(SHELL) -ec '$(CXX) -x c++ -M $(CPPFLAGS) $< \
                      | sed '\''s/\($*\)\.o[ :]*/\1.vobjniobj $@ : /g'\'' > $@; \
                      [ -s $@ ] || rm -f $@'
%.transjnidep: %.transgenjni
	$(SHELL) -ec '$(CXX) -x c++ -M $(CPPFLAGS) $< \
                      | sed '\''s/\($*\)\.o[ :]*/\1.transjniobj $@ : /g'\'' > $@; \
                      [ -s $@ ] || rm -f $@'

%.o: %.cxx
	$(CXX) -c $(CXXFLAGS) -o $@ $<
%.transjniobj: %.transgenjni
	$(CXX) -c $(CXXFLAGS) -o $@ -x c++ $<
%.vobjniobj: %.vobgenjni
	$(CXX) -c $(CXXFLAGS) -o $@ -x c++ $<
