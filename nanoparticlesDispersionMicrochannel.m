% Disersion of nanoparticles in a microchannel - Slip flow regime
clc,clear

% Particle data
np = 5;    % Number of particles
d = 0.01e-6; % Particle's diameter
Ro_p = 2500; % Density of particle
Vol_p = pi*(d^3)/6; % Particle's volume
Mp = Ro_p*Vol_p; % Particle's mass
g = 9.81; % Gravitational acceleration

% Fluid data
Re = 100; % Reynolds
Kn = 0.1; % Knudsen
Ro_f = 1.225; % Density of fluid
L = 7e-6; % Mean free path
mu = 1.983e-5; % Dynamic viscosity
nu = mu/Ro_f; % Kinematic viscosity
Ma = Ro_f*Vol_p; % Mass of replaced fluid

% Channel data
H = L/(4*Kn); % Half of channel height
D = 4*H; % Characteristic length
u = nu*Re/(D); % Average velocity in channel

% Velocity profile
dp_dx = -12*mu*u/(D^2); % Pressure loss in channle
y = linspace(-H,H,100);
sigma = 0.9;
UF = (H^2/(2*mu))*(-dp_dx)*(1-(y/H).^2+8*(2/sigma-1)*Kn);

% Plot velocity profile
figure(1)
plot(UF,y)
axis([0 1.5*max(UF) -H H])
title('Velocity Profile')
xlabel('u (m/s)')
ylabel('2H (m)')
legend('Re=100 Kn=0.01')

% Constants and parameters needed
k = 1.38e-23; % Boltzmann constant [j/K]
T = 297;  % Temperature
Cc = 1+2*L/(d)*(1.257+0.4*exp(-1.1*d/(2*L))); % Cunningham correction factor
tow = Cc*Mp/(3*pi*mu*d); % Particle relaxation time
s_nn=2*k*T/(tow*pi*Mp); % Used in brownian force

dt = 0.01*tow; % Time step
it = 2000;  % Iteration/steps goint forward in time
n = zeros(1,np); % Counting steps of each particle

% Some predefined arrays for results (helps with the code speed)
% Velocity and position storage
vel_u = zeros(np,it);
vel_v = zeros(np,it);
pos_x = zeros(np,it);
pos_y = zeros(np,it);

% Brownian storage
BrF_x = zeros(np,it);
BrF_y = zeros(np,it);

% Drag force storage
Drag_x = zeros(np,it);
Drag_y = zeros(np,it);

% Saffman lift force Storage
Saffmanstore = zeros(np,it);

% Added mass (negligible)-(not included in u and v velocities)
Addedmass_x = zeros(np,it);
Addedmass_y = zeros(np,it);

for i=1:np
    j=1;              % Initial step
    Xp_old = 0;       % Initial x-pos of particle
    Yp_old = 0;       % Initial y-pos of particle
    Up_old = max(UF); % Initial u-vel of particle
    Vp_old = 0;       % Initial v-vel of particle
    
    vel_u(i,j)=Up_old;% Storing
    vel_v(i,j)=Vp_old;
    
    j=2;              % Second Step
    while (Xp_old<=20*H && abs(Yp_old)<0.95*H) % Reching end of channel or getting close to the wall
        % Brownian force (randomly generated)
        Brfx = Mp*randn*sqrt(pi*s_nn/dt);
        Brfy = Mp*randn*sqrt(pi*s_nn/dt);
        
        % Fluid velocity at certain y location. uf(Yp-old).
        uf = (H^2/(2*mu))*(-dp_dx)*(1-(Yp_old/H)^2+8*(2/sigma-1)*Kn);
        
        % Added mass force
        FAdX = Mp*18*Ma*nu/(d^2)*(uf-Up_old); 
        FAdY = Mp*18*Ma*nu/(d^2)*(-Vp_old);
        
        % Particle u-velocity from newton law. x-dir
        Up_new = (1/(1+dt/tow)) * ( Up_old+ ((dt/tow) *uf) + dt*(Brfx/Mp));
        
        % Step in x-pos
        Xp_new = Xp_old+dt*Up_new;
        % Store the new x-position
        pos_x(i,j) = Xp_new;
        % Store the new u-velocity
        vel_u(i,j) = Up_new;
        % Store the Drag x-force
        Drag_x(i,j) = (Mp/tow) * (uf-Up_new);
        
        % Calculate the Saffman lift force. Based on particle u-velocity
        f_saf = 1.615*Ro_f*nu^.5*d^2*(uf-Up_new)*sqrt(abs((H^2/(2*mu))*(-dp_dx)*(-2*Yp_old/H^2)))*sign((H^2/(2*mu))*(-dp_dx)*(-2*Yp_old/H^2));
        Saffmanstore(i,j) = f_saf; % Storing Saffman force
        
        % Particle v-velocity from newton law. y-dir
        Vp_new = (1/(1+dt/tow)) * (Vp_old + dt*( (Brfy/Mp) + f_saf + (g*Ro_f/Ro_p) - g ) );
        % Step in y-pos
        Yp_new = Yp_old+dt*Vp_new;
        % Store the new y-position
        pos_y(i,j) = Yp_new;
        % Store the new v-velocity
        vel_v(i,j)= Vp_new;
        % Store the Drag v-force
        Drag_y(i,j)= (Mp/tow) * (Vp_new);
        
        % Store the Brownian force
        BrF_x(i,j) = Brfx;
        BrF_y(i,j) = Brfy;
        
        Addedmass_x(i,j) = FAdX;
        Addedmass_y(i,j) = FAdY;    
        
        Xp_old = Xp_new; % Put new-pos into the old-pos for next iteration
        Yp_old = Yp_new;
        Up_old = Up_new;
        Vp_old = Vp_new;
        
        n(1,i)=n(1,i)+1; % Counting the number of steps eacg particle pass
        j=j+1; % Going to next time step or iteration
        
    end
end

% The particles path
figure(2)
for i=1:np
   hold on
   plot(pos_x(i,1:n(i)),pos_y(i,1:n(i)))
end

% Position history of particle #1 1
P1_s = pos_x(1,1:n(1));

figure(3)
plot(P1_s, BrF_x(1,1:n(1)))
title('Brownian Force_X')

figure(4)
plot(P1_s, BrF_y(1,1:n(1)))
title('Brownian Force_Y')

figure(5)
plot(P1_s, Saffmanstore(1,1:n(1)))
title('Saffman Lift Force')

figure(6)
plot(P1_s, Drag_x(1,1:n(1)))
title('Drag Force x')

figure(7)
plot(P1_s, Drag_y(1,1:n(1)))
title('Drag Force y')
