% Disersion of nanoparticles in a microchannel - Slip flow regime
clc,clear

% Particle data
d = 0.01e-6; % Particle's diameter
Ro_p = 2500; % Density of particle
Vol_p = pi*(d^3)/6; % Particle's volume
Mp = Ro_p*Vol_p; % Particle's mass
g = 9.81; % Gravitational acceleration

% Fluid data
Re=100; % Reynolds
Kn=0.1; % Knudsen
Ro_f=1.225; % Density of fluid
L=7e-6; % Mean free path
mu=1.983e-5; % Dynamic viscosity
nu=mu/Ro_f; % Kinematic viscosity
Ma=Ro_f*Vol_p; % Mass of replaced fluid

% Channel data
H=L/(4*Kn); % Half of channel height
D=4*H; % Characteristic length
u=nu*Re/(D); % Average velocity in channel

% Velocity profile
dp_dx= -12*mu*u/(D^2); % Pressure loss in channle
y=linspace(-H,H,100);
sigma=0.9;
UF=(H^2/(2*mu))*(-dp_dx)*(1-(y/H).^2+8*(2/sigma-1)*Kn);

% Plot velocity profile
figure(1)
plot(UF,y)
axis([0 1.5*max(UF) -H H])
title('Velocity Profile')
xlabel('u (m/s)')
ylabel('2H (m)')
legend('Re=100 Kn=0.01')