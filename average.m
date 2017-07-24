% Jakub Nowak 201706
% bla bla

% Calculates column averages of specified type over selected number of points 
%
% INPUT
%    x - data matrix with signals in consecutive columns or column vector
%    M - number of points to average over
%    type - type of the average:
%       'segment' - nonoverlaping averaging window
%       'moving' - overlaping averaging window, preserves number of points
%
% OUTPUT
%    av - averaged signals in columns


function av = average(x,M,type)

if nargin<3, type='segment'; end
s=size(x);


if strcmp(type,'moving') || strcmp(type,'m')
    m=floor(M/2);
    av=nan(s);
    for j=1:s(2)
        for i=1:s(1)
            i1=max([i-m 1]);
            i2=min([i+m s(1)]);
            av(i,j)=mean(x(i1:i2,j));
        end
    end
    
elseif strcmp(type,'segment') || strcmp(type,'s')
    M=round(M);
    N=floor(s(1)/M);
    av=nan(N,s(2));
    for j=1:s(2)
        av(:,j)=mean(reshape(x(1:N*M,j),M,N),1)';
    end
    
else
    error('Invalid type :(')
end

end
