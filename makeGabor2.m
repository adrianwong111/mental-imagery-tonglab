function gaborS = makeGabor2(iwidth, freq, phz, theta, sd)
%iwidth = 100;
[x y] = meshgrid(linspace(-0.5,0.5,iwidth),linspace(-0.5,0.5,iwidth)); % work with range of 1
%freq = 4; % spatial frequency
%phz = 0; % phase is in absolute units of the space
phz = phz/freq/(2*pi); % convert phase, relative to frequency of the grating/Gabor
%theta = pi/2; % angle of grating or Gabor filter
%sd = 0.2; % standard deviation of Gaussian for specifying Gabor, should be 0.2 or less ideally
gauss = exp(-(x.^2+y.^2)/(2*sd^2)); % assume circular 2D Gaussian
Gs = sin(2*pi*freq * (x.*sin(theta) + y.*cos(theta) - phz)); % sine grating, if phz = 0
Gc = cos(2*pi*freq * (x.*sin(theta) + y.*cos(theta) - phz)); % cosine grating, if phz = 0
Gs = (Gs + 1)/2;
% note, phz refers to phase-shifting the pattern in desired direction, so it is subtracted here
gaborS = gauss.*Gs; % Gabor filter, odd-symmetric if phz = 0
gaborC = gauss.*Gc; % Gabor filter, even-symmetric if phz = 0
%imshow(gaborS)