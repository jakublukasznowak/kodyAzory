% Jakub Nowak 2016 09 27
% dupa dupa dupa

function x = importUFT(filename,range,Nchannels)

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
