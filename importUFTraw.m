% Jakub Nowak 201706

% INPUT
%    filename - binary file saved by DAC on SD card
%    range - voltage range [V] set on DAC (e.g. 1 V, 5 V)
%    Nchannels - number of channels used
%
% OUTPUT
%    x - matrix with columns corresponding to consecutive channels
%
% Callibration coefficients were obtained for ranges 1V and 5V by comparison
% with .csv output file produced by DAQLog software.

function x = importUFTraw(filename,range,Nchannels)

f=fopen(filename);
fseek(f,2*16^3,'bof');

if range==5
    a=1.6431e-4;
    b=-5.3170;
elseif range==1
    a=3.2890e-5;
    b=-1.0645;
else
    a=1;
    b=0;
end

x=a*fread(f,'uint16','l')+b;

x=reshape(x,Nchannels,floor(length(x)/Nchannels))';

fclose(f);

end
