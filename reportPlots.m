
fn=2;
path='/home/pracownicy/jnowak/uft/dataWinningen';
output='/home/pracownicy/jnowak/uft/raport/plots';

frm='png';
position='h';

ssT={{'1','2','3'},{'A1','C1','C2','A2','A3','C3'}};
timeSegT={[700 750;
     1380 1410;
     1770 1820];
     [500 600;
     750 780;
     990 1020;
     1080 1110;
     1325 1375;
     1490 1540]};
     
ss=ssT{fn}; timeSeg=timeSegT{fn};
N=length(timeSeg(:,1));



%% load data

actosfile=sprintf('%s/actos_flight%02d.mat',path,fn);
uftfile=sprintf('%s/uft_flight%02d.mat',path,fn);
prefix=sprintf('flight%02d',fn);

actos=load(actosfile);
uft=load(uftfile);

% if ~isfield(actos,'cloudmask')
%     maskLWCthresh=0.02;
%     maskLWCdill=1; % [s]
%     actos.cloudmask=(average(actos.pvm1LWC,11,'m')>maskLWCthresh);
%     actos.cloudmask=(average(actos.cloudmask,maskLWCdill*100,'m')>0);
% end

timeTakeOff=actos.time(find(actos.pressure<0.99*max(actos.pressure),1,'first'));
timeLanding=actos.time(find(actos.pressure<0.99*max(actos.pressure),1,'last'));
actos.time=actos.time-timeTakeOff+1/actos.samp;
uft.time_av=uft.time_av-timeTakeOff+1/uft.samp_av;



%% plot segments

for sn=1:N
    fprintf('\\subsubsection{Segment %s (%04d-%04d s)}\n\n',ss{sn},timeSeg(sn,1),timeSeg(sn,2))
    
    % time plots
    fileName=[prefix,num2str(sn,'seg%02d')];
    plotSegments(actos,uft,timeSeg(sn,:),[output,filesep,fileName,'.',frm])
    close all
    
    suffixes={'lwc','uft','temp','humid','sonic','imar'};
    captions1=sprintf('Flight %d, segment %s. ',fn,ss{sn});
    captions2={'Pressure and liquid water content.',...
        'UFT-2 temperature.',...
        'ACTOS instruments temperature.',...
        'Humidity.',...
        'Wind velocity with respect to the platform.',...
        'Platform velocity with respect to ground.'};
    labels1=sprintf('%d:seg%s:',fn,ss{sn});
    for j=1:6
        fprintf(['\\begin{figure}[%s]\n',...
            '\\centering\n',...
            '\\includegraphics{../plots/%s}\n',...
            '\\caption[]{%s}\n',...
            '\\label{fig:%s}\n',...
            '\\end{figure}\n\n'],...
            position,[fileName,suffixes{j}],[captions1 captions2{j}],[labels1 suffixes{j}])
    end
    
    
    % psd plots
    fileName=[prefix,num2str(sn,'seg%02dpsd')];
    plotSpectra(actos,uft,timeSeg(sn,:),[output,filesep,fileName,'.',frm],[50 0])
    close all
    
    suffixes={'temp','humid'};
    captions1=sprintf('Flight %d, segment %s. ',fn,ss{sn});
    captions2={'Temperature spectrum.',...
        'Humidity spectrum.'};
    labels1=sprintf('%d:seg%s:psd',fn,ss{sn});
    for j=1:2
        fprintf(['\\begin{figure}[%s]\n',...
            '\\centering\n',...
            '\\includegraphics{../plots/%s}\n',...
            '\\caption[]{%s}\n',...
            '\\label{fig:%s}\n',...
            '\\end{figure}\n\n'],...
            position,[fileName,suffixes{j}],[captions1 captions2{j}],[labels1 suffixes{j}])
    end
end



%% plot whole flight

fprintf('\\subsection{Overview}\n\n')

% time plots
fileName=[prefix,num2str(0,'seg%02d')];
plotSegments(actos,uft,[timeTakeOff timeLanding]-timeTakeOff,[output,filesep,fileName,'.',frm])
close all

suffixes={'lwc','uft','temp','humid','sonic','imar'};
captions1=sprintf('Flight %d. ',fn);
captions2={'Pressure and liquid water content.',...
    'UFT-2 temperature.',...
    'ACTOS instruments temperature.',...
    'Humidity.',...
    'Wind velocity with respect to the platform.',...
    'Platform velocity with respect to ground.'};
labels1=sprintf('%d:',fn);
for j=1:6
    fprintf(['\\begin{figure}[%s]\n',...
        '\\centering\n',...
        '\\includegraphics{../plots/%s}\n',...
        '\\caption[]{%s}\n',...
        '\\label{fig:%s}\n',...
        '\\end{figure}\n\n'],...
        position,[fileName,suffixes{j}],[captions1 captions2{j}],[labels1 suffixes{j}])
end


% psd plots
fileName=[prefix,num2str(0,'seg%02dpsd')];
plotSpectra(actos,uft,[timeTakeOff timeLanding]-timeTakeOff,[output,filesep,fileName,'.',frm],[500 0])
close all

suffixes={'temp','humid'};
captions1=sprintf('Flight %d. ',fn);
captions2={'Temperature spectrum.',...
    'Humidity spectrum.'};
labels1=sprintf('%d:psd',fn);
for j=1:2
    fprintf(['\\begin{figure}[%s]\n',...
        '\\centering\n',...
        '\\includegraphics{../plots/%s}\n',...
        '\\caption[]{%s}\n',...
        '\\label{fig:%s}\n',...
        '\\end{figure}\n\n'],...
        position,[fileName,suffixes{j}],[captions1 captions2{j}],[labels1 suffixes{j}])
end