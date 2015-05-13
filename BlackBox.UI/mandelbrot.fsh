varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

#ifdef GL_ES
precision mediump float;
#endif

#define maxIter 64

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec2 surfacePosition;

void main( void ) {
    
    vec2 c = textureCoordinate;
    c = c*2.;
    vec2 z = vec2(0);
    
    float I = 0.;
    
    for(int i=1; i<maxIter; i++)
    {
        z = vec2(pow(z.x, 2.)-pow(z.y, 2.),z.x*z.y*2.)+c;
        if(length(z)>32.)
        {
            //float zn = z.x*z.x+z.y*z.y;
            float zn=length(z);
            I=float(i);
            I=I+1.0-log2(log2(zn));
            break;
        }
    }
    
    gl_FragColor = vec4( sqrt(I)/sqrt(float(maxIter)) );
    
}