function Factors = EFT(varargin)
    % Factors = EmissionFactorTools.ReadFromSource.EFT
    %
    % Returns a dictionary containing the Emission Factor Toolkit emission 
    % factors for PM10, PM2.5 and NOx.
    %
    % Default behaviour is to return the factors for the current year and
    % for the default euro class, but other options can be specified.
    %
    % USAGE
    % F = EmissionFactorTools.ReadFromSource.EFT
    % F = EmissionFactorTools.ReadFromSource.EFT( ... 'Year', year)
    % F = EmissionFactorTools.ReadFromSource.EFT( ... 'SourceFile', filename)
    % F = EmissionFactorTools.ReadFromSource.EFT( ... 'Option', Option)
    % EmissionFactorTools.ReadFromSource.EFT('ListOptions')
    % EmissionFactorTools.ReadFromSource.EFT( ... 'ListYears')
    %
    % Factors are read from spreadsheets prepered using the Emission Factor
    % Toolkit. View the default files to see the format that is required.
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   EmissionFactorTools.ReadFromSource.EFT.m  $
    % $Revision:   1.0  $
    % $Author:   edward.barratt  $
    % $Date:   Nov 24 2016 09:19:14  $
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    FunctionCommand = 'EmissionFactorTools.ReadFromSource.EFT';
    FunctionPath = fileparts(which(FunctionCommand));
    
    OptionPaths = struct();
    OptionPaths.Default = [FunctionPath, '\Data\EFT2016_v7.0_ScotlandResults_DefaultEuroClasses.xlsx'];
    OptionPaths.BusesEuroVI = [FunctionPath, '\Data\EFT2016_v7.0_ScotlandResults_AllBusesEuroVI.xlsx'];
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
        fprintf('The following years are available:\n')
        [~, sheets, ~] = xlsfinfo(SourceFile);
        sdf = '';
        for shi = 1:numel(sheets)
            sdf = [sdf, ', ', sheets{shi}]; %#ok<AGROW>
        end
        sdf = sdf(3:end);
        fprintf('%s\n', sdf)
        Factors = 0;
        return
    end
    
    [yB, yi] = ismember('-Year', varargin);
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
    [~, ~, raw] = xlsread(SourceFile, sprintf('%04d', year), 'A2:C218');
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
        Name = raw{rowi, 1};
        Name = strsplit(Name, ' ');
        SpeedClass = Name{1};
        VehClass = Name{2};
        Pollutant = raw{rowi, 2};
        Pollutant = strrep(Pollutant, '.', '');
        Factor = raw{rowi, 3};
        
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


