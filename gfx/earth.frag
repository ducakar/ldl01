const   float     TAU        = 6.2832;

uniform sampler2D nightImage;
uniform float     times[2];

vec4 effect(vec4 colour, sampler2D dayImage, vec2 imageCoords, vec2 screenCoords)
{
  vec4  daySample   = texture2D(dayImage, imageCoords);
  vec4  nightSample = texture2D(nightImage, imageCoords);

  // Calculate the point (= normal) on the earth sphere from texture coordinates.
  float phi         = (imageCoords.s - 0.5 + times[0] / 86400.0) * TAU;
  float theta       = (0.5 - imageCoords.t) * TAU / 2.0;
  vec2  normal      = vec2(cos(phi) * cos(theta), sin(theta));

  // Calculate sun light vector tilt besed on the time of the year.
  float tilt        = cos(times[1] / 365.25 * TAU) * 0.4084;
  vec2  sunLight    = vec2(cos(tilt), sin(tilt));

  // Light intensity.
  float intensity   = clamp(0.5 - 2.0 * dot(sunLight, normal), 0.0, 1.0);

  return mix(nightSample, daySample, intensity);
}
