
% targetName='SMAP_AM';
targetName='APCP_FORA';
% 
% targetNameLst={...
%     'APCP_FORA';...
%     'DLWRF_FORA';...
%     'DSWRF_FORA';...
%     'TMP_2_FORA';...
%     'SPFH_2_FORA';...
%     'VGRD_10_FORA';...
%     'UGRD_10_FORA';...
%     };

rootDB=kPath.DBSMAP_L3_NA;
rootName='CONUS';



%% add Noise to root DB
yrLst=2015:2017;
% sigmaLst=[0.05,0.1,0.2,0.3,0.4,0.5];
% sigmaNameLst={'5e2','1e1','2e1','3e1','4e1','5e1'};
sigmaLst=[1,2];
sigmaNameLst={'1e0','2e0'};

for iY=1:length(yrLst)
    yr=yrLst(iY);
    [data,stat,crd,t]=readDB_Global(rootName,targetName,'yrLst',yr,'rootDB',rootDB);
    for iS=1:length(sigmaLst)
        tic
        sigma=sigmaLst(iS);
        sigmaName=sigmaNameLst{iS};
        varName=[targetName,'_rn',sigmaName];        
        dataNoiseFile=[rootDB,filesep,rootName,filesep,num2str(yr),filesep,varName,'.csv'];
        disp([num2str(yr),' ',varName])
        
        rNoise=randn(size(data)).*sigma;
        dataNoise=data.*(1+rNoise);
        %figure
        %plot(t,data(:,1000),'ko');hold on
        %plot(t,dataNoise(:,1000),'ro');hold off
        dlmwrite(dataNoiseFile,dataNoise','precision',8);
        toc
    end
end

%% calculate stat
for iS=1:length(sigmaLst)
    sigma=sigmaLst(iS);
    sigmaName=sigmaNameLst{iS};
    varName=[targetName,'_rn',sigmaName];
    varWarning{iS}= statDBcsvGlobal(rootDB,rootName,2015:2017,'varLst',varName,'varConstLst',[]);
end


%% subset to subsetted DB
% find subset need to be add data
folderLst=dir(rootDB);
subsetLst={};
for k=1:length(folderLst)
    folderName=folderLst(k).name;
    if ~strcmp(folderName,'.') && ...
            ~strcmp(folderName,'..') && ...
            ~strcmp(folderName,'Statistics') && ...
            ~strcmp(folderName,'Subset') && ...
            ~strcmp(folderName,'Variable') && ...
            ~strcmp(folderName,rootName)
        subsetLst=[subsetLst,folderName];
    end
end

for iSub=1:length(subsetLst)
    subsetName=subsetLst{iSub};
    for iS=1:length(sigmaLst)
        sigma=sigmaLst(iS);
        sigmaName=sigmaNameLst{iS};
        varName=[targetName,'_rn',sigmaName];
        msg=subsetSplitGlobal(subsetName,'rootDB',rootDB,'varLst',{varName},...
            'varConstLst',[],'yrLst',yrLst);
    end
end