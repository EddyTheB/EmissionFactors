function [Factors, year] = NAEI2014(varargin)
    % Factors = EmissionFactorTools.ReadFromSource.NAEI2014
    %
    % Returns a structure containing the NAEI emission 
    % factors for PM10, PM2.5, NO2 and NOx.
    %
    % Default behaviour is to return the factors for the current year and
    % for the default euro class, but other options can be specified.
    %
    % USAGE
    % F = EmissionFactorTools.ReadFromSource.NAEI
    % F = EmissionFactorTools.ReadFromSource.NAEI( ... 'SourceFile', filename)
    % F = EmissionFactorTools.ReadFromSource.NAEI( ... 'Option', Option)
    % EmissionFactorTools.ReadFromSource.NAEI('ListOptions')
    %
    % Factors are read from spreadsheets populated with data extracted from
    % EMIT using the python EmissionDB tools that I wrote.
    
    FunctionCommand = 'EmissionFactorTools.ReadFromSource.NAEI2014';
    FunctionPath = fileparts(which(FunctionCommand));
    
    OptionPaths = struct();
    OptionPaths.Default = [FunctionPath, '\Data\NAEI2014UrbanDB_Standard.xlsx'];
    OptionPaths.BusesEuroVI = [FunctionPath, '\Data\NAEI2014UrbanDB_AllBusesEuro6.xlsx'];
    OptionPaths.NoDieselCars = [FunctionPath, '\Data\NAEI2014UrbanDB_NoDieselCars.xlsx'];
    OptionPaths.MarkBusesEuroV = [FunctionPath, '\Data\NAEI2014UrbanDB_MarksEuroVBuses.xlsx'];
    OptionPaths.MarkBusesEuroVI = [FunctionPath, '\Data\NAEI2014UrbanDB_MarksEuroVIBuses.xlsx'];
    
    
    if ismember('ListOptions', varargin)
        OFNs = fieldnames(OptionPaths);
        fprintf('Select one of the following options.\n')
        for OPi = 1:numel(OFNs)
            OFN = OFNs{OPi};
            fprintf('%15s: %s\n', OFN, OptionPaths.(OFN))
        end
        Factors = 0;
        return
    end
    
    vehChanges = struct();
    vehChanges.ahgv3o4x = 'AHGV_34X';
    vehChanges.ahgv5x = 'AHGV_5X';
    vehChanges.ahgv6px = 'AHGV_6X';
    vehChanges.bus = 'Bus';
    vehChanges.car = 'Car';
    vehChanges.lgv = 'LGV';
    vehChanges.motorcycle = 'MCycle';
    vehChanges.rhgv2x = 'RHGV_2X';
    vehChanges.rhgv3x = 'RHGV_3X';
    vehChanges.rhgv4px = 'RHGV_4X';
    vehChanges.taxi = 'TAXI';
    
    [SFB, SFi] = ismember('SourceFile', varargin);
    [OpB, Opi] = ismember('Option', varargin);
    if SFB
        SourceFile = varargin{SFi+1};
        varargin(SFi+1) = [];
        varargin(SFi) = [];
    elseif OpB
        SourceFile = OptionPaths.(varargin{Opi+1});
        varargin(Opi+1) = [];
        varargin(Opi) = [];
    else
        SourceFile = OptionPaths.Default;
    end
    fprintf('Reading file %s.\n', SourceFile)
    [~, years, ~] = xlsfinfo(SourceFile);
    Factors = struct;
    for yi = 1:numel(years)
        ystr = years{yi};
        ystr_ = ['Y', ystr];
        % Read the source file.
        fprintf('Reading NAEI2014 sheet for %s.\n', ystr)
        [~, ~, raw] = xlsread(SourceFile, ystr, 'A11:D715');
        if ~isnan(raw{end, end})
            error('EmissionFactorTools:ReadFromSource:EFT:FileToLong', 'There is data beyond the expected end of the file. Investigate ways to improve this fucntion.')
        end
        raw = raw(1:end-1, :);
    
        [NumRows, ~] = size(raw);
        FactorsY = struct;
        Pollutants = {};
        VehClasses = {}; %fieldnames(vehChanges);
        SpeedClasses = {};
        for rowi = 1:NumRows
            if isnan(raw{rowi, 1})
                break
            end
            VehClass = strtrim(raw{rowi, 1});
            VehClass = vehChanges.(VehClass);
            Speed = raw{rowi, 2};
            SpeedClass = sprintf('S%d', Speed);
            Pollutant = strtrim(raw{rowi, 3});
            Pollutant = strrep(Pollutant, '.', '');
            Factor = raw{rowi, 4};
            
            if ~ismember(Pollutant, Pollutants)
                Pollutants{end+1} = Pollutant; %#ok<AGROW>
            end
            if ~ismember(VehClass, VehClasses)
                VehClasses{end+1} = VehClass; %#ok<AGROW>
            end
            if ~ismember(SpeedClass, SpeedClasses)
                SpeedClasses{end+1} = SpeedClass; %#ok<AGROW>
            end
            FactorsY.(Pollutant).(VehClass).(SpeedClass) = Factor/(60*60);
        end
        Factors.(ystr_) = FactorsY;
    end
