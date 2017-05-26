% Jakub Nowak 201705

% Fits polynomial y=p(x)
%
% INPUT
%    x - signal to calibrate
%    y - reference
%    n - polynomial order
%    printout - .pdf or .png filename for calibration plot printout
%
% OUTPUT
%    p - fitted polynomial of selected order


function p = polyCalib(x,y,n,printout)

if nargin<4, printout=''; end

p=polyfit(x,y,n);


% plot
res=300;

if isempty(printout)

    figure
    ax=axes('Color','none','FontSize',8);
    hold on
    scatter(x,y,25,(1:length(x))','.')
    colormap jet, cb=colorbar; cb.Label.String='Time [points]';
    plot(x,polyval(p,x),'b','LineWidth',1.5)
    xlabel('x'), ylabel('y')
    set(ax,'Box','on','XGrid','on','YGrid','on','GridAlpha',0.5)

else
    
    if strcmp(printout(end-2:end),'pdf')
        fig=figure('Color','white','PaperUnits','centimeters',...
            'PaperSize',[21 29.7],'PaperPosition',[1.25 1.25+(29.7-2.5)/2 21-2.5 (29.7-2.5)/2]);
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on
        scatter(x,y,25,(1:length(x))','.')
        colormap jet, cb=colorbar; cb.Label.String='Time [points]';
        plot(x,polyval(p,x),'b','LineWidth',1.5)
        xlabel('x'), ylabel('y')
        set(ax,'Box','on','XGrid','on','YGrid','on','GridAlpha',0.5)
        print(fig,printout(1:end-4),'-dpdf',['-r',num2str(res)])
    elseif strcmp(printout(end-2:end),'png')
        fig=figure('Color','white');
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on
        scatter(x,y,25,(1:length(x))','.')
        colormap jet, cb=colorbar; cb.Label.String='Time [points]';
        plot(x,polyval(p,x),'b','LineWidth',1.5)
        xlabel('x'), ylabel('y')
        set(ax,'Box','on','XGrid','on','YGrid','on','GridAlpha',0.5)
        print(fig,printout(1:end-4),'-dpng',['-r',num2str(res)])
    else
        sprintf('Invalid file format.')
    end
    
end

end