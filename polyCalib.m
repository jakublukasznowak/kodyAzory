% Jakub Nowak 201706

% Fits polynomial y=p(x)
%
% INPUT
%    x - signal to calibrate
%    y - reference
%    n - polynomial order
%    printout - .pdf or .png filename for calibration plot printout; other
%       nonempty value plots only on the screen
%
% OUTPUT
%    p - fitted polynomial of selected order
%    fig - figure handle
%    ax - axes handle

function [p,fig,ax] = polyCalib(x,y,n,printout)

if nargin<4, printout=''; end

p=polyfit(x,y,n);

%% plot
res=300;
if ~isempty(printout)
    [fig,ax]=calibPlot(x,y,p);
    if strcmp(printout(end-2:end),'pdf') || strcmp(printout(end-2:end),'png')
        print(fig,printout(1:end-4),['-d',printout(end-2:end)],['-r',num2str(res)])
    end
else
    fig=[]; ax=[];
end

end

function [f,ax]=calibPlot(x,y,p)

width=12; height=10;
f=figure('Color','white','PaperUnits','centimeters',...
    'PaperSize',[21 29.7],'PaperPosition',[(21-width)/2 29.7-2.5-height width height]);
ax=axes('Color','none','FontSize',8,'Position',[0.12 0.12 0.83 0.83]);
hold on

scatter(x,y,15,(1:length(x))'/1000,'.')
colormap jet, cb=colorbar; cb.Label.String='Time [1e3 samples]';
plot(x,polyval(p,x),'b','LineWidth',1.5)
xlabel('Voltage [V]'), ylabel('Temperature [^{o} C]')
set(ax,'Box','on',...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)

end