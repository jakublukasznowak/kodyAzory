% Jakub Nowak 201706

function [f,ax,leg,ax2,leg2]=segmentPlot(y,time,vars,label,colors)

if nargin<5, colors={1,2,3,4,5,6,7,8;1,2,3,4,5,6,7,8}; end

N=size(y,2); Nax=size(y,1);
if Nax>1
    N1=sum(cellfun(@(x) ~isempty(x),y(1,:),'UniformOutput',true));
    N2=sum(cellfun(@(x) ~isempty(x),y(2,:),'UniformOutput',true));
else
    N1=N;
end

width=16; height=6.5;
f=figure('Color','white','PaperUnits','centimeters',...
    'PaperSize',[21 29.7],'PaperPosition',[(21-width)/2 29.7-2.5-height width height]);
ax=axes('Color','none','FontSize',8,'Position',[0.10 0.13 0.80 0.83]);
hold on

co=get(gca,'ColorOrder');
for i=1:Nax
    for j=1:N
        if isscalar(colors{i,j}) && isnumeric(colors{i,j})
            colors{i,j}=co(colors{i,j},:);
        end
    end
end


%% left axis
timeLim=[1e5 -1e5];
for i=1:N1
    timeLim(1)=min([timeLim(1) min(time{1,i})]); timeLim(2)=max([timeLim(2) max(time{1,i})]);
    plot(time{1,i},y{1,i},'Color',colors{1,i});
end

xlabel('Time [s]')%'Interpreter','latex')
ylabel(label{1})%'Interpreter','latex')
set(ax,'XLim',timeLim,'Box','off',...
    'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
    'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5,...
    'YLim',[floor(min(cell2mat(y(1,:)'))) ceil(max(cell2mat(y(1,:)')))])

if ~isempty(vars)
    legStr=vars(1,1:N1);
    leg=legend(legStr,'Location','north','Orientation','horizontal');
    set(leg,'Position',get(leg,'Position')+[0 0.065 0 0])
else
    leg=[];
end


%% right axis
if Nax>1
    ax2=axes('Color','none','FontSize',8,'Position',[0.10 0.13 0.80 0.83]);
    hold on
    for i=1:N2
        plot(time{2,i},y{2,i},'Color',colors{2,i});
    end
    
    ylabel(label{2})%,'Interpreter','latex')
    set(ax2,'XLim',timeLim,'Box','off',...
        'YAxisLocation','right','XTickLabel',[],...
        'XGrid','off','YGrid','off','XMinorGrid','off','YMinorGrid','off',...
        'YLim',[min(y{2,i}) max(y{2,i})])
    
    if ~isempty(vars)
        legStr2=vars(2,1:N2);
        leg2=legend(legStr2,'Location','north','Orientation','horizontal');
        set(leg2,'Position',get(leg2,'Position')+[0.13 0.065 0 0])
        set(leg,'Position',get(leg,'Position')+[-0.13 0 0 0])
    else
        leg2=[];
    end
else
    ax2=[];
end

end