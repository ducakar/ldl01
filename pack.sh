#!/bin/sh

version='0.0'
images=`find base gfx -name '*.png' -o -name '*.jpg'`
sounds=`find base sfx -name '*.wav' -o -name '*.ogg'`
scripts=`echo *.{lua,md}`

optipng -o7 -zm1-9 ${images}

zip -9r ldl01-${version}.love ${images} ${sounds} ${scripts}
