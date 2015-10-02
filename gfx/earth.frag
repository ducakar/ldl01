const float       TAU        = 6.2832;

uniform sampler2D nightImage;
uniform float     dayTime;
uniform float     yearTime;

vec4 effect(vec4 colour, sampler2D dayImage, vec2 imageCoords, vec2 screenCoords)
{
  vec4  daySample   = texture2D(dayImage, imageCoords);
  vec4  nightSample = texture2D(nightImage, imageCoords);

  // Calculate the point (= normal) on the earth sphere from texture coordinates.
  float phi         = (imageCoords.s - 0.5) * TAU + dayTime / 86400.0 * TAU;
  float theta       = (imageCoords.t - 0.5) * TAU / 2.0;
  vec3  normal      = vec3(vec2(cos(phi), sin(phi)) * cos(theta), sin(theta));

  // Calculate sun light vector tilt besed on the time of the year.
  float tilt        = cos(yearTime / 365.25 * TAU) * -0.4084;
  vec3  sunLight    = vec3(-cos(tilt), 0.0, sin(tilt));

  // Light intensity.
  float intensity   = clamp(0.25 + dot(sunLight, normal) * 1.0, 0.0, 1.0);

  return mix(nightSample, daySample, intensity);
}
