clear all
close all
%TMz Polarization
%physical constants
c    = 2.998e8;
eta0 = 120*pi;
mu0  = pi*4e-7;
eps0 = 1e-9/(36*pi);
%environment parameters
nx = 249;
ny = 249;
delta = 1.2e-2; %1.2cm
dx = delta;
dy = delta;
dt   = 20e-12; %0.95/(c*sqrt(dx^-2+dy^-2));
%f0     = 2e9; %2GHz
tw     = 16*dt;
t0     = 200*dt;
srcx = round(nx/2);
srcy = round(ny/2);
eps_r = 4.58;
sigma = 0.52; %S/m
ksi = (dt * sigma) / ( 2 * eps0 * eps_r );
%calculation parameters
n_iter = 500;
%initalization
Hx = zeros(nx,ny);
Hy = zeros(nx,ny);
Ez = zeros(nx,ny);
receivers = zeros(23,n_iter);
%iteration
for n=1:1:n_iter
    %Maxwell Equations (TMz)
    Ezx = diff(Ez,1,1);
    Ezy = diff(Ez,1,2);
    Hx(2:nx-1,2:ny) = Hx(2:nx-1,2:ny) - (dt/(mu0*dy))*Ezy(2:nx-1,:);
    Hy(2:nx,2:ny-1) = Hy(2:nx,2:ny-1) + (dt/(mu0*dx))*Ezx(:,2:ny-1);
    Hxy = diff(Hx,1,2);
    Hyx = diff(Hy,1,1);
    Ez(2:nx-1,2:ny-1) = ((1-ksi)/(1+ksi))*Ez(2:nx-1,2:ny-1) + ((1/(1+ksi))*(dt/(eps0*eps_r)))*((1/dx)*Hyx(2:nx-1,2:ny-1) - (1/dy)*Hxy(2:nx-1,2:ny-1));
    %Gaussian Source
    f(n)= (-2*(n*dt-t0)*dt/(tw^2))*exp(-(n*dt-t0)^2/(tw^2))/dy;
    Ez(srcx,srcy) = Ez(srcx,srcy) + f(n);
    %Neuman Condition
    Ez(:,2)  = -Ez(:,1);
    Ez(2,:)  = -Ez(1,:);
    Ez(:,ny-1) = -Ez(:,ny);
    Ez(nx-1,:) = -Ez(nx,:);
    %display
    %n = n + 1;
    for i=1:1:23
        receivers(i,n) = Ez(i*10,srcy);
    end
    pcolor(Ez')
    colorbar
    shading interp
    title(n)
    drawnow
end

plot(f)

save('bitirme5.mat','receivers');


