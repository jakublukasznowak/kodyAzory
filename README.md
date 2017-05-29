# kodyAzory

The repository contains a set of simple matlab scripts to preprocess data
collected by UltraFast Thermometer mounted on ACTOS measurement platform.

When you use the code, please mention the author:
Jakub Nowak, Institute of Geophysics, University of Warsaw

Standard workflow:
(1) prepare common .mat flight file with ACTOS data [makeACTOSfile]
(2) prepare .mat flight file with UFT signals [makeUFTfile]
    (a) import raw binary data [importUFTraw]
    (b) synchronize time comparing one base variable collected by UFT's DAQ
        and one reference variable from ACTOS aquisition system (e.g. 'upV'
        and 'sonicPRT' for upper UFT voltage and PT thermometer) [findDelay]
    (c) callibrate UFT temperature readings versus reference instrument
        onboard ACTOS [polyCalib]
(3) look at time series plots of different quantities for selected segements
    of the flight [plotTimeSegment]
(4) examine power spectral density of the instruments [spectra]
        
