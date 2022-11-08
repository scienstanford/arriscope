%% s_MPE_SonyLights
%

% Note that the uv, blue, green and red Sony lights were set to a much
% lower light level - not sure why we did this .. (perhaps Jared remembers)

% Calculate the maximum permissible exposure (MPE) for the Sony lights
%
% The safety function curves used in this and related calculations are
% stored in data/human/safetyStandard.
%
%   Actinic         - UV hazard for skin and eye safety The limits for
%                     exposure to ultraviolet radiation incident upon the
%                     unprotected skin or eye (4.3.1 and 4.3.2)
%
% There are two other types of safety calculations that we include in
% related scripts
%
%   blueLightHazard - Eye (retinal) safety (retinal photochemical injury
%                     from chronic blue-light exposure).  There are
%                     different functions for large and small field lights
%                     (4.3.3 and 4.3.4)
%   burnHazard      - Retinal thermal injury (4.3.5 and 4.3.6)
%
% The data for the safety function curves were taken from this paper
%
%  IEC 62471:2006 Photobiological Safety of Lamps and Lamp Systems. n.d.
%  Accessed October 5, 2019. https://webstore.iec.ch/publication/7076
%  J.E. Farrell has a copy of this standard
%
% Notes:   Near UV is also called UV-A and is 315-400nm.
%
% Calculations
%  We load in a radiance (Watts/sr/nm/m2), convert it to irradiance
%
%      Irradiance = Radiance * pi
%
% Question: How does IEC 62471:2006 differ from ANSI Z136.1-2014
%

%% make sure these libraries are on your path
cd /Users/joyce/Github/isetcam;
addpath(genpath(pwd));
cd /Users/joyce/Github/isetfluorescence;
addpath(genpath(pwd));
cd /users/joyce/Github/oraleye/;
addpath(genpath(pwd));
cd /users/joyce/Github/isetcornellbox/;
addpath(genpath(pwd));
cd /users/joyce/Github/arriscope/;
addpath(genpath(pwd));
cd /users/joyce/Github/cholesteotoma/;
addpath(genpath(pwd));

%%
ieInit;
wave = 300:900;
nWaves = length(wave);

%% Sanity check - or why I think the numbers may be too high

