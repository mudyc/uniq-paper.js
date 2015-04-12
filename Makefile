

all:

	mkdir -p dist

	coffee -cb -o dist/ src/

  # coffee to js
	cat \
	  dist/pmill.js \
	  dist/textures.js \
	  dist/shader.js \
	  > dist/uniq-paper.js

  # combine javascript files into distributed file
	cat \
	  textures/js/rgbw1.js \
	  textures/js/rgbw2.js \
	  textures/js/rgbw3.js \
	  textures/js/turb.js \
	  textures/js/pyramid.js \
	  textures/js/cone.js \
	  textures/js/saw.js \
	  textures/js/triangle.js \
	  textures/js/rnd0.js \
	  textures/js/rnd1.js \
	  textures/js/rnd2.js \
	  textures/js/stripe.js \
	  textures/js/rnd0n.js \
	  textures/js/rnd1n.js \
	  textures/js/rnd2n.js \
	> dist/uniq-paper-textures.js


