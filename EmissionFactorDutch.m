function F = EmissionFactorDutch(varargin)
    % Factors = EmissionFactorDutch
    %
    % Returns a dictionary containing the defined Dutch emission factors
    % for non motorways for PM10, PM2.5, NO2 and NOx, or a single emission
    % factor, depending on input arguments.
    %
    % USAGE
    % D = EmissionFactorDutch
    % D = EmissionFactorDutch(Pollutant)
    % D = EmissionFactorDutch(Pollutant, VehicleClass)
    % F = EmissionFactorDutch(Pollutant, VehicleClass, SpeedClass)
    %
    % Factors where taken from the published spreadsheet downloaded in
    % September 2015. The spreadsheet is uploaded annualy and can be
    % downloaded from http://tinyurl.com/EF-NonMotorway.
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   EmissionFactorDutch.m  $
    % $Revision:   1.0  $
    % $Author:   edward.barratt  $
    % $Date:   Nov 24 2016 09:19:14  $
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    Factors.PM10.Light.Stagnated = 0.0437;
    Factors.PM10.Light.Normal = 0.0399;
    Factors.PM10.Light.Smooth = 0.0401;
    Factors.PM10.Light.LargeRoad = 0.0212;
    Factors.PM10.Medium.Stagnated = 0.2478;
    Factors.PM10.Medium.Normal = 0.1930;
    Factors.PM10.Medium.Smooth = 0.1664;
    Factors.PM10.Medium.LargeRoad = 0.1116;
    Factors.PM10.Heavy.Stagnated = 0.2669;
    Factors.PM10.Heavy.Normal = 0.2025;
    Factors.PM10.Heavy.Smooth = 0.1713;
    Factors.PM10.Heavy.LargeRoad = 0.1129;
    Factors.PM10.Bus.Stagnated = 0.3828;
    Factors.PM10.Bus.Normal = 0.2443;
    Factors.PM10.Bus.Smooth = 0.1825;
    Factors.PM10.Bus.LargeRoad = 0.1638;

    Factors.PM25.Light.Stagnated = 0.0224;
    Factors.PM25.Light.Normal = 0.0186;
    Factors.PM25.Light.Smooth = 0.0188;
    Factors.PM25.Light.LargeRoad = 0.0102;
    Factors.PM25.Medium.Stagnated = 0.1461;
    Factors.PM25.Medium.Normal = 0.0913;
    Factors.PM25.Medium.Smooth = 0.0646;
    Factors.PM25.Medium.LargeRoad = 0.0560;
    Factors.PM25.Heavy.Stagnated = 0.1718;
    Factors.PM25.Heavy.Normal = 0.1074;
    Factors.PM25.Heavy.Smooth = 0.0762;
    Factors.PM25.Heavy.LargeRoad = 0.0618;
    Factors.PM25.Bus.Stagnated = 0.3054;
    Factors.PM25.Bus.Normal = 0.1668;
    Factors.PM25.Bus.Smooth = 0.1050;
    Factors.PM25.Bus.LargeRoad = 0.1214;

    Factors.NO2.Light.Stagnated = 0.1500;
    Factors.NO2.Light.Normal = 0.0900;
    Factors.NO2.Light.Smooth = 0.0900;
    Factors.NO2.Light.LargeRoad = 0.0800;
    Factors.NO2.Medium.Stagnated = 0.7300;
    Factors.NO2.Medium.Normal = 0.4400;
    Factors.NO2.Medium.Smooth = 0.2900;
    Factors.NO2.Medium.LargeRoad = 0.2800;
    Factors.NO2.Heavy.Stagnated = 0.7900;
    Factors.NO2.Heavy.Normal = 0.4800;
    Factors.NO2.Heavy.Smooth = 0.3200;
    Factors.NO2.Heavy.LargeRoad = 0.3000;
    Factors.NO2.Bus.Stagnated = 1.0400;
    Factors.NO2.Bus.Normal = 0.6500;
    Factors.NO2.Bus.Smooth = 0.4700;
    Factors.NO2.Bus.LargeRoad = 0.4400;

    Factors.NOx.Light.Stagnated = 0.6100;
    Factors.NOx.Light.Normal = 0.3800;
    Factors.NOx.Light.Smooth = 0.3900;
    Factors.NOx.Light.LargeRoad = 0.2700;
    Factors.NOx.Medium.Stagnated = 12.500;
    Factors.NOx.Medium.Normal = 7.6000;
    Factors.NOx.Medium.Smooth = 5.2000;
    Factors.NOx.Medium.LargeRoad = 4.8000;
    Factors.NOx.Heavy.Stagnated = 16.600;
    Factors.NOx.Heavy.Normal = 10.100;
    Factors.NOx.Heavy.Smooth = 7.0000;
    Factors.NOx.Heavy.LargeRoad = 5.6000;
    Factors.NOx.Bus.Stagnated = 10.300;
    Factors.NOx.Bus.Normal = 6.4000;
    Factors.NOx.Bus.Smooth = 4.6000;
    Factors.NOx.Bus.LargeRoad = 4.1000;
    
    if nargin == 0
        F = Factors;
    elseif nargin == 1
        F = Factors.(varargin{1});
    elseif nargin == 2
        F = Factors.(varargin{1}).(varargin{2});
    elseif nargin > 2
        F = Factors.(varargin{1}).(varargin{2}).(varargin{3});
    end
end


