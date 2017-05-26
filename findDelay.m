% Jakub Nowak 201705

% Gives time lag of one signal versus another by maximizing correlation
% coefficient.
%
% INPUT
%    sb - base signal in the form of column vector
%    sa - matrix of column signals to be synchronized with sb
%    maxlag - maximum range of translations applied [in # of points]
%    printout - .pdf or .png filename for correlation plot printout
%
% OUTPUT
%    dl - best lag for each column of sa (maximazing correlation with sb)
%    corr - correlation coefficients where rows correspond to different
%       translations and columns to signals included in sa
%    lagV - vector of all translations applied [in # of points]


function [dl,corr,lagV] = findDelay (sb,sa,maxlag,printout)

if nargin<4, printout=''; end

Lb=length(sb); s=size(sa); La=s(1); Na=s(2);
if nargin<3, maxlag=round(min([Lb La])/10); end

if La~=Lb
    disp('Warning: signals sa and sb have different length.')
    L=min([La Lb]);
    sa=sa(1:L,:); sb=sb(1:L);
end


%% correlate signals

lagV=-maxlag:1:maxlag;
corr=zeros(2*maxlag+1,Na);
dl=zeros(1,Na);

for i=1:Na 
    for j=1:2*maxlag+1
%         tempcorr=corrcoef([ones(max([0 -lagV(j)]),1)*mean(sb); sb; ones(max([0 lagV(j)]),1)*mean(sb)],...
%             [ones(max([0 lagV(j)]),1)*mean(sa(:,i)); sa(:,i); ones(max([0 -lagV(j)]),1)*mean(sa(:,i))]);
        tempcorr=corrcoef(sb(maxlag+1:Lb-maxlag),sa(maxlag+1-lagV(j):La-maxlag-lagV(j),i));
        corr(j,i)=tempcorr(1,2);
    end
    [~,ind]=max(abs(corr(:,i)));
    dl(i)=lagV(ind);
end


%% plot

res=300;

if isempty(printout)
    
    figure
    ax=axes('Color','none','FontSize',8);
    hold on
    for i=1:Na, plot(lagV,corr(:,i),'.'), end
    xlabel('Lag [points]')
    ylabel('Correlation coefficient [a.u.]')
    legend(num2str((1:Na)','ch%02d'))
    set(ax,'XLim',[lagV(1) lagV(end)],'Box','on',...
        'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
        'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
    
else
    
    if strcmp(printout(end-2:end),'pdf')
        fig=figure('Color','white','PaperUnits','centimeters',...
            'PaperSize',[21 29.7],'PaperPosition',[1.25 1.25+(29.7-2.5)/2 21-2.5 (29.7-2.5)/2]);
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on
        for i=1:Na, plot(lagV,corr(:,i),'.'), end
        xlabel('Lag [points]')
        ylabel('Correlation coefficient [a.u.]')
        legend(num2str((1:Na)','ch%02d'))
        set(ax,'XLim',[lagV(1) lagV(end)],'Box','on',...
            'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
            'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
        print(fig,printout(1:end-4),'-dpdf',['-r',num2str(res)])
    elseif strcmp(printout(end-2:end),'png')
        fig=figure('Color','white');
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on
        for i=1:Na, plot(lagV,corr(:,i),'.'), end
        xlabel('Lag [points]')
        ylabel('Correlation coefficient [a.u.]')
        legend(num2str((1:Na)','ch%02d'))
        set(ax,'XLim',[lagV(1) lagV(end)],'Box','on',...
            'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
            'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)
        print(fig,printout(1:end-4),'-dpng',['-r',num2str(res)])
    else
        sprintf('Invalid file format.')
    end
    
end

end