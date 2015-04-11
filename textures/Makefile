.SUFFIXES: $(SUFFIXES) .texture .bin

include rules.mk

#EXTRAOBJS := ../util/Debug.o

TEXTURE_OBJS := $(shell for file in *.texture; do echo $${file%.texture}.o; done)
TEXTURE_EXES := $(shell for file in *.texture; do echo $${file%.texture}.bin; done)
LIBS = -lglut
FINDSRC := .

all: Texture_decl.generated.hxx Texture_const.generated.cxx Perlin.o Texture.o $(TEXTURE_OBJS) $(TEXTURE_EXES) Texture_gettexture.o Texture_pipetexture.o

# We have some extra here, since these need to be really fast
OPTFLAGS=-O3 -ffast-math

%.o : %.texture Texture.hxx Makefile
	file=$<; \
	name=$${file%.texture}; \
	{ echo "#include \"Texture.hxx\""; \
	  echo "#define GENERATE $$name::render"; \
	  echo "namespace Vob {namespace Texture { struct $$name : Texture {"; \
	  echo "virtual void render(TextureParam *, int, int, int, int, float *);"; \
	  echo "};"; echo "#line 1 \"$<\""; \
	  cat $<; echo "}}"; } > $${name}_tmp.generated.cxx; \
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) -x c++ -c $${name}_tmp.generated.cxx -o $@        

%.bin : %.texture binmain.o Texture.o $(EXTRAOBJS) Makefile
	file=$<; \
	name=$${file%.texture}; \
	{ echo "#include \"Texture.hxx\""; \
	  echo "#define GENERATE $$name::render"; \
	  echo "namespace Vob {namespace Texture { struct $$name : Texture {"; \
	  echo "virtual void render(TextureParam *, int, int, int, int, float *);"; \
	  echo "};"; echo ""; \
	  echo "Texture *bin_texture = new $$name();"; echo "#line 1 \"$<\""; \
	  cat $<; echo "}}"; } > $${name}_tmp2.generated.cxx; \
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) $${name}_tmp2.generated.cxx Texture.o binmain.o $(EXTRAOBJS) -o $@ Perlin.o 

Texture_decl.generated.hxx: *.texture
	for file in *.texture; do \
		name=$${file%.texture}; \
		echo "struct $$name : Texture {"; \
		echo "virtual void render(TextureParam *, int, int, int, int, float *);"; \
		echo "};"; echo ""; \
	done > Texture_decl.generated.hxx

Texture_const.generated.cxx: *.texture
	for file in *.texture; do \
		name=$${file%.texture}; \
		echo "if (strcmp(type, \"$$name\") == 0) return new $$name;"; \
	done > Texture_const.generated.cxx

Perlin.cxx: Perlin.hxx
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) -c Perlin.cxx -o $@

clean:
	find $(FINDSRC) -name "*.dep" |xargs rm -f
	find $(FINDSRC) -name "*.bin" |xargs rm -f
	find $(FINDSRC) -name "*.generated.*"|xargs rm -f
	find $(FINDSRC) -name "*.o" |xargs rm -f
	find $(FINDSRC) -name "*.js" |xargs rm -f
	find $(FINDSRC) -name "*.json" |xargs rm -f
	rm -f $(GENSRC)
