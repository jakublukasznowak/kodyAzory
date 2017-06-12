% Jakub Nowak 201706

function [f,ax]=spectrumPlot(psd,fv,vars,Mv,factors,colors,colorsM)

N=numel(psd);

if nargin<7, colorsM={'c','b','g','r'}; end
if nargin<6, colors={2,3,4,1,5}; end
if nargin<5, factors=10.^-(0:2:2*(N-1)); end
if nargin<4, Mv=zeros(1,N); end

width=12;
f=figure('Color','white','PaperUnits','centimeters',...
    'PaperSize',[21 29.7],'PaperPosition',[(21-width)/2 29.7-2.5-width width width]);
ax=axes('Color','none','FontSize',8,'Position',[0.12 0.12 0.83 0.83]);
hold on

co=get(gca,'ColorOrder');
for i=1:numel(colorsM)
    if isscalar(colorsM{i}) && isnumeric(colorsM{i})
        colorsM{i}=co(colorsM{i},:);
    end
end
for i=1:numel(colors)
    if isscalar(colors{i}) && isnumeric(colors{i})
        colors{i}=co(colors{i},:);
    end
end

skip=3;
fvLim=[1e5 -1e5];
legStr=vars;
for i=1:N
    fvLim(1)=min([fvLim(1) min(fv{i})]); fvLim(2)=max([fvLim(2) max(fv{i})]);
    if strcmp(vars{i},'-5/3'), ln=2; factors(i)=1; else ln=0.5; end
    plot(fv{i}(skip:end),psd{i}(skip:end)*factors(i),'Color',colors{i},'LineWidth',ln);
    if factors(i)~=1, legStr{i}=[legStr{i},'*',num2str(factors(i),'%1.0e')]; end
end

skipAv=2;
for i=1:N
    if Mv(i)>1
        psdtemp=average(psd{i},Mv(i),'segment');
        fvtemp=average(fv{i},Mv(i),'segment');
        plot(fvtemp(skipAv:end),psdtemp(skipAv:end)*factors(i),'Color',colorsM{i})
        legStr=cat(2,legStr,[vars{i},'av',num2str(Mv(i),'%dp')]);
        if factors(i)~=1, legStr{end}=[legStr{end},'*',num2str(factors(i),'%1.0e')]; end
    end
end

legend(legStr,'Location','northeast');
xlabel('Frequency [Hz]')
ylabel('PSD')
set(ax,'XLim',fvLim,'XScale','log','YScale','log',...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5,...
    'Box','on')%,'PlotBoxAspectRatio',[1 1 1])

end