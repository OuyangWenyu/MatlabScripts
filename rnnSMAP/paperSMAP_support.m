
suffix = '.jpg';
figFolder='H:\Kuai\rnnSMAP\paper\';


%% 1 Prcp map
trainName='CONUSs4f1';
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);

[yRain_All,yRain_stat] = readDatabaseSMAP(trainName,'ARAIN');
[ySnow_All,ySnow_stat] = readDatabaseSMAP(trainName,'ASNOW');

plotData=mean(yRain_All'+ySnow_All',2)*365*24;
[gridData,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Precipitation [mm]';
shapefile='H:\Kuai\map\USA.shp';
colorRange=[0,2000];
[h,cmap]=showMap(gridData,yy,xx,'colorRange',colorRange,'shapefile',shapefile,...
    'title',titleStr,'Position',[1,1,1600,1000]);
colormap(cmap)

fname=[figFolder,'fig_sup_Prcp'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% 2 raw values of R2(Noah) and Bias(Noah)
trainName='CONUSs4f1';
tTest=367:732;
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';

[yNOAH_All,yNOAH_stat] = readDatabaseSMAP(trainName,'LSOIL');
[ySMAP_All,yNOAH_stat] = readDatabaseSMAP(trainName,'SMAP');

ySMAP=ySMAP_All(tTest,:);
yNOAH=yNOAH_All(tTest,:)./100;

statNOAH=statCal(yNOAH,ySMAP);

stat='rsq';
plotData=statNOAH.(stat);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='R^2(NOAH)';
colorRange=[0,1];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_rsqMap_NOAH'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

stat='bias';
plotData=statNOAH.(stat);
[gridStat,xx,yy] = data2grid(plotData,crd(:,2),crd(:,1));
titleStr='Bias(NOAH)';
colorRange=[-0.15,0.15];
[h,cmap]=showMap(gridStat,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
fname=[figFolder,'fig_biasMap_NOAH'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);
