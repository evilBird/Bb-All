varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

precision mediump float;

void main() {
    // normalize to the center
    vec2 p = textureCoordinate - 0.5;
    
    // cartesian to polar coordinates
    float r = length(p);
    float a = atan(p.y, p.x);
    
    // kaleidoscope
    float sides = 6.;
    float tau = 2. * 3.1416;
    a = mod(a, tau/sides);
    a = abs(a - tau/sides/2.);
    
    // polar to cartesian coordinates
    p = r * vec2(cos(a), sin(a));
    
    // sample the image
    vec4 color = texture2D(inputImageTexture, p + 0.5);
    gl_FragColor = color;
}