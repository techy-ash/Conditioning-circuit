clc;
clear;
close all;

% Desired center frequency
f0 = 6000;              % 6 kHz
w0 = 2*pi*f0;

Q = 5;                  % filter selectivity

% Simulation parameters
fs = 200e3;             % sampling for simulation
dt = 1/fs;
t = 0:dt:0.02;

% Test signal (multiple frequencies)
u = sin(2*pi*6000*t) + 0.5*sin(2*pi*2000*t) + 0.5*sin(2*pi*12000*t);

% First SVF states
x1 = zeros(size(t));
x2 = zeros(size(t));

% Second SVF states
x3 = zeros(size(t));
x4 = zeros(size(t));

% Output
y = zeros(size(t));

for n = 2:length(t)

    % ----- SVF Stage 1 -----
    dx1 = x2(n-1);

    dx2 = -w0^2*x1(n-1) ...
          - (w0/Q)*x2(n-1) ...
          + w0^2*u(n-1);

    x1(n) = x1(n-1) + dx1*dt;
    x2(n) = x2(n-1) + dx2*dt;

    bp1 = x2(n);    % bandpass output


    % ----- SVF Stage 2 -----
    dx3 = x4(n-1);

    dx4 = -w0^2*x3(n-1) ...
          - (w0/Q)*x4(n-1) ...
          + w0^2*bp1;

    x3(n) = x3(n-1) + dx3*dt;
    x4(n) = x4(n-1) + dx4*dt;

    y(n) = x4(n);   % final output

end

% Plot time response
figure
subplot(2,1,1)
plot(t,u)
title('Input Signal')
xlabel('Time (s)')

subplot(2,1,2)
plot(t,y,'LineWidth',1.5)
title('Filtered Output (6 kHz Bandpass)')
xlabel('Time (s)')
grid on

N = length(y);
Y = fft(y);
f = (0:N-1)*(fs/N);

figure
plot(f,20*log10(abs(Y)/max(abs(Y))))
xlim([0 20000])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
title('Output Spectrum')
grid on