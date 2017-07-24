% Jakub Nowak 201706

% Stores all relevant parameters from ACTOS aquisition system in one .mat
% file. Needs path to the folder with raw .bin and preprocessed .lev1 ACTOS
% binary files.


path='C:\jnowak\AZORES2017\UFT\actos-azores\20170715\Data';
output='C:\jnowak\AZORES2017\UFT\20170715\actos_flight11_new';
starttime=[2017 7 15 0 0 0];


%% list of parameters

in={'pressure','final-serial_pressure_sensor.bin';
    'baroheight','BaroHeightAGL.lev1';
    'static','StaticPressure.lev1';
    % GPS
    'gpsTIME','final-serial_GPS-HPR_GPStime_sec.bin';
    'gpsSOW','final-serial_GPS_second_of_week.bin';
    'gpsSOD','GPS-SOD.lev1';
    'gpsALT','final-serial_GPS_altitude.bin';
    'gpsLAT','final-serial_GPS_latitude.bin';
    'gpsLON','final-serial_GPS_longitude.bin';
    'gpsU','final-serial_GPS_velocity_east.bin';
    'gpsV','final-serial_GPS_velocity_north.bin';
    'gpsW','final-serial_GPS_velocity_up.bin';
    'gpsHEAD','final-serial_GPS-HPR_heading_deg.bin';
    'gpsPITCH','final-serial_GPS-HPR_pitch_deg.bin';
    % IMAR
    'imarACCx','final-serial_iMAR_ACCS_x.bin';
    'imarACCy','final-serial_iMAR_ACCS_y.bin';
    'imarACCz','final-serial_iMAR_ACCS_z.bin';
    'imarALT','final-serial_iMAR_NLLH_alt.bin';
    'imarLAT','final-serial_iMAR_NLLH_lat.bin';
    'imarLON','final-serial_iMAR_NLLH_lon.bin';
    'imarPITCH','final-serial_iMAR_NRPY_pitch.bin';
    'imarROLL','final-serial_iMAR_NRPY_roll.bin';
    'imarYAW','final-serial_iMAR_NRPY_yaw.bin';
    'imarU','final-serial_iMAR_NVEL_u.bin';
    'imarV','final-serial_iMAR_NVEL_v.bin';
    'imarW','final-serial_iMAR_NVEL_w.bin';
    'imarOMGx','final-serial_iMAR_OMGS_x.bin';
    'imarOMGy','final-serial_iMAR_OMGS_y.bin';
    'imarOMGz','final-serial_iMAR_OMGS_z.bin';
    'imarTMOD','final-serial_iMAR_TMOD.bin';
    % HMP243
    'hmpDP','final-serial_HMP243_dew_point.bin';
    'hmpRH','final-serial_HMP243_relative_humidity.bin';
    'hmpT','final-serial_HMP243_temperature.bin';
    % dewpoint
    'dpAH','final-analog_DP_Mirror_DP-0_16bit.bin';
    'dpDP','final-analog_DP_Mirror_Tref_16bit.bin';
    'dpT','final-analog_DP_Mirror_TT-0_16bit.bin';
    'dp1AH','DP_Mirror_absHum.lev1';
    'dp1DP','DP_Mirror_DP.lev1';
    'dp1T','DP_Mirror_TT.lev1';
    % hotwire
    'hotwire1','final-analog_Hot_Wire_16bit_I.bin';
    'hotwire2','final-analog_Hot-Wire_16bit_II.bin';
    'hotwire3','final-analog_Hot-Wire_16bit_III.bin';
    % UFT
    'uft','final-analog_UFT_16bit_II.bin';
    'uftCal','UFTcal.lev1';
    % PVM
    'pvmLWC','final-analog_PVM_LWC_16bit.bin';
    'pvmPSA','final-analog_PVM_PSA_16bit.bin';
    'pvm1LWC','PVM_LWC.lev1';
    'pvm1PSA','PVM_PSA.lev1';
    'pvm1ERAD','PVM_EffRad.lev1';
    'pvm1QL','PVM_ql.lev1';
    % LICOR
    'licorH2O','final-analog_LiCor_H2O_16bit.bin';
    'licorCO2','final-analog_LiCor_CO2_16bit.bin';
    % LYMAN
    'lyman','final-analog_Lyman-alpha_16bit.bin';
    % PT100
    'pt100','final-analog_PT100CL13_16bit.bin';
    'pt100R','PT100-Rosemount.lev1';
    % SONIC
    'sonicPRT','final-serial_sonic_PRT_temp.bin';
    'sonicSOS','final-serial_sonic_SoS_or_sonic_temp.bin';
    'sonic1','final-serial_sonic_wind_component_1.bin';
    'sonic2','final-serial_sonic_wind_component_2.bin';
    'sonic3','final-serial_sonic_wind_component_3.bin';
    'sonicINCx','final-serial_sonic_inclinometer_x.bin';
    'sonicINCy','final-serial_sonic_inclinometer_y.bin';
    'sonicT','SonicTemp.lev1';
    % wind vector ??
%    'wvU','WindVector-u.lev1';
%    'wvV','WindVector-v.lev1';
%    'wvW','WindVector-w.lev1';
%    'wvUU','WindVector-UU.lev1';
%    'wvDD','WindVector-dd.lev1';
    % ???
    'density','AirDens.lev1';
    % CPC
    'cpc1','final-analog_CPC-I.bin';
    'cpc2','final-analog_CPC-II.bin';
    'cpc3','final-analog_CPC-III.bin';
    };

vars=in(:,1);
files=in(:,2);


%% read from binary files

for i=1:numel(files)
    fullfilepath=[path,filesep,files{i}];
    if exist(fullfilepath,'file')
        f=fopen([path,filesep,files{i}]);
        x=fread(f,'double');
        data.(vars{i})=reshape(x,2,length(x)/2)';
        fclose(f);
    else
        fprintf('No data for %s. Cannot find file %s\n',vars{i},files{i})
    end
end


%% synchronise devices

vars=fieldnames(data); N=numel(vars);
lengths=zeros(N,1);
tmin=zeros(N,1); tmax=zeros(N,1);

for i=1:N
    lengths(i)=length(data.(vars{i})(:,1));
    tmin(i)=data.(vars{i})(1,1);
    tmax(i)=data.(vars{i})(end,1);
end

minLength=1e3;
tstart=max(tmin(lengths>minLength & tmax>tmin));
tend=min(tmax(lengths>minLength & tmax>tmin));

for i=1:N
    if lengths(i)>=minLength
        ind1=find(data.(vars{i})(:,1)>=tstart,1,'first');
        ind2=find(data.(vars{i})(:,1)<=tend,1,'last');
        syncdata.(vars{i})=data.(vars{i})(ind1:ind2,2);
    else
        syncdata.(vars{i})=data.(vars{i});
    end
end


%% new variables

% sampling frequency
syncdata.samp=100;
% common time vector in sec from the start of recording
syncdata.time=syncdata.gpsSOD-2*syncdata.gpsSOD(1)+syncdata.gpsSOD(2);
% virtual temperature from sonic anemometer
syncdata.sonicTV=(syncdata.sonicSOS.^2/331.3^2-1)*273.15;
syncdata.starttime = datevec(datenum(starttime)+syncdata.gpsSOD(1)/3600/24);


%% save ACTOS .mat file

save(output,'-struct','syncdata')