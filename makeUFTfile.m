% Jakub Nowak 201706

% Imports UFT data from raw binary file, synchronises time, performs
% callibration with reference ACTOS thermometer and stores information in 
% one .mat file.


%prefix='flight01';
prefix='flight02';
%rawfile='/home/pracownicy/jnowak/uft/dataWinningen/rawUFT/uft_20161005_1327.dat';
rawfile='/home/pracownicy/jnowak/uft/dataWinningen/rawUFT/uft_20161006_1210.dat';
%actosfile='/home/pracownicy/jnowak/uft/dataWinningen/actos_flight01.mat';
actosfile='/home/pracownicy/jnowak/uft/dataWinningen/actos_flight02.mat';
output='/home/pracownicy/jnowak/uft/dataWinningen';
outputplots='/home/pracownicy/jnowak/uft/raport/plots';



% load ACTOS
actos=load(actosfile);

% load UFT
temp=importUFTraw(rawfile,5,2); % range 5 V, 2 channels
uft.upV=temp(:,1); uft.lowV=temp(:,2); % uft.lwcV=temp(:,3);
clear temp
uft.samp=20e3;



%% time synchronization

% baseVar - variable from uft acquisition system to serve as a base in
%    signal comparison
% refVar - variable from actos file to serve as a reference in comparison
% ssamp - requested frequency of both signals being compared; averaging is
%    applied prior to synchronization
% maxDelay - maximum time delay range to probe when maximizing correlation
%    between signals

baseVar='upV';
refVar='sonicPRT';
ssamp=10; % [Hz]
maxDelay=100; % [s]


% base UFT signal
baseSig=average(uft.(baseVar),uft.samp/ssamp,'s');

% reference signal
refSig=average(actos.(refVar),actos.samp/ssamp,'s');
refTime=average(actos.time,actos.samp/ssamp,'s');

% select time section
refPress=average(actos.pressure,actos.samp/ssamp,'s');
sel=(refPress<0.99*max(refPress));

% find delay between base and reference
delay=findDelay(refSig(sel),baseSig(sel),maxDelay*ssamp,[outputplots,filesep,prefix,'sync.png']);

% save info and results
uft.sync=struct('ref',refVar,'base',baseVar,'samp',ssamp,...
    'maxDelay',maxDelay,'timeDelay',delay/ssamp);
uft.startTime=actos.time(1)+uft.sync.timeDelay-0.5/uft.sync.samp+0.5/uft.samp;
uft.startSOD=actos.gpsSOD(1)+uft.startTime-actos.time(1);



%% temperature calibration

% refVar - temperature variable from actos file to serve as a reference in
%    calibration of both uft sensors
% csamp - requested frequency of calibrated and reference signals, averaging
%    is applied prior to calibration
% maskLWCthresh - LWC threshold for constructing a cloudmask used to avoid
%    including cloudy regions in calibration procedure
% maskLWCdill - timescale of dillution applied to sharp thresholded cloudmask

refVar='sonicPRT';
csamp=10; % [Hz]
maskLWCthresh=0.02; maskLWCdill=1; % [s]

% base UFT signals
baseUpV=average(uft.upV,uft.samp/csamp,'s');
baseLowV=average(uft.lowV,uft.samp/csamp,'s');

% reference signal
refT=average(actos.(refVar),actos.samp/csamp,'s');

% cloudmask to avoid cloudy regions in calibration
if isfield(actos,'pvm1LWC')
    cloudmask=(average(actos.pvm1LWC,actos.samp/csamp,'s')>maskLWCthresh);
    cloudmask=(average(cloudmask,maskLWCdill*csamp,'m')>0); % dillution
else
    sprintf('pvm1LWC not found in ACTOS file. Cannot apply cloudmask :(.')
    cloudmask=zeros(size(refT));
end

% select time section
refPress=average(actos.pressure,actos.samp/csamp,'s');
sel=find(all([refPress<0.99*max(refPress) ~cloudmask],2));

% calibrate
delay=round(uft.sync.timeDelay*csamp);
[upP,upPe]=polyCalib(baseUpV(sel-delay),refT(sel),1,[outputplots,filesep,prefix,'upcalib.png']);
[lowP,lowPe]=polyCalib(baseLowV(sel-delay),refT(sel),1,[outputplots,filesep,prefix,'lowcalib.png']);
uft.upT=polyval(upP,uft.upV);
uft.lowT=polyval(lowP,uft.lowV);
uft=rmfield(uft,{'upV','lowV'});

% save info
uft.calib=struct('ref',refVar,'samp',csamp,'maskLWCthresh',maskLWCthresh,...
    'maskLWCdill',maskLWCdill,'upP',upP,'lowP',lowP,'upPe',upPe','lowPe',lowPe);



%% average signals for quicklooks and plots

uft.samp_av=100; % [Hz]
M=uft.samp/uft.samp_av;
uft.time_av=average((0:length(uft.upT)-1)'/uft.samp+uft.startTime,M,'s');
uft.SOD_av=uft.time_av+uft.startSOD-uft.startTime;
uft.upT_av=average(uft.upT,M,'s');
uft.lowT_av=average(uft.lowT,M,'s');
%uft.LWC_av=average(uft.LWC,M,'s')



%% save to file

save([output,filesep,'uft_',prefix],'-struct','uft')