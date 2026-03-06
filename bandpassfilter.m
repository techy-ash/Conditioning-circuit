clc;
clear;
close all;

%% Simulation parameters
fs = 200e3;                 % simulation sampling frequency
dt = 1/fs;
t = 0:dt:0.02;

%% ===============================
% Generate Composite Input Signal
%% ===============================

% Component A – Low Frequency Drift
A_amp = 0.8/2;              % convert Vpp to peak
A = A_amp*sin(2*pi*600*t);

% Component B – Usable Information Signal
B_amp = 0.4/2;
B = B_amp*sin(2*pi*6000*t);

% Component C – Structured Interference
C_amp = 1.2/2;
C = C_amp*sign(sin(2*pi*18000*t));   % square wave

% Component D – High Frequency Interference
D_amp = 2.0/2;
D = D_amp*sin(2*pi*55000*t);

% Component E – Broadband Noise
E = 0.15*randn(size(t));

% Composite signal
u = A + B + C + D + E;

%% ===============================
% State Variable Filter Parameters
%% ===============================

f0 = 6000;                  % center frequency
w0 = 2*pi*f0;

Q = 6;                      % selectivity

% State variables (two cascaded SVFs)
x1 = zeros(size(t));
x2 = zeros(size(t));
x3 = zeros(size(t));
x4 = zeros(size(t));

y = zeros(size(t));

%% ===============================
% SVF Simulation
%% ===============================

for n = 2:length(t)

    % ----- First SVF -----
    dx1 = x2(n-1);

    dx2 = -w0^2*x1(n-1) ...
          - (w0/Q)*x2(n-1) ...
          + w0^2*u(n-1);

    x1(n) = x1(n-1) + dx1*dt;
    x2(n) = x2(n-1) + dx2*dt;

    bp1 = x2(n);

    % ----- Second SVF (cascade) -----
    dx3 = x4(n-1);

    dx4 = -w0^2*x3(n-1) ...
          - (w0/Q)*x4(n-1) ...
          + w0^2*bp1;

    x3(n) = x3(n-1) + dx3*dt;
    x4(n) = x4(n-1) + dx4*dt;

    y(n) = x4(n);

end

%% ===============================
% Time Domain Plots
%% ===============================

figure

subplot(2,1,1)
plot(t,u)
title('Composite Input Signal')
xlabel('Time (s)')
ylabel('Amplitude (V)')

subplot(2,1,2)
plot(t,y)
title('Filtered Output (6 kHz Dominant)')
xlabel('Time (s)')
ylabel('Amplitude (V)')
grid on

%% ===============================
% Frequency Spectrum
%% ===============================

N = length(y);
Y = fft(y);
f = (0:N-1)*(fs/N);

figure
plot(f,20*log10(abs(Y)/max(abs(Y))))
xlim([0 80000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Output Spectrum')
grid on