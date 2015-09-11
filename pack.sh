#!/bin/sh

version='0.0'
images=`find gfx -name '*.png' -o -name '*.jpg'`
sounds=`find sfx -name '*.wav' -o -name '*.ogg'`
scripts=`find . -name '*.lua' -o -name '*.md'`

optipng -o7 -zm1-9 ${images}

zip -9r ldl01-${version}.love ${images} ${sounds} ${scripts}
