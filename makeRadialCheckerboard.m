function checks = makeRadialCheckerboard(diam, rcycles, tcycles)
%diam = 200;
%rcycles = 4;
%tcycles = 10;
white = 1;
black = 0;
%grey = white/2;

xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (diam - 1): xylim,...
    -xylim: 2 * xylim / (diam - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* checks; % + grey * ~circle;

end