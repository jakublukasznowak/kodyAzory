function [ LWC1 ] = LWClev1( LWCbin, samp )
%function [ LWC1 ] = LWClev1( LWCbin, samp )
%   Making level 1 from a pure LWC data
%   Input:
%     LWCbin - a vector with a LWC signal
%     samp - sampling of a LWC signal [Hz]
%   Output:
%     LWC1 - a vector with postprocessed signal (level 1)


offset = median(LWCbin(1:samp*600)); % offset is a median from the first 10 mins of a record

LWC1 = LWCbin - offset;
LWC1(LWC1 < 0.01) = 0;

end