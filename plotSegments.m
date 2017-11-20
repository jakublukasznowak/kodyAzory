% Jakub Nowak 201705

% Generates 6 time plots for selected segment of the flight.
%
% INPUT
%    actos - actos file structure
%    uft - uft file structure
%    timeRange - 2-element vector with time limits defining segment to plot,
%       in sec from ACTOS recording startup
%    printout - .pdf or .png filename for printout; if skipped or empty
%       plots appears only on the screen
%
% OUTPUT -> 6 plots containing:
%    (1) pressure, LWC, cloudmask
%    (2) UFT temperature
%    (3) ACTOS temperature: PT100, sonicTV, Vaisala HMP, DewPoint
%    (4) humidity: LICOR, Vaisala HMP, DewPoint
%    (5) wind velocity from sonic
%    (6) platform velocity with respect to ground from inertial navigation


function plotSegments(actos,uft,timeRange,printout)

if nargin<4, printout=''; end

% select segment
indA1=find(actos.time>=timeRange(1),1,'first');
indA2=find(actos.time<=timeRange(2),1,'last');
selA=indA1:indA2;

indU1=find(uft.time_av>=timeRange(1),1,'first');
indU2=find(uft.time_av<=timeRange(2),1,'last');
selU=indU1:indU2;


% %% prepare plots - default
% 
% % plot 1: LWC and pressure
% [f1,ax1a,leg1a,ax1b,leg1b]=segmentPlot({actos.pvm1LWC(selA);actos.pressure(selA)},...
%     {actos.time(selA);actos.time(selA)},...
%     {'LWC';'Pressure'},{'LWC [g/m^3]';'Pressure [hPa]'},...
%     {'b';'g'});
% 
% % plot 2: UFT-2
% [f2,ax2,leg2]=segmentPlot({uft.upT_av(selU),uft.lowT_av(selU)},...
%     {uft.time_av(selU),uft.time_av(selU)},...
%     {'upUFT','lowUFT'},{'Temperature [^{o}C]'},{2,3});
% 
% % plot 3: temp from PT100, SOS, HMP
% [f3,ax3,leg3]=segmentPlot({actos.sonicPRT(selA),actos.sonicTV(selA)-3,actos.hmpT(selA)},...
%     {actos.time(selA),actos.time(selA),actos.time(selA)},...
%     {'PT100','T_v-3','Vaisala'},{'Temperature [^{o}C]'},{1,4,5});
% 
% % plot 4: humidity from HMP, LICOR
% if ~isfield(actos,'hmpAH')
%     es=6.112*exp(17.67*actos.hmpT./(actos.hmpT+243.5));
%     e=es.*actos.hmpRH/100;
%     actos.hmpAH=1./(1+(actos.pressure./e-1)*28.84/18.02)*1000;
% end
% [f4,ax4,leg4]=segmentPlot({actos.hmpAH(selA),actos.licorH2O(selA)},...
%     {actos.time(selA),actos.time(selA)},...
%     {'Vaisala','LICOR'},{'Humidity [g/kg]'},{5,2});
% 
% % plot 5: sonic wind
% [f5,ax5,leg5]=segmentPlot({actos.sonic1(selA),actos.sonic2(selA),actos.sonic3(selA)},...
%     {actos.time(selA),actos.time(selA),actos.time(selA)},...
%     {'u','v','w'},{'Wind velocity [m/s]'});
% 
% % plot 6: imar velocity
% [f6,ax6,leg6]=segmentPlot({actos.imarU(selA),actos.imarV(selA),actos.imarW(selA)},...
%     {actos.time(selA),actos.time(selA),actos.time(selA)},...
%     {'u','v','w'},{'Platform velocity [m/s]'});


%% prepare plots - for flight printing

% plot 1: LWC and baroheight
[f1,ax1a,leg1a,ax1b,leg1b]=segmentPlot({actos.pvm1LWC(selA);actos.baroheight(selA)},...
    {actos.time(selA);actos.time(selA)},...
    {'LWC';'Baroheight'},{'LWC [g/m^3]';'Baroheight [m]'},...
    {'b';'g'});

% plot 2: UFT-2 and sonicPRT
actos.sonicPRT_av=average(actos.sonicPRT,10,'s');
actos.time_av=average(actos.time,10,'s');
indA1_av=find(actos.time_av>=timeRange(1),1,'first');
indA2_av=find(actos.time_av<=timeRange(2),1,'last');
selA_av=indA1_av:indA2_av;

