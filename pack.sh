#!/bin/sh

version='0.0'
images=`find gfx -name '*.png'`
sounds=`find sfx -name '*.ogg'`
scripts=`find . -name '*.lua' -o -name '*.md'`

#optipng -o7 -zm1-9 ${images}
optipng ${images}

zip -9r ldl01-${version}.love ${images} ${sounds} ${scripts}
