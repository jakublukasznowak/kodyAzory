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
%    (6) platform velocity with respect to ground from inertial naviation


function plotTimeSegment(actos,uft,timeRange,printout)

if nargin<4, printout=''; end

indA1=find(actos.time>=timeRange(1),1,'first');
indA2=find(actos.time<=timeRange(2),1,'last');
selA=indA1:indA2;

indU1=find(uft.time_av>=timeRange(1),1,'first');
indU2=find(uft.time_av<=timeRange(2),1,'last');
selU=indU1:indU2;


%% plot 1: LWC and pressure

f1=figure('Color','white');

ax1a=axes('Color','none','Box','off','FontSize',8);
hold on
plot(actos.time(selA),actos.pvm1LWC(selA),'b')
if isfield(actos,'cloudmask'), plot(actos.time(selA),0.15*actos.cloudmask(selA),'r'), leg={'LWC','cloudmask'};
else leg={'LWC'}; end
xlabel('Time [s]')
ylabel('LWC [g/m^3]')
set(ax1a,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg1a=legend(leg,'Location','north','Orientation','horizontal');
set(leg1a,'Position',get(leg1a,'Position')+[-0.13 0.08 0 0])

ax1b=axes('Color','none','Box','off','FontSize',8);
hold on
plot(actos.time(selA),actos.pressure(selA),'g')
ylabel('Pressure [hPa]')
set(ax1b,'XLim',timeRange,'YAxisLocation','right','XTickLabel',[],...
    'XGrid','off','YGrid','off','XMinorGrid','off','YMinorGrid','off')
leg1b=legend({'p'},'Location','north','Orientation','horizontal');
set(leg1b,'Position',get(leg1b,'Position')+[0.13 0.08 0 0])



%% plot 2: UFTx2

f2=figure('Color','white');
ax2=axes('Color','none','Box','off','FontSize',8);
hold on
co=get(gca,'ColorOrder');
plot(uft.time_av(selU),uft.upT_av(selU),'Color',co(2,:))
plot(uft.time_av(selU),uft.lowT_av(selU),'Color',co(3,:))
xlabel('Time [s]')
ylabel('Temperature [^{o}C]')
set(ax2,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg2=legend({'upUFT','lowUFT'},'Location','north','Orientation','horizontal');
set(leg2,'Position',get(leg2,'Position')+[0 0.08 0 0])


%% plot 3: TEMP from PRT,SOS,HMP,DP

f3=figure('Color','white');
ax3=axes('Color','none','Box','off','FontSize',8);
hold on
co=get(gca,'ColorOrder');
plot(actos.time(selA),actos.sonicPRT(selA),'Color',co(1,:))
plot(actos.time(selA),actos.sonicTV(selA)-3,'Color',co(4,:))
plot(actos.time(selA),actos.hmpT(selA),'Color',co(5,:))
plot(actos.time(selA),actos.dp1T(selA),'Color',co(7,:))
xlabel('Time [s]')
ylabel('Temperature [^{o}C]')
set(ax3,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg3=legend({'PRT','sonicTV-3','HMP','DP'},'Location','north','Orientation','horizontal');
%leg3=legend({'PRT','sonicTV-3'},'Location','north','Orientation','horizontal');
set(leg3,'Position',get(leg3,'Position')+[0 0.08 0 0])


%% plot 4: humidity from HMP,LICOR,DP

if ~isfield(actos,'hmpAH')
    es=6.112*exp(17.67*actos.hmpT./(actos.hmpT+243.5));
    e=es.*actos.hmpRH/100;
    actos.hmpAH=1./(1+(actos.pressure./e-1)*28.84/18.02)*1000;
end

f4=figure('Color','white');
ax4=axes('Color','none','Box','off','FontSize',8);
hold on
plot(actos.time(selA),actos.hmpAH(selA))
plot(actos.time(selA),actos.licorH2O(selA))
plot(actos.time(selA),actos.dp1AH(selA)-1.5)
xlabel('Time [s]')
ylabel('Humidity [??]')
set(ax4,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg4=legend({'HMP','LICOR','DP-1.5'},'Location','north','Orientation','horizontal');
set(leg4,'Position',get(leg4,'Position')+[0 0.08 0 0])


%% plot 5: sonic wind

f5=figure('Color','white');
ax5=axes('Color','none','Box','off','FontSize',8);
hold on
plot(actos.time(selA),actos.sonic1(selA),...
    actos.time(selA),actos.sonic2(selA),...
    actos.time(selA),actos.sonic3(selA))
xlabel('Time [s]')
ylabel('Velocity [m/s]')
set(ax5,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg5=legend({'sonic1','sonic2','sonic3'},'Location','north','Orientation','horizontal');
set(leg5,'Position',get(leg5,'Position')+[0 0.08 0 0])


%% plot 6: imar velocity

f6=figure('Color','white');
ax6=axes('Color','none','Box','off','FontSize',8);
hold on
plot(actos.time(selA),actos.imarU(selA),...
    actos.time(selA),actos.imarV(selA),...
    actos.time(selA),actos.imarW(selA))
xlabel('Time [s]')
ylabel('Velocity [m/s]')
set(ax6,'XLim',timeRange,...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
leg6=legend({'u','v','w'},'Location','north','Orientation','horizontal');
set(leg6,'Position',get(leg6,'Position')+[0 0.08 0 0])


%% print
if ~isempty(printout)

    res=300;

    if strcmp(printout(end-2:end),'png') 

       print(f1,[printout(1:end-4),num2str(1,'%02d')],'-dpng',['-r',num2str(res)])
       print(f2,[printout(1:end-4),num2str(2,'%02d')],'-dpng',['-r',num2str(res)])
       print(f3,[printout(1:end-4),num2str(3,'%02d')],'-dpng',['-r',num2str(res)])
       print(f4,[printout(1:end-4),num2str(4,'%02d')],'-dpng',['-r',num2str(res)])
       print(f5,[printout(1:end-4),num2str(5,'%02d')],'-dpng',['-r',num2str(res)])
       print(f6,[printout(1:end-4),num2str(6,'%02d')],'-dpng',['-r',num2str(res)])

    elseif strcmp(printout(end-2:end),'pdf')

        axesM=num2cell(zeros(6,2));
        axesM{1,1}=ax1a; axesM{1,2}=ax1b; axesM{2,1}=ax2; axesM{3,1}=ax3;
        axesM{4,1}=ax4; axesM{5,1}=ax5; axesM{6,1}=ax6;
        legsM=num2cell(zeros(6,2));
        legsM{1,1}=leg1a; legsM{1,2}=leg1b; legsM{2,1}=leg2; legsM{3,1}=leg3;
        legsM{4,1}=leg4; legsM{5,1}=leg5; legsM{6,1}=leg6;

        titles={'LWC and Pressure','Temperature UFT','Temperature ACTOS','Humidity','Wind','Velocity'};
        segmentStr=['Segment ',num2str(round(timeRange(1)),'%04d'),'-',num2str(round(timeRange(2)),'%04d'),'s'];

        for page=1:ceil(numel(axesM(:,1))/3)
            ff=figure('Color','white',...
                'PaperUnits','centimeters',...
                'PaperSize',[21 29.7],...
                'PaperPosition',[1.25 1.25 21-2.5 29.7-2.5]);
            for n=1:3
                subplot(3,1,n,axesM{(page-1)*3+n,1},'Parent',ff)
                set(axesM{(page-1)*3+n,1},'Position',[0.07 0.10/3+(3-n)/3 1-0.07-0.07 1/3-0.10/3-0.10/3],...
                    'FontSize',8,'Title',text(0,0,[segmentStr,' ',titles{(page-1)*3+n}]))
                legsM{(page-1)*3+n,1}.Position=legsM{(page-1)*3+n,1}.Position+[0 (1-n)/3 0 0];
                if ~isnumeric(axesM{(page-1)*3+n,2})
                    subplot(3,1,3+1-n,axesM{(page-1)*3+n,2},'Parent',ff)
                    set(axesM{(page-1)*3+n,2},'Position',[0.07 0.10/3+(3-n)/3 1-0.07-0.07 1/3-0.10/3-0.10/3],...
                        'FontSize',8,'YAxisLocation','right','XTickLabel',[],...
                        'XGrid','off','YGrid','off','XMinorGrid','off','YMinorGrid','off')
                    legsM{(page-1)*3+n,2}.Position=legsM{(page-1)*3+n,2}.Position+[0 (1-n)/3 0 0];
                end
            end
            print(ff,[printout(1:end-4),num2str(page,'%02d')],'-dpdf',['-r',num2str(res)])
        end

    else
        sprintf('Invalid file format.')
    end
    
end
    


end