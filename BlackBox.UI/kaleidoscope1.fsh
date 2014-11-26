varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main(void){
    
  highp vec2 sampleDivisor = vec2(0.1, 0.1);
  highp float iGlobalTime = 5;
  highp float PI = 3.141592658;
  highp float TAU = 2.0 * PI;
  highp float sections = 10.0;
  highp vec2 pos = textureCoordinate - mod(textureCoordinate, sampleDivisor);
  highp float rad = length(pos);
  highp float angle = atan(pos.y, pos.x);
  highp float ma = mod(angle, TAU/sections);
  ma = abs(ma - PI/sections);
  
  highp float x = cos(ma) * rad;
  highp float y = sin(ma) * rad;
	
  highp float time = 2.0;
  
  gl_FragColor = texture2D(inputImageTexture, vec2(x-time, y-time));
}

float Tile1D(float p, float a){
  p -= 4.0 * a * floor(p/4.0 * a);
  p -= 2.* max(p - 2.0 * a , 0.0);
  return p;
}