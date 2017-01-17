function [Factors, year] = EFT(varargin)
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
    % F = EmissionFactorTools.ReadFromSource.EFT( ... 'SourceFile', filename)
    % F = EmissionFactorTools.ReadFromSource.EFT( ... 'Option', Option)
    % EmissionFactorTools.ReadFromSource.EFT('ListOptions')
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
    NO2FracPath = [FunctionPath, '\Data\PrimaryNO2Fraction.xlsx'];
    NO2OverridesAll.BusesEuroVI.Bus = 0.08;
    NO2Overrides = [];
    
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
        if ismember(varargin{Opi+1}, fieldnames(NO2OverridesAll))
            NO2Overrides = NO2OverridesAll.(varargin{Opi+1});
        end
    else
        SourceFile = OptionPaths.Default;
        NO2Overrides = [];
    end
    
    % Read the NO2 Fractions.
    NO2Fracs = ReadNO2Fraction(NO2FracPath, NO2Overrides);
    [~, years, ~] = xlsfinfo(SourceFile);
    Factors = struct;
    for yi = 1:numel(years)
        ystr = years{yi};
        ystr_ = ['Y', ystr];
        % Read the source file.
        fprintf('Reading EFT sheet for %s.\n', ystr)
        SourceFile
        [~, ~, raw] = xlsread(SourceFile, ystr, 'A2:C218');
        if ~isnan(raw{end, end})
            error('EmissionFactorTools:ReadFromSource:EFT:FileToLong', 'There is data beyond the expected end of the file. Investigate ways to improve this fucntion.')
        end
        raw = raw(1:end-1, :);
    
        [NumRows, ~] = size(raw);
        FactorsY = struct;
        Pollutants = {};
        VehClasses = {};
        SpeedClasses = {};
        for rowi = 1:NumRows
            Name = raw{rowi, 1};
            Name = strsplit(Name, ' ');
            'aaa'
            SpeedClass = Name{1}
            VehClass = Name{2}
            Pollutant = raw{rowi, 2};
            Pollutant = strrep(Pollutant, '.', '')
            Factor = raw{rowi, 3}
            error('a')
        
            if ~ismember(Pollutant, Pollutants)
                Pollutants{end+1} = Pollutant; %#ok<AGROW>
            end
            if ~ismember(VehClass, VehClasses)
                VehClasses{end+1} = VehClass; %#ok<AGROW>
            end
            if ~ismember(SpeedClass, SpeedClasses)
                SpeedClasses{end+1} = SpeedClass; %#ok<AGROW>
            end
            FactorsY.(Pollutant).(VehClass).(SpeedClass) = Factor;
            if isequal(Pollutant , 'NOx')
                if ~ismember('NO2', Pollutants)
                    Pollutants{end+1} = 'NO2'; %#ok<AGROW>
                end
                NO2Frac = NO2Fracs.(ystr_).(VehClass);
                FactorsY.NO2.(VehClass).(SpeedClass) = Factor*NO2Frac;
            end
        end
        Factors.(ystr_) = FactorsY;
    end
end

function S = ReadNO2Fraction(filename, Overrides)
    fprintf('Reading NOx to primary NO2 conversion factors...\n')
    [~, ~, raw] = xlsread(filename, 'A5:AA11');
    Years = raw(1,2:end);
    Vehs = raw(2:end,1);
    S = struct;
    for yi = 1:numel(Years)
        y = Years{yi};
        ystr = sprintf('Y%04d', y);
        for vi = 1:numel(Vehs)
            vstr = strrep(Vehs{vi}, ' ', '');
            q = raw{vi+1, yi+1};
            if numel(Overrides)
                if ismember(vstr, fieldnames(Overrides))
                    q = Overrides.(vstr);
                end
            end
            S.(ystr).(vstr) = q;
        end
    end
end % function ReadNO2Fraction(filename)