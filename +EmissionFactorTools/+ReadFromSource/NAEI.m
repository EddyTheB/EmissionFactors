function [Factors, year] = NAEI(varargin)
    % Factors = EmissionFactorTools.ReadFromSource.NAEI
    %
    % Returns a structure containing the NAEI emission 
    % factors for PM10, PM2.5, NO2 and NOx.
    %
    % Default behaviour is to return the factors for the current year and
    % for the default euro class, but other options can be specified.
    %
    % Infact the default behaviour will fail, since we only have values for
    % 2012!
    %
    % USAGE
    % F = EmissionFactorTools.ReadFromSource.NAEI
    % F = EmissionFactorTools.ReadFromSource.NAEI( ... 'Year', year)
    % F = EmissionFactorTools.ReadFromSource.NAEI( ... 'SourceFile', filename)
    % F = EmissionFactorTools.ReadFromSource.NAEI( ... 'Option', Option)
    % EmissionFactorTools.ReadFromSource.NAEI('ListOptions')
    % EmissionFactorTools.ReadFromSource.NAEI( ... 'ListYears')
    %
    % Factors are read from spreadsheets populated with data extracted from
    % EMIT by Alan McDonald. View the default files to see the format that
    % is required.
    
    FunctionCommand = 'EmissionFactorTools.ReadFromSource.NAEI';
    FunctionPath = fileparts(which(FunctionCommand));
    
    OptionPaths = struct();
    OptionPaths.Default = [FunctionPath, '\Data\NAEI2012 Year 2012_Unit_11VC_2012.xlsx'];
    [year, ~] = datevec(now);
    
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
    
    if ismember('ListYears', varargin)
        [~, sheets, ~] = xlsfinfo(SourceFile);
        sdf = '';
        for shi = 1:numel(sheets)
            sdf = [sdf, ', ', sheets{shi}]; %#ok<AGROW>
        end
        sdf = sdf(3:end);
        fprintf('The following years are available:\n')
        fprintf('%s\n', sdf)
        Factors = 0;
        return
    end
    
    [yB, yi] = ismember('Year', varargin);
    if yB
        year = varargin{yi+1};
        if ~isequal(year, 'all')
            year_ = str2double(year);
            if isnan(year_)
                error('EmissionFactorTools:ReadFromSource:EFT:UnrecognizedYear', 'Year ''%s'' is not understood.', year)
            else
                year = year_;
            end
        end
        varargin(yi+1) = [];
        varargin(yi) = [];
    end
    
    % Read the source file.
    [~, ~, raw] = xlsread(SourceFile, sprintf('%04d', year), 'B6:E534');
    if ~isnan(raw{end, end})
        error('EmissionFactorTools:ReadFromSource:EFT:FileToLong', 'There is data beyond the expected end of the file. Investigate ways to improve this fucntion.')
    end
    raw = raw(1:end-1, :);
    
    [NumRows, ~] = size(raw);
    Factors = struct;
    Pollutants = {};
    VehClasses = {};
    SpeedClasses = {};
    for rowi = 1:NumRows
        VehClass = strtrim(raw{rowi, 1});
        Speed = str2double(raw{rowi, 2});
        SpeedClass = sprintf('S_%03d', Speed);
        Pollutant = strtrim(raw{rowi, 3});
        Pollutant = strrep(Pollutant, '.', '');
        Factor = raw{rowi, 4};
        
        if ~ismember(Pollutant, Pollutants)
            Pollutants{end+1} = Pollutant; %#ok<AGROW>
            %Factors.(Pollutant) = struct;
        end
        if ~ismember(VehClass, VehClasses)
            VehClasses{end+1} = VehClass; %#ok<AGROW>
            %Factors.(Pollutant).(VehClass) = struct;
        end
        if ~ismember(SpeedClass, SpeedClasses)
            SpeedClasses{end+1} = SpeedClass; %#ok<AGROW>
            %Factors.(Pollutant).(VehClass) = struct;
        end
        Factors.(Pollutant).(VehClass).(SpeedClass) = Factor;
    end
end