% This is a 405 nm laser diode light source, and the MPE is 
% (116445.205603 (min) or 1940.8 hours (1.9408e+03)
% This light is brighter than the lights that were measured in this study
% Price, Richard B., et al. "The potential %blue light hazard from LED headlamps." Journal of Dentistry 125 (2022): 104226.
% Maximum exposure times  for indirect viewing (reflected)of blue lights used in dental curing range
% between 410 and 74 hours 

%6 brands of LED headlamps were measured using integrating spheres attached to fiberoptic spectroradiometers. 
% The spectral radiant powers were measured both directly and indirectly at a 35 cm distance, 
% and the maximum daily exposure times (tMAX) were calculated from the blue weighted irradiance values.

fname = which('light405.mat'); 
% this light is 5000 times brighter than the Lumadent light which has a
% maximum daily exposure between 53-220 seconds according to Price et al (2022) 
% in "The potential iblue light hazardn from LED headlamps", Journal of
% dentistry

radiance = ieReadSpectra(fname,wave);
plotRadiance(wave,radiance); 
% irradiance = pi*radiance;

exposureMinutes = humanUVSafety(radiance,wave,'method','bluehazard');
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',exposureMinutes) % this is not correct - it is returning val and not calculating max exposure
[val, level, safety] = humanUVSafety(radiance,wave,'method','thermalskin');

%{
The maximum permissible exposure time per 8 hours for ultraviolet radiation
incident upon the unprotected eye or skin shall be computed by:

t_max = 30/E_s   (seconds) (Equation 4.2)

E_s is the effective ultraviolet irradiance (W/m^2).  The formula for E_s
is defined in Equation 4.1.  It is the inner product of the Actinic
function and the irradiance function, accounting for time and wavelength
sampling.

%}
fprintf('Maximum exposure duration per eight hours:  %f (min)\n',(30/hazardEnergy)/60);

%% 
radiance = ieReadSpectra('arriLights.mat',wave); % Nwaves x 7 (7 lights)
plotRadiance(wave,radiance);
legend('405 nm','445 nm','525 nm', '638 nm', 'arri white', 'Sony white', '808 nm' )
irradiance = zeros(nWaves,7);
exposureMinutes = zeros(1,7);
hazardEnergy = zeros(1,7);
tmp = zeros(1,7);
exposureTime = 10; % seconds

for ii = 1:7
    irradiance(:,ii) = pi*radiance(:,ii);
      exposureLevel(:,ii) = humanUVSafety(irradiance(:,ii),wave,'method','thermalskin','duration',exposureTime); %
end

for ii = 1:7
 fprintf('Energy level for 10 second exposure:  %f \n',exposureLevel(:,ii))
end

% MPE = 20000 * exposureTime^0.25;
for ii = 1:7
 fprintf('MPE is greater by a factor of %f \n',MPE/exposureLevel(:,ii))
end

figure;
for ii = 1:7
    plot(wave,irradiance(:,ii)); hold on; pause;
end

%% compare lights 
% The intensity of the lights were chosen to be much lower than the lights
% we are using in the Cholesteatoma study.  
% we used the PR715 
% correction factor?

arriLights = ieReadSpectra('arriLights.mat',wave);

figure;
light405 = ieReadSpectra('light405.mat',wave); 
light450 = ieReadSpectra('light450.mat',wave);
light520 = ieReadSpectra('light520.mat',wave);
plot(wave,light405,'c','LineWidth',2);hold on;
plot(wave,light450,'b','LineWidth',2);
plot(wave,light520,'g','LineWidth',2);
legend('uvChole','blueChole','greenChole');

figure; 
plot(wave,arriLights (:,1),'c--','LineWidth',2); hold on;
plot(wave,arriLights (:,2),'b--','LineWidth',2);
plot(wave,arriLights (:,3),'g--','LineWidth',2);
plot(wave,arriLights (:,4),'r--','LineWidth',2);
plot(wave,arriLights (:,5),'k--','LineWidth',2);
plot(wave,arriLights (:,6),'k:','LineWidth',2);
plot(wave,arriLights (:,7),'m--','LineWidth',2);
legend('uv', 'blue','green','red','whiteArriscope','whiteSony','IR');


%%
% Velscope.mat - was this light measured with PR715 or PF670 with PTB software
% figure;
% LED405.mat (for OralEye study) - was this measured with PR715 or PF670 with PTB software
% if it was measured with PR670 with PTB software then it should be divided
% by 5 (recall that the PTB software calculates power over a 5 nm waveband
% rather than report the power at a single wavelength 
% 

%%
See which lights need to be corrected
wave = 300:900;

figure;
radiance = ieReadSpectra('OralEye_385.mat',wave);
plot(wave,radiance); hold on;
radiance = ieReadSpectra('OralEye_UV.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('LED400.mat',wave);
plot(wave,radiance); hold on;
radiance = ieReadSpectra('LED405.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('LED425.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('LED450.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('Velscope.mat',wave);
plot(wave,radiance); hold on;


figure;
radiance = ieReadSpectra('tungsten.mat',wave);
plot(wave,radiance); hold on;
radiance = ieReadSpectra('OralEye_White.mat',wave);
plot(wave,radiance); hold on;
radiance = ieReadSpectra('tungsten_NoFilter.mat',wave);
plot(wave,radiance); hold on;

figure;
radiance = ieReadSpectra('NitrogenLaser337nm.mat',wave);
plot(wave,radiance); hold on;			
radiance = ieReadSpectra('LEDBlueFlood.mat',wave);
plot(wave,radiance); hold on;

	
	% were these lights normalized?
    figure;
    radiance = ieReadSpectra('LEDCoolWhite.mat',wave); % this is way off -
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('LEDNeutralWhite.mat',wave);
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('LEDWarmWhite.mat',wave);
    plot(wave,radiance); hold on;


    %%
    % large scale
    figure;
    radiance = ieReadSpectra('D65.mat',wave);
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('D75.mat',wave);
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('D50.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('D55.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('D75.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('Fluorescent.mat',wave);
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('Fluorescent2.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('Fluorescent11.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('FluorescentOffice.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('illuminantA.mat',wave);
    plot(wave,radiance);hold on;
    radiance = ieReadSpectra('illuminantB.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('illuminantC.mat',wave);
    plot(wave,radiance);
    radiance = ieReadSpectra('LED385nm.mat',wave);
    plot(wave,radiance); hold on;
    radiance = ieReadSpectra('LED405nm.mat',wave);
    plot(wave,radiance);

% small scale
figure;
radiance = ieReadSpectra('VivitarFlash.mat',wave);
plot(wave,radiance);hold on;
radiance = ieReadSpectra('DaylightPsychBldg.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('daylightSpectra.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('halogen_2913.mat',wave);
plot(wave,radiance); hold on;
radiance = ieReadSpectra('illA-20180220.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('illA-20201023.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('illCWF-20180220.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('illCWF-20201023.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('illDay-20201023.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('illHorizon-20180220.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('Tungsten.mat',wave);
plot(wave,radiance);
%% Some are scaled between 0 and 1
figure;
radiance = ieReadSpectra('LED_1839.mat',wave);
plot(wave,radiance);hold on;
radiance = ieReadSpectra('LED_2977.mat',wave);
plot(wave,radiance);
radiance = ieReadSpectra('Traffic_amber.mat',wave);
plot(wave,radiance); 
radiance = ieReadSpectra('Traffic_green.mat',wave);
plot(wave,radiance); 
radiance = ieReadSpectra('Traffic_red.mat',wave);
plot(wave,radiance); 
radiance = ieReadSpectra('blueLEDFlood.mat',wave);
plot(wave,radiance);


% LEDs having output wavelengths in the 400-465 nanometer range exhibit power levels exceeding 20 milliwatts/cm2, whereas 
% most of the longer wavelength-emitting LEDs (green through red) have power outputs of less than 10 milliwatts/cm2
% In contrast, violet and blue LEDs having light outputs of 250 and 150 milliwatts, respectively, 
% are now commercially available and similar powers in other wavelengths should be available in the near future.

% The single most useful number in laser safety calculations is the maximum permissible exposure. 
% This is the minimum irradiance or radiant exposure that may be incident upon the eye or skin without 
% causing biological damage. The MPE varies by wavelength and duration of exposure and is documented in 
% tables published in ANSI z136.1 standard. 
% Think of the MPE as your laser safety speed limit.
% The ANSI 136.1 standard tables 5, 6, and 7 summarize the MPE for particular wavelengths and exposure durations.  

% The ANSI Z136.1 Laser Safety Standard is the best reference to consult for laser safety information.
%%

figure;
cd '/Volumes/GoogleDrive/.shortcut-targets-by-id/1mxeS80kjMboS0mvMNilCR5SZhvY0i1rv/Natural spectra dynamic range/2022-10-31/Courtyard';
radiance = ieReadSpectra('spd-2022-10-31-cloudySky.mat',wave);
plot(wave,radiance);hold on;
radiance = ieReadSpectra('light405.mat',wave);
plot(wave,radiance);
