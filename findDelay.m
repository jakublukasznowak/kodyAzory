% Jakub Nowak 201707

% Gives time lag of one signal versus another by maximizing correlation
% coefficient.
%
% INPUT
%    sb - base signal in the form of column vector
%    sa - matrix of column signals to be synchronized with sb
%    maxlag - maximum range of translations applied [in # of points]
%    printout - .pdf or .png filename for correlation plot printout; other
%       nonempty value plots only on the screen
%
% OUTPUT
%    dl - best lag for each column of sa (maximazing correlation with sb)
%    corr - correlation coefficients where rows correspond to different
%       translations and columns to signals included in sa
%    lagV - vector of all translations applied [in # of points]
%    fig - figure handle
%    ax - axes handle


function [dl,corr,lagV,fig,ax] = findDelay (sb,sa,maxlag,printout)

if nargin<4, printout=''; end


Lb=length(sb); s=size(sa); La=s(1); Na=s(2);
if nargin<3, maxlag=round(min([Lb La])/10); end

if La~=Lb
    disp('Warning: signals sa and sb have different length.')
    L=min([La Lb]);
    sa=sa(1:L,:); sb=sb(1:L);
end


%% correlate signals
lagV=(-maxlag:1:maxlag)'; Ll=2*maxlag+1;
corr=zeros(Ll,Na);
dl=zeros(1,Na);

for i=1:Na 
    for j=1:2*maxlag+1
%         tempcorr=corrcoef([ones(max([0 -lagV(j)]),1)*mean(sb); sb; ones(max([0 lagV(j)]),1)*mean(sb)],...
%             [ones(max([0 lagV(j)]),1)*mean(sa(:,i)); sa(:,i); ones(max([0 -lagV(j)]),1)*mean(sa(:,i))]);
        tempcorr=corrcoef(sb(maxlag+1:Lb-maxlag),sa(maxlag+1-lagV(j):La-maxlag-lagV(j),i));
        corr(j,i)=tempcorr(1,2);
        fprintf('%d out of %d done\n',j,2*maxlag+1)
    end
    [~,ind]=max(abs(corr(:,i)));
    dl(i)=lagV(ind);
end


%% plot
res=300;
if ~isempty(printout)
    legStr='';
    %legStr=mat2cell(num2str((1:Na)','ch%02d'),ones(1,Na))';
    corrcell=mat2cell(corr,Ll,ones(1,Na));
    lagcell=mat2cell(repmat(lagV,1,Na),Ll,ones(1,Na));
    
    [fig,ax]=delayPlot(corrcell,lagcell,legStr);
    if strcmp(printout(end-2:end),'pdf') || strcmp(printout(end-2:end),'png')
        print(fig,printout(1:end-4),['-d',printout(end-2:end)],['-r',num2str(res)])
    end
    
else
    fig=[]; ax=[];
end
    
end



function [f,ax] = delayPlot(corr,lag,vars)

N=numel(corr);

width=12; height=10;
f=figure('Color','white','PaperUnits','centimeters',...
    'PaperSize',[21 29.7],'PaperPosition',[(21-width)/2 29.7-2.5-height width height]);
ax=axes('Color','none','FontSize',8,'Position',[0.12 0.12 0.83 0.83]);
hold on
                   
lagLim=[1e5 -1e5];
for i=1:N
    lagLim(1)=min([lagLim(1) min(lag{i})]); lagLim(2)=max([lagLim(2) max(lag{i})]);
    plot(lag{i},corr{i},'.')
end
if ~isempty(vars), legend(vars,'Location','northeast'), end
ylabel('Correlation coefficient [a.u.]')
xlabel('Delay [samples]')
set(ax,'XLim',lagLim,'Box','on',...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5)

end