[f2,ax2,leg2]=segmentPlot({uft.upT_av(selU),uft.lowT_av(selU),actos.sonicPRT_av(selA_av)},...
    {uft.time_av(selU),uft.time_av(selU),actos.time_av(selA_av)},...
    {'upUFT 100Hz','lowUFT 100Hz','PRT 10Hz'},{'Temperature [^{o}C]'},{2,3,1});

% plot 3: sonic wind
[f5,ax5,leg5]=segmentPlot({actos.sonic1(selA),actos.sonic2(selA),actos.sonic3(selA)},...
    {actos.time(selA),actos.time(selA),actos.time(selA)},...
    {'u','v','w'},{'Sonic velocity [m/s]'});


%% print
res=300;

if strcmp(printout(end-2:end),'png')
    
    names={'lwc','uft','temp','humid','sonic','imar'};
    %fM={f1,f2,f3,f4,f5,f6};
    fM={f1,f2,f5};
    for i=1:numel(fM)
        print(fM{i},[printout(1:end-4),names{i}],'-dpng',['-r',num2str(res)])
        %eval(sprintf('print(f%d,%s,''-dpng'',''-r%d'')',i,[printout(1:end-4),names{i}],res))
    end
    
elseif strcmp(printout(end-2:end),'pdf')
    
    fpp=3;
    
    %axM={ax1a,ax1b;ax2,[];ax3,[];ax4,[];ax5,[];ax6,[]};
    %legM={leg1a,leg1b;leg2,[];leg3,[];leg4,[];leg5,[];leg6,[]};
    axM={ax1a,ax1b;ax2,[];ax5,[]};
    legM={leg1a,leg1b;leg2,[];leg5,[]};
    
    N=size(axM,1); P=ceil(N/fpp);
    
    segmentStr=sprintf('Segment %04d-%04ds',round(timeRange(1)),round(timeRange(2)));
    %titles={'LWC and Pressure','Temperature UFT-2','Temperature ACTOS',...
    %    'Humidity','Wind velocity','Platform velocity'};
    titles={'LWC and Height','Temperature','Sonic wind'};
        
    for p=1:P
        if strcmp(printout(end-4),'H')
            ff=figure('Color','white','PaperUnits','centimeters',...
                'PaperSize',[29.7 21],'PaperPosition',[1 1 29.7-2 21-2]);
            titles=repmat({''},size(titles));
        else
            ff=figure('Color','white','PaperUnits','centimeters',...
                'PaperSize',[21 29.7],'PaperPosition',[1 1 21-2 29.7-2]);
            titles=cellfun(@(x,y) cat(2,x,y),repmat({[segmentStr,' ']},size(titles)),titles,'UniformOutput',false);
        end
        
        for i=1:fpp
            subplot(fpp,1,i,axM{(p-1)*fpp+i,1},'Parent',ff)
            set(axM{(p-1)*fpp+i,1},'Position',[0.04 0.08/fpp+(fpp-i)/fpp 1-0.04-0.04 1/fpp-0.08/fpp-0.08/fpp],...
                'FontSize',8,'Title',text(0,0,titles{(p-1)*fpp+i}))
            legM{(p-1)*fpp+i,1}.Position=legM{(p-1)*3+i,1}.Position+[0 (1-i)/fpp 0 0];
            if ~isempty(axM{(p-1)*fpp+i,2})
                subplot(fpp,1,i,axM{(p-1)*fpp+1,2},'Parent',ff)
                set(axM{(p-1)*fpp+1,2},'Position',[0.04 0.08/fpp+(fpp-i)/fpp 1-0.04-0.04 1/fpp-0.08/fpp-0.08/fpp],...
                    'FontSize',8,'YAxisLocation','right','XTickLabel',[],...
                    'XGrid','off','YGrid','off','XMinorGrid','off','YMinorGrid','off')
                legM{(p-1)*fpp+i,2}.Position=legM{(p-1)*fpp+i,2}.Position+[0 (1-i)/3 0 0];
            end
        end
        
        print(ff,[printout(1:end-4),num2str(p,'_%02d')],'-dpdf',['-r',num2str(res)])
    end
    
end   

end