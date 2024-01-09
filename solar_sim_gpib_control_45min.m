% =========================================================================
% MATLAB program to control Agilent E4350B Solar Array Simulator using 
% Prologix
% GPIB-USB Controller 4.2.
%
% E4350B is configured as TALKER/LISTENER and GPIB address 1.
% 
% Output will be as follows:
%
% Prologix GPIB-USB Controller version 6.107
% HEWLETT-PACKARD,E4350B,0,fA.01.03sB.00.00pA.01.01
% =========================================================================

% Specify the virtual serial port created by USB driver. Other serial port
% parameters don't matter
diary on
instrreset;
sport = serial('COM4');

% Prologix Controller 4.2 requires CR as command terminator, LF is
% optional. The controller terminates internal query responses with CR and
% LF. Responses from the instrument are passed through as is. (See Prologix
% Controller Manual)
sport.Terminator = 'CR/LF';

% Reduce timeout to 0.5 second (default is 10 seconds)
sport.Timeout = 0.5;

% =========================================================================
% Method #1 uses fgets to read controller response. Since the Prologix
% controller always terminates internal query responses with CR/LF which is
% same as the currently specified serial port terminator, this method will
% work fine.
% =========================================================================

% Open virtual serial port
fopen(sport);

% Send Prologix Controller query version command
fprintf(sport, '++ver');

% Read and display response
ver = fgets(sport);
disp(ver);

% Close port
fclose(sport);

% =========================================================================
% Method #2 uses fread to read instrument response. In this case we read
% until the specified number of bytes are received or until timeout occurs.
% If the specified number of bytes are not received before timeout MATLAB
% will generate a "not enough data read before timeout" warning.
% =========================================================================

% Suppress "not enough data read before timeout" warning
warning('off','MATLAB:serial:fread:unsuccessfulRead');

fopen(sport);

% Configure as Controller (++mode 1), instrument address 1, and with
% read-after-write (++auto 1) enabled
fprintf(sport, '++mode 1');
fprintf(sport, '++addr 1');
fprintf(sport, '++auto 1');


%% reset 
fprintf(sport, '*RST');
fclose(sport);

%% Start Setup
% Suppress "not enough data read before timeout" warning
warning('off','MATLAB:serial:fread:unsuccessfulRead');

fopen(sport);

% Configure as Controller (++mode 1), instrument address 1, and with
% read-after-write (++auto 1) enabled
fprintf(sport, '++mode 1');
fprintf(sport, '++addr 1');
fprintf(sport, '++auto 1');


%% Set Volage, Current, and Solar Array Simulator Mode

% Set mode to solar array simulator
fprintf(sport,strcat('CURR:MODE SAS'));
fread(sport, 50);

% Set to close to measured values from Professor Goryll
%fprintf(sport,'CURR:SAS:ISC 0.380;IMP 0.340;:VOLT:SAS:VOC 5.35;VMP 4.8')
fprintf(sport,'CURR:SAS:ISC 0.380;IMP 0.340;:VOLT:SAS:VOC 5.45;VMP 4.9')
fread(sport, 50);

% Send query to check mode
fprintf(sport,'CURR:MODE?');
% Read 20 bytes or until timeout expires
new_mode = fread(sport, 50);
% Display mode
disp( ['New Mode: ', sprintf('%c', new_mode)] );

% Send query to check voltage
fprintf(sport,'SOUR:VOLT:LEV?');
% Read 20 bytes or until timeout expires
new_volt = fread(sport, 50);
% Display voltage
disp( ['New Voltage: ', sprintf('%c', new_volt)] );

% Send query to check current
fprintf(sport,'SOUR:CURR:LEV?');
% Read 20 bytes or until timeout expires
new_curr = fread(sport, 50);
% Display voltage
disp( ['New Current: ', sprintf('%c', new_curr)] );

% Send query to check short circuit current
fprintf(sport,'SOUR:CURR:SAS:ISC?');
% Read 20 bytes or until timeout expires
new_isc = fread(sport, 50);
% Display voltage
disp( ['New Short Circuit Current: ', sprintf('%c', new_isc)] );

% Send query to check open circuit voltage
fprintf(sport,'SOUR:VOLT:SAS:VOC?');
% Read 20 bytes or until timeout expires
new_voc = fread(sport, 50);
% Display voltage
disp( ['New Open Circuit Voltage: ', sprintf('%c', new_voc)] );

% Send query to check maximum power current
fprintf(sport,'SOUR:CURR:SAS:IMP?');
% Read 20 bytes or until timeout expires
new_imp = fread(sport, 50);
% Display voltage
disp( ['New Max Power Current: ', sprintf('%c', new_imp)] );

% Send query to check maximum power voltage
fprintf(sport,'SOUR:VOLT:SAS:VMP?');
% Read 20 bytes or until timeout expires
new_vmp = fread(sport, 50);
% Display voltage
disp( ['New Max Power Voltage: ', sprintf('%c', new_vmp)] );

% infinite loop turning on and off solar array simulator every 45 minutes
loop_count = 0;
charg_imp = zeros(1,16);
charg_vmp = zeros(1,16);
while(true)
    pause on
    
    loop_count = loop_count + 1;
    disp(' ');
    disp(['Orbit Number: ', num2str(loop_count)]);
    
    fprintf(sport,'OUTP ON');
    daytime = now;
    disp(['Daytime ', datestr(daytime)]);
    pause(3)
    % Charging Current
    fprintf(sport,'MEAS:CURR?');
    % Read 20 bytes or until timeout expires
    chrg_imp = fread(sport, 50);
    % Display charging current
    disp(['Charging Current: ', sprintf('%c', chrg_imp(1:(end-1)))]);
    
    % Charging Voltage
    fprintf(sport,'MEAS:VOLT?');
    % Read 20 bytes or until timeout expires
    chrg_vmp = fread(sport, 50);
    % Display charging current
    disp(['Charging Voltage: ', sprintf('%c', chrg_vmp(1:end-1))]);
    
    pause(45*60)
    fprintf(sport,'OUTP OFF');
    nighttime = now;
    disp(['Nighttime ', datestr(nighttime)]);
    pause(45*60)
    
    disp(['Orbital time:', datestr(nighttime-daytime,13)]);
end
