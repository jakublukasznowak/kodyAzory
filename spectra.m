% Jakub Nowak 201705

% Calculates power spectral density of column signals with Welch method and
% plots the result.
%
% INPUT
%    x - data matrix with signals in consecutive columns or a column vector
%    f_samp - sampling frequency
%    printout - .pdf or .png filename for printout; if skipped or empty
%       plot appears only on the screen
%    f_iner - frequency inertial range [f_iner_min f_iner_max] where -5/3
%       decay should be fitted
%
% OUTPUT
%    psd - power spectral density of signals from x in columns
%    fv - frequency vector corresponding to psd [Hz]


function [psd,fv] = spectra(x,f_samp,printout,f_iner)

if nargin<4, f_iner=[]; end
if nargin<3, printout=''; end

s=size(x);


%% calculate PSD

window=[];
noverlap=[];
nfft=[];

[psd,fv]=pwelch(x(:,1)-mean(x(:,1)),window,noverlap,nfft,f_samp);
if s(2)>1
    for j=2:s(2)
        psd=cat(2,psd,pwelch(x(:,j)-mean(x(:,j)),window,noverlap,nfft,f_samp));
    end
end

% fit -5/3 decay
if ~isempty(f_iner)
    selIR=find(fv>=f_iner(1),1,'first'):find(fv<=f_iner(2),1,'last');
    C1=exp(mean(log(psd(selIR,1))+5/3*log(fv(selIR))));
end


%% plot

res=300;

legStr=mat2cell([num2str((1:s(2))','ch%02d'),num2str((1:s(2))'-1,'*1e%d')],ones(1,s(2)),8);
if ~isempty(f_iner)
    legStr=cat(1,legStr,'-5/3');
end

if isempty(printout)
    
    figure
    ax=axes('Color','none','FontSize',8);
    hold on
    
    for j=1:s(2), plot(fv,psd(:,j)*10^(j-1)), end
    if ~isempty(f_iner), plot(fv(selIR),C1*fv(selIR).^(-5/3),'LineWidth',2), end
    
    legend(legStr,'Location','northeast');
    xlabel('Frequency [Hz]')
    ylabel('PSD [??]')
    set(ax,'XLim',[fv(1) f_samp/2],'XScale','log','YScale','log',...
            'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
            'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5,...
            'Box','on','PlotBoxAspectRatio',[1 1 1])    
else
        
    if strcmp(printout(end-2:end),'pdf')

        fig=figure('Color','white','PaperUnits','centimeters',...
            'PaperSize',[21 29.7],'PaperPosition',[1.25 1.25 21-2.5 29.7-2.5]);
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on

        for j=1:s(2), plot(fv,psd(:,j)*10^(j-1)), end
        if ~isempty(f_iner), plot(fv(selIR),C1*fv(selIR).^(-5/3),'LineWidth',2), end

        legend(legStr,'Location','northeast');
        xlabel('Frequency [Hz]')
        ylabel('PSD [??]')
        set(ax,'XLim',[fv(1) f_samp/2],'XScale','log','YScale','log',...
                'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
                'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5,...
                'Box','on','PlotBoxAspectRatio',[1 1 1])

        print(fig,printout(1:end-4),'-dpdf',['-r',num2str(res)])

    elseif strcmp(printout(end-2:end),'png')

        fig=figure('Color','white');
        ax=axes('Color','none','FontSize',8,'Position',[0.07 0.07 1-0.07-0.07 1-0.07-0.07]);
        hold on

        for j=1:s(2), plot(fv,psd(:,j)*10^(j-1)), end
        if ~isempty(f_iner), plot(fv(selIR),C1*fv(selIR).^(-5/3),'LineWidth',2), end

        legend(legStr,'Location','northeast');
        xlabel('Frequency [Hz]')
        ylabel('PSD [??]')
        set(ax,'XLim',[fv(1) f_samp/2],'XScale','log','YScale','log',...
                'XGrid','on','GridAlpha',0.5,'XMinorGrid','on','MinorGridAlpha',0.5,...
                'YGrid','on','GridAlpha',0.5,'YMinorGrid','on','MinorGridAlpha',0.5,...
                'Box','on','PlotBoxAspectRatio',[1 1 1])

        print(fig,printout(1:end-4),'-dpng',['-r',num2str(res)])

    else 
        sprintf('Invalid file format.')
    end

end


end