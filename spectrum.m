% Jakub Nowak 201706

% Calculates power spectral density of column signals with Welch method and
% plots the result.
%
% INPUT
%    x - data matrix with signals in consecutive columns or a column vector
%    f_samp - sampling frequency
%    printout - .pdf or .png filename for printout; other nonempty value plots
%       only on the screen
%    f_iner - frequency inertial range [f_iner_min f_iner_max] where -5/3
%       decay should be fitted
%
% OUTPUT
%    psd - power spectral density of signals from x in columns
%    fv - frequency vector corresponding to psd [Hz]
%    C - fitted -5/3 decay constant
%    fig - figure handle
%    ax - axes handle


function [psd,fv,C,fig,ax] = spectrum(x,f_samp,f_iner,printout)

if nargin<4, printout=''; end
if nargin<3, f_iner=[]; end

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
    C=exp(mean(log(psd(selIR,1))+5/3*log(fv(selIR))));
else
    C=[];
end


%% plot
res=300;
if ~isempty(printout)
    
    legStr=mat2cell(num2str((1:s(2))','ch%02d'),ones(1,s(2)))';
    p=length(psd(:,1));
    psdcell=mat2cell(psd,p,ones(1,s(2)));
    fvcell=mat2cell(repmat(fv,1,s(2)),p,ones(1,s(2)));
    if ~isempty(f_iner)
        psdcell=cat(2,psdcell,C*fv(selIR).^(-5/3));
        fvcell=cat(2,fvcell,fv(selIR));
        legStr=cat(2,legStr,'-5/3');
    end
    
    [fig,ax]=spectrumPlot(psdcell,fvcell,legStr);
    if strcmp(printout(end-2:end),'pdf') || strcmp(printout(end-2:end),'png')
        print(fig,printout(1:end-4),['-d',printout(end-2:end)],['-r',num2str(res)])
    end
    
else
    fig=[]; ax=[];
end

end