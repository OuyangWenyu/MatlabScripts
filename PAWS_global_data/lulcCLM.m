function [] = lulc(boundingbox,lulcFolder,proj,savedir)
% land use and land cover
% input: boundingbox = 2 x 2 array [lon_left, lon_right; lat_bottom, lat_up]

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);
%load('GW_K.mat', 'g', 'Prob');

pftfile=[lulcFolder,'\mksrf_24pftNT_landuse_rc2000_c121207.nc'];
pftfile=checkMatNc(pftfile);
lat = readGPdata(pftfile, 'LAT');
lon = readGPdata(pftfile, 'LON');
latixy = readGPdata(pftfile, 'LATIXY');
longxy = readGPdata(pftfile, 'LONGXY');
pct_pft = readGPdata(pftfile, 'PCT_PFT');

% extract for the watershed
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
long_range=[long_range(1)-1;long_range;long_range(end)+1];  % 1 cell buffer
lati_range=[lati_range(1)-1;lati_range;lati_range(end)+1];

m_longxy_pft = round(double(longxy(long_range, lati_range)*1000))/1000;%round to 0.001
m_latixy_pft = round(double(latixy(long_range, lati_range)*1000))/1000;
m_pct_pft = pct_pft(long_range, lati_range, :);

% they may have different resolution. Take pft as standard and interpolate
% others by nearest.
m_East_pft = zeros(size(m_latixy_pft));
m_North_pft = zeros(size(m_latixy_pft));
for i = 1 : size(m_latixy_pft, 1)
    for j = 1 : size(m_latixy_pft, 2)
        [m_East_pft(i,j), m_North_pft(i,j)] = latlon2utm(m_latixy_pft(i,j), m_longxy_pft(i,j),proj.lon0,proj.hs);
    end
end
pft=permute(m_pct_pft,[2 1 3]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lakefile=[lulcFolder,'\mksrf_LakePnDepth_3x3min_simyr2004_c111116.nc'];
lakefile=checkMatNc(lakefile);
lat = readGPdata(lakefile, 'LAT');
lon = readGPdata(lakefile, 'LON');
latixy = readGPdata(lakefile, 'LATIXY');
longxy = readGPdata(lakefile, 'LONGXY');
pct_lake = readGPdata(lakefile, 'PCT_LAKE');

% extract for the watershed
% lat lon may change due to different files
% so these have to be re-calculated
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
long_range=[long_range(1)-1;long_range;long_range(end)+1];  % 1 cell buffer
lati_range=[lati_range(1)-1;lati_range;lati_range(end)+1];

m_longxy = round(double(longxy(long_range, lati_range)*1000))/1000;%round to 0.001
m_latixy = round(double(latixy(long_range, lati_range)*1000))/1000;
m_pct_lake = pct_lake(long_range, lati_range, :);

m_East = zeros(size(m_latixy));
m_North = zeros(size(m_longxy));
for i = 1 : size(m_latixy, 1)
    for j = 1 : size(m_latixy, 2)
        [m_East(i,j), m_North(i,j)] = latlon2utm(m_latixy(i,j), m_longxy(i,j),proj.lon0,proj.hs);
    end
end

if isequal(m_East,m_East_pft)&&isequal(m_North,m_North_pft)
    lake=double(m_pct_lake');
else
    lake = interp2_irreguler(m_East,m_North,double(m_pct_lake),m_East_pft,m_North_pft, 'nearest');
    lake=lake';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wetlandfile=[lulcFolder,'\mksrf_lanwat.060929.nc'];
wetlandfile=checkMatNc(wetlandfile);
lat = readGPdata(wetlandfile, 'LAT');
lon = readGPdata(wetlandfile, 'LON');
latixy = readGPdata(wetlandfile, 'LATIXY');
longxy = readGPdata(wetlandfile, 'LONGXY');
pct_wetland = readGPdata(wetlandfile, 'PCT_WETLAND');

% extract for the watershed
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
long_range=[long_range(1)-1;long_range;long_range(end)+1];  % 1 cell buffer
lati_range=[lati_range(1)-1;lati_range;lati_range(end)+1];

m_longxy = round(double(longxy(long_range, lati_range)*1000))/1000;%round to 0.001
m_latixy = round(double(latixy(long_range, lati_range)*1000))/1000;
m_pct_wetland = pct_wetland(long_range, lati_range, :);

m_East = zeros(size(m_latixy));
m_North = zeros(size(m_longxy));
for i = 1 : size(m_latixy, 1)
    for j = 1 : size(m_latixy, 2)
        [m_East(i,j), m_North(i,j)] = latlon2utm(m_latixy(i,j), m_longxy(i,j),proj.lon0,proj.hs);
    end
end

if isequal(m_East,m_East_pft)&&isequal(m_North,m_North_pft)
    wetland=double(m_pct_wetland');
else
    wetland = interp2_irreguler(m_East,m_North,double(m_pct_wetland),m_East_pft,m_North_pft,'nearest');
    wetland=wetland';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
urbanfile=[lulcFolder,'\mksrf_urban_0.05x0.05_simyr2000.c120621.nc'];
urbanfile=checkMatNc(urbanfile);
lat = readGPdata(urbanfile, 'LAT');
lon = readGPdata(urbanfile, 'LON');
latixy = readGPdata(urbanfile, 'LATIXY');
longxy = readGPdata(urbanfile, 'LONGXY');
pct_urban = readGPdata(urbanfile, 'PCT_URBAN');

% extract for the watershed
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
long_range=[long_range(1)-1;long_range;long_range(end)+1];  % 1 cell buffer
lati_range=[lati_range(1)-1;lati_range;lati_range(end)+1];

m_longxy = round(double(longxy(long_range, lati_range)*1000))/1000;%round to 0.001
m_latixy = round(double(latixy(long_range, lati_range)*1000))/1000;
m_pct_urban = pct_urban(long_range, lati_range, :);

m_East = zeros(size(m_latixy));
m_North = zeros(size(m_longxy));
for i = 1 : size(m_latixy, 1)
    for j = 1 : size(m_latixy, 2)
        [m_East(i,j), m_North(i,j)] = latlon2utm(m_latixy(i,j), m_longxy(i,j),proj.lon0,proj.hs);
    end
end

if isequal(m_East,m_East_pft)&&isequal(m_North,m_North_pft)
    urban=permute(m_pct_urban,[2 1 3]);
else
    for i = 1 : size(m_pct_urban, 3)
        urbantemp = interp2_irreguler(m_East,m_North,double(m_pct_urban(:,:,i)),m_East_pft,m_North_pft,'nearest');
        urban(:,:,i)=urbantemp';
    end
end
urban = sum(urban, 3);  % sum up the 3 urban classes

% combine the PFTs
pft = cat(3, pft, urban, lake, wetland);
East_pft=m_East_pft';
North_pft=m_North_pft';
save([savedir,'\pft.mat'], 'pft','East_pft','North_pft');