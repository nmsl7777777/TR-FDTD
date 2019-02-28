%physical constants
datetime('now')
clear all;
close all;
c    = 2.998e8;
eta0 = 120*pi;
mu0  = pi*4e-7;
eps0 = 1e-9/(36*pi);
%environment parameters
width  = 1;
height = 1;
length  = 1;
f0     =1e9;
tw     = 1e-8/pi;
t0     = 4*tw;
%discretization parameters
dx = 0.01;
dy = dx;
dz = dx;
nx = width/dx;
ny = height/dy;
nz = length/dz;
dt   = 0.95/(c*sqrt(dx^-2+dy^-2+dz^-2));
%source
srcx = nx / 2;
srcy = nz / 2;
srcz = 3 * ny / 4;
%material
adipose = 10;
tumor   = 60;
mx = 3 * ny / 8;
my = 0
mz = 0;
mw = nx / 4; % width
mh = ny / 4; % height
ml = nz / 4; % length
al = ny / 2;
eps = ones(nx,ny,nz) * eps0;
for i=1:1:nx
    for j=1:1:ny
       for k=1:1:nz
          if (k<al)
            eps(i,j,k) = eps0 * adipose ;  
          end
          if (i>mx && i<(mw+mx) && j>my && j<(mh+my) && k>mz && k<(ml+mz))
            eps(i,j,k) = eps0 * tumor;
          end
       end
    end
end
%calculation parameters
n_iter = 1000;
%initalization
Hx = zeros(nx,ny,nz);
Hy = zeros(nx,ny,nz);
Hz = zeros(nx,ny,nz);
Ex = zeros(nx,ny,nz);
Ey = zeros(nx,ny,nz);
Ez = zeros(nx,ny,nz);
%iteration
i = 0;
for n=1:1:n_iter
    %derivatives
    Hxy = diff(Hx,1,2);
    Hxz = diff(Hx,1,3);
    Hzx = diff(Hz,1,1);
    Hzy = diff(Hz,1,2);
    Hyx = diff(Hy,1,1);
    Hyz = diff(Hy,1,3);
    
    %Maxwell Equations
    Ex(:,2:end-1,2:end-1) = Ex(:,2:end-1,2:nz-1) + (dt/(eps(:,2:end-1,2:nz-1)*dy)).*Hzy(:,1:end-1,2:end-1) - (dt/(eps(:,2:end-1,2:nz-1)*dz)).*Hyz(:,2:ny-1,1:end-1);
    Ey(2:end-1,:,2:end-1) = Ey(2:end-1,:,2:end-1) + (dt/(eps(2:end-1,:,2:end-1)*dz)).*Hxz(2:end-1,:,1:end-1) - (dt/(eps(2:end-1,:,2:end-1)*dx)).*Hzx(1:end-1,:,2:end-1);
    Ez(2:end-1,2:end-1,:) = Ez(2:end-1,2:end-1,:) + (dt/(eps(2:end-1,2:end-1,:)*dx)).*Hyx(1:end-1,2:end-1,:) - (dt/(eps(2:end-1,2:end-1,:)*dy)).*Hxy(2:end-1,1:end-1,:);
   
    %Gaussian Source
    f(n)= sin(2*pi*f0*n*dt)*exp(-(n*dt-t0)^2/(tw^2))/dy;
    Ez(srcx,srcy,srcz) = Ez(srcx,srcy,srcz) + f(n);
    Ezn(n)=Ez(srcx,srcy,srcz);
    
    %derivatives
    Exy = diff(Ex,1,2);
    Exz = diff(Ex,1,3);
    Ezx = diff(Ez,1,1);
    Ezy = diff(Ez,1,2);
    Eyx = diff(Ey,1,1);
    Eyz = diff(Ey,1,3);
    
    %Maxwell Equations
    Hx(:,1:end-1,1:end-1) = Hx(:,1:end-1,1:end-1) - (dt/(mu0*dy))*Ezy(:,:,1:end-1) + (dt/(mu0*dz))*Eyz(:,1:end-1,:);
    Hy(1:end-1,:,1:end-1) = Hy(1:end-1,:,1:end-1) - (dt/(mu0*dz))*Exz(1:end-1,:,:) + (dt/(mu0*dx))*Ezx(:,:,1:end-1);
    Hz(1:end-1,1:end-1,:) = Hz(1:end-1,1:end-1,:) - (dt/(mu0*dx))*Eyx(:,1:end-1,:) + (dt/(mu0*dy))*Exy(1:end-1,:,:);
     
    %display
    if (mod(i,10)==0)
        hold on
        %for k=1:20:nz
        %slice(:,:)=Ez(:,:,k);
        %slice = log(slice.*(slice>0)); %logarithmic scale
        %g = hgtransform('Matrix',makehgtform('translate',[0 0 k]));
        %imagesc(g,slice)
        %alpha(0.5);
        %end
%         slice(:,:)=Ez(:,:,nz/2);
%         slice = log(slice.*(slice>0)); %logarithmic scale
%         imagesc(slice)
        slice(:,:)=Ez(:,ny/2,:);
        slice = log(slice.*(slice>0)); %logarithmic scale
        xr = makehgtform('xrotate',pi/2);
        zr = makehgtform('zrotate',-pi/2);
        yr = makehgtform('yrotate',pi);
        t = makehgtform('translate',[-nx/2 -0 nz/2]);
        g = hgtransform('Matrix',xr * zr * yr * t); 
        imagesc(g,slice)      
        slice(:,:)=Ez(ny/2,:,:);
        slice = log(slice.*(slice>0)); %logarithmic scale
        yr = makehgtform('yrotate',pi/2);
        zr = makehgtform('zrotate',pi);
        t = makehgtform('translate',[-nx/2 -ny nz/2]);
        g = hgtransform('Matrix',yr * zr * t); 
        im = imagesc(g,slice)
        im.AlphaData = 0.1;
        [X,Y] = meshgrid(nx:-1:1,1:1:ny);
        Z(:,:) = (eps(:,:,1)/eps0 - adipose)*(nz/4)/tumor - nz/2;
        sr = surf(Y,X,Z);
        sr.AlphaData = 0.05;
        sr.LineStyle = 'none';
        alpha(0.7);
        view([-37.5,120])
        hold off
        drawnow
view(3)
%         y(:,:)=Ey(:,:,round(ny/2));
%         logy = log(y.*(y>0)); %logarithmic scale
%         py=pcolor(logy);
%         ydata = py.YData;
% %         py.YData = py.ZData;
% %         py.ZData = ydata;
%         py.YData = ny/2 + py.YData;
%         ballsize = 20;
% [xx, yy, zz] = meshgrid(1:10:nx,1:10:ny,1:10:nz);
% E = log(Ez.*(Ez>0));
% samples = E(1:10:nx,1:10:ny,1:10:nz);
% scatter3(xx(:),yy(:),zz(:),ballsize, samples(:),'filled');
colorbar;
    end
    %shading interp;
    i = i+1
end
datetime('now')
