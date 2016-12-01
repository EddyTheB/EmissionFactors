function F = EmissionFactorDutch(varargin)
    % Factors = EmissionFactorDutch
    %
    % Returns a dictionary containing the defined Dutch emission factors
    % for non motorways for PM10, PM2.5, NO2 and NOx, or a single emission
    % factor, depending on input arguments.
    %
    % USAGE
    % F = EmissionFactorDutch
    % F = EmissionFactorDutch(Pollutant)
    % F = EmissionFactorDutch(Pollutant, VehicleClass)
    % F = EmissionFactorDutch(Pollutant, VehicleClass, SpeedClass)
    % F = EmissionFactorDutch(Pollutant, VehicleClass, SpeedClass)
    % F = EmissionFactorDutch( ... '-Year', year)
    % F = EmissionFactorDutch( ... '-SourceFile', filename)
    % F = EmissionFactorDutch( ... 'Motorway')
    %
    % Factors are read from spreadsheets downloaded from the Dutch
    % government. As of November 2015 the following links worked: 
    % http://tinyurl.com/EF-NonMotorway and http://tinyurl.com/EF-Motorway 
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   EmissionFactorDutch.m  $
    % $Revision:   1.0  $
    % $Author:   edward.barratt  $
    % $Date:   Nov 24 2016 09:19:14  $
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    FunctionCommand = 'EmissionFactorTools.ReadFromSource.Dutch';
    FunctionPath = fileparts(which(FunctionCommand));
    NonMotorwayPath = [FunctionPath, '\Data\DutchEF-NonMotorway.xlsx'];
    MotorwayPath = [FunctionPath, '\Data\DutchEF-Motorway.xlsx'];
    [year, ~] = datevec(now);
    
    [SFB, SFi] = ismember('-SourceFile', varargin);
    if SFB
        SourceFile = varargin{SFi+1};
        varargin(SFi+1) = [];
        varargin(SFi) = [];
    elseif ismember('Motorway', varargin)
        SourceFile = MotorwayPath;
        varargin(end) = [];
    else
        SourceFile = NonMotorwayPath;
    end
    [yB, yi] = ismember('-Year', varargin);
    if yB
        year = varargin{yi+1};
        if ~isequal(year, 'all')
            year_ = str2double(year);
            if isnan(year_)
                error('EmissionFactorsDutch:UnrecognizedYear', 'Year ''%s'' is not understood.', year)
            else
                year = year_;
            end
        end
        varargin(yi+1) = [];
        varargin(yi) = [];
    end
    
    % Read the source file.
    [~, ~, raw] = xlsread(SourceFile);
    
    if isequal(raw{1,1}, 'Emissiefactoren voor niet-snelwegen (SRM1)')
        MWay = 0;
    elseif isequal(raw{1,1}, 'Emissiefactoren voor snelwegen (SRM2)')
        %MWay = 1;
        error('Not ready yet')
    else
        error('Source file structure is not recognised.')
    end
    
    [NumRows, ~] = size(raw);
    
    if ~MWay
        VehiclesToSearch = {'LICHT WEGVERKEER', 'MIDDELZWAAR WEGVERKEER', ...
                            'ZWAAR WEGVERKEER', 'AUTOBUSSEN'};
        Vehicles = {'Light', 'Medium', 'Heavy', 'Bus'};
        PollutantsToSearch = {'NOx in NO2-equivalenten (g/km)', ...
                             'NO2 (g/km)', ...
                             'PM10 verbranding + slijtage naar lucht (g/km)', ...
                             'PM2.5 verbranding + slijtage naar lucht (g/km)', ...
                             'CO (g/km)', ...
                             'B(a)P verbranding (µg/km)', ...
                             'benzeen (mg/km) verbranding + verdamping', ...
                             'SO2 (mg/km)'};
        Pollutants = {'NOx', 'NO2', 'PM10', 'PM25', 'CO', 'BaP', 'Benzeen', 'SO2'};
        PScales = [0, 0, 0, 0, 0, -6, -3, -3]; % Scales to convert to g/km
        PYearExtra = [3, 3, 3, 3, 3, 4, 4, 4];
        SpeedClasses = {'Stagnated', 'Normal', 'Smooth', 'LargeRoad'};
        SpeedClassColNums = 1:4;

        
        % Find the column numbers for the different vehicle classes.
        VehColNums = nan(1, numel(Vehicles));
        for vi = 1:numel(Vehicles)
            index = find(strcmp(raw, VehiclesToSearch{vi}));
            VehColNums(vi) = floor(index/NumRows) + 1;
        end
        
        % Find the row numbers for the different pollutants.
        PolRowNums = nan(1, numel(Pollutants));
        for pi = 1:numel(Pollutants)
            index = find(strcmp(raw, PollutantsToSearch{pi}));
            PolRowNums(pi) = index(1);
        end

        % Find the available Years.
        Years = raw(PolRowNums(1)+1:PolRowNums(2)-1, 1);
        Years = [Years{:}];
        Years = Years(isfinite(Years));
        YearsRowNums = (1:numel(Years));
        if ~isequal(year, 'all')
            [yB, yi] = ismember(year, Years);
            if ~yB
                error('EmissionFactorsDutch:UnknownYear', 'Year ''%d'' is not known.', year)
            end
            Years = year;
            YearsRowNums = YearsRowNums(yi);
        end

        % See what factors have been requested.
        NumVars = numel(varargin);
        if NumVars > 0
            % Pollutant Specified.
            [Is, Pi] = ismember(varargin{1}, Pollutants);
            if ~Is
                error('EmissionFactorsDutch:UnknownPollutant', 'Pollutant ''%s'' is not known.', varargin{1})
            end
            Pollutants = Pollutants(Pi);
            PScales = PScales(Pi);
            PolRowNums = PolRowNums(Pi);
            PYearExtra = PYearExtra(Pi);
        end
        if NumVars > 1
            % Vehicle class specified.
            [Is, Pi] = ismember(varargin{2}, Vehicles);
            if ~Is
                error('EmissionFactorsDutch:UnknownVehicleClass', 'Vehicle Class ''%s'' is not known', varargin{2})
            end
            Vehicles = Vehicles(Pi);
            VehColNums = VehColNums(Pi);
        end
        if NumVars > 1
            % Vehicle class specified.
            [Is, Pi] = ismember(varargin{2}, Vehicles);
            if ~Is
                error('EmissionFactorsDutch:UnknownVehicleClass', 'Vehicle Class ''%s'' is not known', varargin{2})
            end
            Vehicles = varargin(2);
            VehColNums = VehColNums(Pi);
        end
        if NumVars > 2
            % speed class specified.
            [Is, Pi] = ismember(varargin{3}, SpeedClasses);
            if ~Is
                error('EmissionFactorsDutch:UnknownSpeedClass', 'Speed Class ''%s'' is not known', varargin{3})
            end
            SpeedClasses = varargin(3);
            SpeedClassColNums = SpeedClassColNums(Pi);
        end
        
        % Populate the structure.
        F = struct;
        for Yi = 1:numel(Years)
            Y = Years(Yi);
            YRow = YearsRowNums(Yi);
            F.(sprintf('Y_%d', Y)) = struct;
            for Pi = 1:numel(Pollutants)
                P = Pollutants{Pi};
                PRowStart = PolRowNums(Pi);
                PRowExtra = PYearExtra(Pi);
                PScale = PScales(Pi);
                F.(sprintf('Y_%d', Y)).(P) = struct;
                for Vi = 1:numel(Vehicles)
                    V = Vehicles{Vi};
                    VColStart = VehColNums(Vi);
                    F.(sprintf('Y_%d', Y)).(P).(V) = struct;
                    for Si = 1:numel(SpeedClasses)
                        S = SpeedClasses{Si};
                        SCol = SpeedClassColNums(Si);
                        Row = PRowStart + YRow + PRowExtra;
                        Col = VColStart + SCol;
                        %fprintf('%s %s %s %d: %dx%d = %f\n', P, V, S, Y, Row, Col, raw{Row, Col})
                        F.(sprintf('Y_%d', Y)).(P).(V).(S) = raw{Row, Col} * 10^PScale;
                    end
                end
            end
        end
    end
    
    
    % That's the structure produced, now simplify it.
    FFNs = fieldnames(F);
    while numel(FFNs) == 1
        F = F.(FFNs{1});
        try
            FFNs = fieldnames(F);
        catch E
            if ~isequal(E.identifier, 'MATLAB:UndefinedFunction')
                disp(E)
                rethrow(E)
            end
            break
        end
    end
    
 
end


