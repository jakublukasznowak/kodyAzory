% Jakub Nowak 201706

% Generates 2 psd plots for selected segment of the flight.
%
% INPUT
%    actos - actos file structure
%    uft - uft file structure
%    timeRange - 2-element vector with time limits defining segment to plot,
%       in sec from ACTOS recording startup
%    printout - .pdf or .png filename for printout; if skipped or empty
%       plots appears only on the screen
%    Mv - number of points over which the average should be taken (to
%       improve clarity of the plot)
%
% OUTPUT -> 2 plots containing:
%    (1) PSD of temperature (UFT,PT100 and Tv)
%    (2) PSD of humidity (LICOR)


function plotSpectra(actos,uft,timeRange,printout,Mv)

if nargin<5, Mv=[0 0]; end
if nargin<4, printout=''; end

% select segment
indA1=find(actos.time>=timeRange(1),1,'first');
indA2=find(actos.time<=timeRange(2),1,'last');
selA=indA1:indA2;

uft.time=(0:length(uft.upT)-1)'/uft.samp+uft.startTime;
indU1=find(uft.time>=timeRange(1),1,'first');
indU2=find(uft.time<=timeRange(2),1,'last');
selU=indU1:indU2;


% PSD
finerU=[1 1e2];
[uft.psd,uft.fv,Cu]=spectrum([uft.upT(selU) uft.lowT(selU)],uft.samp,finerU);
uft.fv53=logspace(log10(finerU(1)),log10(finerU(2)),1000); uft.psd53=Cu*uft.fv53.^(-5/3);

finerA=[0.5 10];
[actos.psd,actos.fv,Ca]=spectrum([actos.licorH2O(selA),actos.sonicTV(selA),actos.sonicPRT(selA)],actos.samp,finerA);
actos.fv53=logspace(log10(finerA(1)),log10(finerA(2)),1000); actos.psd53=Ca*actos.fv53.^(-5/3);


% plots
[f1,ax1]=spectrumPlot({uft.psd(:,1),uft.psd(:,2),actos.psd(:,2),actos.psd(:,3),uft.psd53/10},...
    {uft.fv,uft.fv,actos.fv,actos.fv,uft.fv53},...
    {'upUFT','lowUFT','T_v','PT100','-5/3'},[Mv(1) Mv(1) Mv(2) Mv(2) 0]);
[f2,ax2]=spectrumPlot({actos.psd(:,1),actos.psd53/10},{actos.fv,actos.fv53},{'LICOR','-5/3'},[Mv(2) 0]);


% print
res=300;
if strcmp(printout(end-2:end),'png')

    print(f1,[printout(1:end-4),'temp'],'-dpng',['-r',num2str(res)])
    print(f2,[printout(1:end-4),'humid'],'-dpng',['-r',num2str(res)])

elseif strcmp(printout(end-2:end),'pdf')
    
    segmentStr=sprintf('Segment %04d-%04ds',round(timeRange(1)),round(timeRange(2)));
    titles={'Temperature PSD','Humidity PSD'};
    
    ff=figure('Color','white','PaperUnits','centimeters',...
        'PaperSize',[21 29.7],'PaperPosition',[1.25 1.25 21-2.5 29.7-2.5]);
    subplot(2,1,1,ax1,'Parent',ff)
    set(ax1,'Position',[0.04 0.07/2+1/2 1-0.04-0.04 1/2-0.07/2-0.07/2],...
        'FontSize',8,'Title',text(0,0,[segmentStr,' ',titles{1}]),...
        'PlotBoxAspectRatio',[1 1 1])
    subplot(2,1,2,ax2,'Parent',ff)
    set(ax2,'Position',[0.04 0.07/2+0/2 1-0.04-0.04 1/2-0.07/2-0.07/2],...
        'FontSize',8,'Title',text(0,0,[segmentStr,' ',titles{2}]),...
        'PlotBoxAspectRatio',[1 1 1])
    print(ff,printout(1:end-4),'-dpdf',['-r',num2str(res)])
    
end
    
end