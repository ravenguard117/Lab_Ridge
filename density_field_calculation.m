close all

askref=0;
coarsinglevel=2; % level of grid coarsing
%% Get conversion infos

[infofile,pathname] = uigetfile('*.mat','Choose info file for beta and gamma values');
load(strcat(pathname,infofile),'beta','gamma');

 mkdir(strcat(pathname,'/densityfields'));

[background,pathname2] = uigetfile('*.tiff','Choose background image');
bgimage=imread(strcat(pathname2,background));

prepaname1=truncname(background,'','.tiff','beforelast');
prepaname2=truncname(prepaname1,'C','','afterlast');


im1=double(bgimage(:,:,3));

if askref==0;
refpic=input('select upper and lower limits ? (1 for yes, 0 for no) =>') 
askref=1;
end;

if refpic==1;

imagesc(im1)
input('Position of the upper and lower limits')
[jj,ii]=ginput;

itop=floor(ii(1)) %position of the free surface
ibot=floor(ii(2)) %position of the tank bottom

end;

ideb=input('Index of first image =>');
ifin=input('Index of last image =>');

cim1=im1(itop:ibot,:);
gamma=1/gamma;
%gamma=(ibot-itop)/32.5 % en cm

%% Fine grid

sizex=size(cim1,2);sizez=size(cim1,1);
xx=sizex/gamma*linspace(0,1,sizex);
zz=sizez/gamma*linspace(0,1,sizez);
[xm,zm] = meshgrid(xx,zz);

%% Coarse grid

xxc=sizex/gamma*linspace(0,1,floor(sizex/coarsinglevel));
zzc=sizez/gamma*linspace(0,1,floor(sizez/coarsinglevel));
[xcm,zcm] = meshgrid(xxc,zzc);

cgamma=gamma/coarsinglevel;

%%
ccim1=interp2(xm,zm,cim1,xcm,zcm);

for it=ideb:1:ifin;

itstr=num2str(it)
    clear lratio mlratio;
    imload=imread(strcat(pathname2,'_DSC',num2str(it),'.tiff'));
    imcur=double(imload(:,:,3));
    cimcur=imcur(itop:ibot,:);
    ccimcur=interp2(xm,zm,cimcur,xcm,zcm);
    lratio=log(ccim1./ccimcur);
   % mlratio=lratio;
    mlratio=medfilt2(lratio, [10 10]);
     
%    plot 
     figure(50)
     imagesc(xx,zz,mlratio*beta)
     daspect([1 1 1])
     caxis([-1.5 1.5])
     cmocean('balance')
     colorbar 
     title(strcat('\Delta \rho (kg/m3), t=',num2str((it-ideb)/2.5),' s'));
     xlabel ('x (m)','Fontsize',30);
     ylabel ('z (m)','Fontsize',30);
     set(gca,'Fontsize',30)
%      
       pause(0.1);
     
     save(strcat(pathname,'/densityfields/','density_',prepaname2,'_',itstr),'beta','mlratio','xxc','zzc','coarsinglevel','cgamma','itop','ibot')
     
end;





