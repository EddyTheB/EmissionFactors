classdef EmissionFactorsClass < handle
    % EmissionFactorsClass
    % An emission factor class.
    %
    % PROPERTIES
    % Name           - string
    %                  A name for the emission factor scheme used in this
    %                  object.
    % Pollutants     - cell
    %                  The pollutants available in the specified scheme.
    % VehicleClasses - cell
    %                  The vehicle classes available in the specified
    %                  scheme.
    % SpeedClasses   - cell of strings
    %                  The speed classes available in the specified scheme.
    % StagnantSpeedClass - string
    %                  The specific speed class that should be used for
    %                  'stagnant' traffic.
    %                  Must be one of the available speed classes, or
    %                  'Ignore'.
    %                  default 'Ignore'.
    % Factors        - struct
    %                  A structure of the emission factors in the specified
    %                  scheme. The structure hierachy goes Pollutant -
    %                  VehicleClass - SpeedClass. So, for example, to get
    %                  the PM10 emissions for a Bus travelling in a speed
    %                  class 'Smooth', you would call
    %                  EmissionFactor.PM10.Bus.Smooth.
    % Units          - string
    %                  The units used for the emission factors.
    %                  Note. Changing this property has no effect.
    %                  default 'g/km/vehicle'
    % UnitConversion - numeric scaler
    %                  The factor that would be used to convert to
    %                  'g/km/vehicle'
    %                  Note. Changing this property has no effect.
    %                  default 1
    %
    % METHODS
    % EditFactor(Pollutant, VehicleClass, SpeedClass, Value)
    %                  Sets the emission factor of the specified pollutant,
    %                  vehicle and speed to the specified value.
    % Multiply(Number, OptionalArguments)
    %                  Multiply the specified factor(s) by the specified
    %                  value. See help EmissionFactorsClass.Multiply for details.
    % Add(Number, OptionalArguments)
    %                  Adds the specified value to the the specified
    %                  factor(s). See help EmissionFactorsClass.Add for details.
    % AddPollutant(PollutantName, OptionalArguments)
    %                  Add a new pollutant. The speed classes and vehicle
    %                  classes will be identical to preexisting pollutants.
    %                  See help EmissionFactorsClass.AddPollutant for details.
    % RemovePollutant(PollutantName)
    %                  Remove the specified pollutant. See help 
    %                  EmissionFactorsClass.RemovePollutant for details.
    % AddVehicleClass(VehicleClass, OptionalArguments)
    %                  Add a new vehicle class. The pollutants and speed
    %                  classes will be identical to those for existing
    %                  vehicle classes. See help
    %                  EmissionFactorsClass.AddVehicleClass for details.
    % RemoveVehicleClass(VehicleClass)
    %                  Remove the specified vehicle class. See help 
    %                  EmissionFactorsClass.RemoveVehicleClass for details.
    % AddSpeedClass(SpeedClass, OptionalArguments)
    %                  Add a new Speed class. The pollutants and vehicle
    %                  classes will be identical to those for existing
    %                  speed classes. See help
    %                  EmissionFactorsClass.AddSpeedClass for details.
    % RemoveSpeedClass(SpeedClass)
    %                  Remove the specified speed class. See help 
    %                  EmissionFactorsClass.RemoveSpeedClass for details.
    % ImportFactorStruct(Structure, OptionalArguments)
    %                  Create a EmissionFactorsClass object from a suitable
    %                  structure.
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   EmissionFactorsClass.m  $
    % $Revision:   1.1  $
    % $Author:   edward.barratt  $
    % $Date:   Nov 24 2016 09:18:04  $
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties 
        Units@char = 'g/km/vehicle'
        UnitConversion@double = 1
    end
    
    properties (Dependent)
        Name
        Pollutants
        VehicleClasses
        SpeedClasses
        StagnantSpeedClass
        Factors
    end % properties (Dependent)

    properties (Hidden)
        Protected = false
    end % properties
    
    properties (SetAccess=private, GetAccess=private)
        NameP@char
        PollutantsP@cell
        VehicleClassesP@cell
        SpeedClassesP@cell
        StagnantSpeedClassP@char
        FactorsP@struct
    end % properties (SetAccess=private, GetAccess=private)
    
    methods
        
        %% Getters and Setters
        function val = get.Name(obj)
            val = obj.NameP;
        end % function val = get.Name(obj)
        
        function set.Name(obj, val)
            if obj.Protected
                error('EmissionFactorsClass:SetName:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            else
                obj.NameP = val;
            end
        end % function set.Name(obj, val)
        
        function val = get.Pollutants(obj)
            val = obj.PollutantsP;
        end % function val = get.Pollutants(obj)
        
        function set.Pollutants(obj, val)
            if obj.Protected
                error('EmissionFactorsClass:SetPollutants:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            else
                obj.PollutantsP = val;
            end
        end % function set.Pollutants(obj, val)
        
        function val = get.VehicleClasses(obj)
            val = obj.VehicleClassesP;
        end % function val = get.VehicleClasses(obj)
        
        function set.VehicleClasses(obj, val)
            if obj.Protected
                error('EmissionFactorsClass:SetVehicleClasses:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            else
                obj.VehicleClassesP = val;
            end
        end % function set.VehicleClasses(obj, val)
        
        function val = get.SpeedClasses(obj)
            val = obj.SpeedClassesP;
        end % function val = get.SpeedClasses(obj)
        
        function set.SpeedClasses(obj, val)
            if obj.Protected
                error('EmissionFactorsClass:SetSpeedClasses:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            else
                obj.SpeedClassesP = val;
            end
        end % function set.SpeedClasses(obj, val)
        
        function val = get.Factors(obj)
            val = obj.FactorsP;
        end % function get.Factors(obj)
        
        function set.Factors(obj, val)
            % Could just import the structure directly. But this next step
            % will ensure that it is in the right format.
            if obj.Protected
                error('EmissionFactorsClass:SetFactors:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            else
                % Iterate through all the possibilities, to make sure that
                % the new structure is in the right format.
                for PI = 1:numel(obj.Pollutants)
                    P = obj.Pollutants{PI};
                    for VI = 1:numel(obj.VehicleClasses)
                        V = obj.VehicleClasses{VI};
                        for SI = 1:numel(obj.SpeedClasses)
                            S = obj.SpeedClasses{SI};
                            G.(P).(V).(S) = val.(P).(V).(S);
                        end
                    end
                end
                obj.FactorsP = G;
            end
        end % function set.Factors(obj)
        
        function val = get.StagnantSpeedClass(obj)
            val = obj.StagnantSpeedClassP;
        end % function val = get.StagnantSpeedClass(obj)
        
        function set.StagnantSpeedClass(obj, val)
            if ~isequal(val, 'Ignore')
                if ~ismember(val, obj.SpeedClasses)
                    error('EmissionFactor:SetStagnantSpeedClass:NotAvailable', 'StagnantSpeedClass cannot be set to ''%s'', that speed class does not exist. StagnantSpeedClass can be set to ''Ignore'', or one of the available speed classes.', val)
                end
            end
            obj.StagnantSpeedClassP = val;
        end
        
        %% Other functions
        function EditFactor(obj, Pollutant, VehicleClass, SpeedClass, Value)
            % Sets the emission factor of the specified pollutant, vehicle
            % and speed to the specified value.
            % USAGE
            % EmissionFactorsClass.EditFactor(obj, Pollutant, VehicleClass, SpeedClass, Value)
            if obj.Protected
                error('EmissionFactorsClass:EditFactor:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            obj.FactorsP.(Pollutant).(VehicleClass).(SpeedClass) = Value;
        end % function EditFactor(obj, Pollutant, VehicleClass, SpeedClass, Value)
        
        function Multiply(obj, Number, varargin)
            % Multiply the specified factor(s) by the specified value.
            % USAGE
            % Multiply(obj, Factor)
            %         - apply to all factors.
            % Multiply(obj, Factor, 'Pollutant', Pollutant)
            %         - apply to all factors for specified pollutant.
            % Multiply(obj, Factor, 'VehicleClass', VehicleClass)
            %         - apply to all factors for specified vehicle class.
            % Multiply(obj, Factor, 'SpeedClass', SpeedClass)
            %         - apply to all factors for specified speed class.
            % Multiply(obj, Factor, 'Pollutant', Pollutant, 'VehicleClass', VehicleClass, 'SpeedClass', SpeedClass)
            %         - apply to factor(s) meeting any specified conditions.
            if obj.Protected
                error('EmissionFactorsClass:Multiply:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            [PB, PI] = ismember('Pollutant', varargin);
            [VB, VI] = ismember('VehicleClass', varargin);
            [SB, SI] = ismember('SpeedClass', varargin);
            if PB
                Ps = varargin(PI+1);
            else
                Ps = obj.Pollutants;
            end
            if VB
                Vs = varargin(VI+1);
            else
                Vs = obj.VehicleClasses;
            end
            if SB
                Ss = varargin(SI+1);
            else
                Ss = obj.SpeedClasses;
            end
            for PI = 1:numel(Ps)
                P = Ps{PI};
                for VI = 1:numel(Vs)
                    V = Vs{VI};
                    for SI = 1:numel(Ss)
                        S = Ss{SI};
                        W = obj.Factors.(P).(V).(S) * Number;
                        if W < 0
                            obj.Factors.(P).(V).(S) = 0;
                        else
                            obj.Factors.(P).(V).(S) = W;
                        end
                    end
                end
            end
        end % function Multiply(obj, varargin, Factor)
        
        function Add(obj, Number, varargin)
            % Adds the specified value to the the specified factor(s).
            % USAGE
            % Add(obj, Factor)
            %         - apply to all factors.
            % Add(obj, Factor, 'Pollutant', Pollutant)
            %         - apply to all factors for specified pollutant.
            % Add(obj, Factor, 'VehicleClass', VehicleClass)
            %         - apply to all factors for specified vehicle class.
            % Add(obj, Factor, 'SpeedClass', SpeedClass)
            %         - apply to all factors for specified speed class.
            % Add(obj, Factor, 'Pollutant', Pollutant, 'VehicleClass', VehicleClass, 'SpeedClass', SpeedClass)
            %         - apply to factor(s) meeting any specified conditions.
            if obj.Protected
                error('EmissionFactorsClass:Add:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            [PB, PI] = ismember('Pollutant', varargin);
            [VB, VI] = ismember('VehicleClass', varargin);
            [SB, SI] = ismember('SpeedClass', varargin);
            if PB
                Ps = varargin(PI+1);
            else
                Ps = obj.Pollutants;
            end
            if VB
                Vs = varargin(VI+1);
            else
                Vs = obj.VehicleClasses;
            end
            if SB
                Ss = varargin(SI+1);
            else
                Ss = obj.SpeedClasses;
            end
            for PI = 1:numel(Ps)
                P = Ps{PI};
                for VI = 1:numel(Vs)
                    V = Vs{VI};
                    for SI = 1:numel(Ss)
                        S = Ss{SI};
                        W = obj.Factors.(P).(V).(S) + Number;
                        if W < 0
                            obj.Factors.(P).(V).(S) = 0;
                        else
                            obj.Factors.(P).(V).(S) = W;
                        end
                    end
                end
            end
        end % function Add(obj, varargin, Factor)
        
        function AddPollutant(obj, PollutantName, varargin)
            % Add a new pollutant. The speed classes and vehicle classes
            % will be identical to preexisting pollutants.
            %
            % USAGE
            % AddPollutant(PollutantName, OptionalArguments)
            %
            % OptionalArguments
            % Like     - string
            %          Another pollutant already within the emission factor
            %          object. Setting this will basically copy the factors
            %          for that pollutant. One of Like or Value should be
            %          specified.
            % Value    - numeric
            %          Will set all factors to that value. One of Like or Value should be
            %          specified.
            % Add      - Value to add to all emission factors, be they
            %          specified by 'Like' or 'Value'
            % Multiply - Value to multiply all emission factors by, be they
            %          specified by 'Like' or 'Value'
            if obj.Protected
                error('EmissionFactorsClass:AddPollutant:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            if ismember(PollutantName, obj.Pollutants)
                error('EmissionFactorsClass:AddPollutant:ExistingPollutant', 'Cannot add pollutant ''%s'', it already exists.', PollutantName)
            end
            Options.Like = -999;
            Options.Value = -999;
            Options.Add = 0;
            Options.Multiply = 1;
            Options = checkArguments(Options, varargin);
            
            if Options.Like ~= -999
                if Options.Value ~= -999
                    error('EmissionFactorsClass:AddPollutant:LikeAndValue', '''Like'' and ''Value'', are both specified. Only one should be.')
                end
                Like = obj.Factors.(Options.Like);
            else
                if Options.Value == -999
                    error('EmissionFactorsClass:AddPollutant:LikeNorValue', 'Neither ''Like'' nor ''Value'' have been specified. One should be.')
                end
                Like = obj.Factors.(obj.Pollutants{1});
            end
            
            obj.Pollutants{end+1} = PollutantName;
            FF = obj.Factors;
            FF.(PollutantName) = Like;
            obj.Factors = FF;
            
            if Options.Value ~= -999
                obj.Multiply(0, 'Pollutant', PollutantName)
                obj.Add(Options.Value, 'Pollutant', PollutantName)
            end
            
            obj.Multiply(Options.Multiply, 'Pollutant', PollutantName)
            obj.Add(Options.Add, 'Pollutant', PollutantName)
        end % function AddPollutant(obj, PollutantName, varargin)
        
        function RemovePollutant(obj, PollutantName)
            % RemovePollutant(PollutantName)
            % Remove the specified pollutant. Will fail if only one
            % pollutant exists.
            if obj.Protected
                error('EmissionFactorsClass:RemovePollutant:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            if ismember(PollutantName, obj.Pollutants);
                if numel(obj.Pollutants) > 1
                    obj.FactorsP = rmfield(obj.FactorsP, PollutantName);
                    obj.Pollutants = fieldnames(obj.Factors);
                else
                    error('EmissionFactorsClass:RemovePollutant:LastPollutant', 'Cannot remove only pollutant.')
                end
            end
        end % function RemovePollutant(obj, PollutantName)
        
        function AddVehicleClass(obj, VehicleClass, varargin)
            % AddVehicleClass(obj, VehicleClass, OptionalArguments)
            %     Add a new vehicle class. The pollutants and speed classes
            %     will be identical to those for existing vehicle classes. 
            %     See help EmissionFactorsClass.AddPollutant for usage.
            if obj.Protected
                error('EmissionFactorsClass:AddVehicle:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            if ismember(VehicleClass, obj.VehicleClasses)
                error('EmissionFactorsClass:AddVehicleClass:ExistingVehicleClass', 'Cannot add vehicle class ''%s'', it already exists.', VehicleClass)
            end
            Options.Like = -999;
            Options.Value = -999;
            Options.Add = 0;
            Options.Multiply = 1;
            Options = checkArguments(Options, varargin);
            
            if Options.Like ~= -999
                if Options.Value ~= -999
                    error('EmissionFactorsClass:AddVehicleClass:LikeAndValue', '''Like'' and ''Value'', are both specified. Only one should be.')
                end
                Like = Options.Like;
            else
                if Options.Value == -999
                    error('EmissionFactorsClass:AddVehicleClass:LikeNorValue', 'Neither ''Like'' nor ''Value'' have been specified. One should be.')
                end
                Like = obj.VehicleClasses{1};
            end
            
            obj.VehicleClasses{end+1} = VehicleClass;
            FF = obj.Factors;
            for Pi = 1:numel(obj.Pollutants)
                P = obj.Pollutants{Pi};
                FF.(P).(VehicleClass) = FF.(P).(Like);
            end
            obj.Factors = FF;
            
            if Options.Value ~= -999
                obj.Multiply(0, 'VehicleClass', VehicleClass)
                obj.Add(Options.Value, 'VehicleClass', VehicleClass)
            end
            
            obj.Multiply(Options.Multiply, 'VehicleClass', VehicleClass)
            obj.Add(Options.Add, 'VehicleClass', VehicleClass)
        end % function AddVehicleClass(obj, VehicleClass, varargin)
        
        function RemoveVehicleClass(obj, VehicleClass)
            % RemoveVehicleClass(obj, VehicleClass)
            %     Remove the specified vehicle class.
            %     See help EmissionFactorsClass.RemovePollutant for usage.
            if obj.Protected
                error('EmissionFactorsClass:RemoveVehicleClass:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            if ismember(VehicleClass, obj.VehicleClasses);
                for Pi = 1:numel(obj.Pollutants)
                    P = obj.Pollutants{Pi};
                    obj.FactorsP.(P) = rmfield(obj.FactorsP.(P), VehicleClass);
                end
                obj.VehicleClasses = fieldnames(obj.Factors.(P));
            end
        end % function RemoveVehicleClass(obj, VehicleClass)
        
        function AddSpeedClass(obj, SpeedClass, varargin)
            % AddSpeedClass(obj, SpeedClass, OptionalArguments)
            %     Add a new Speed class. The pollutants and vehicle classes
            %     will be identical to those for existing speed classes.
            %     See help EmissionFactorsClass.AddPollutant for usage.
            if ismember(SpeedClass, obj.SpeedClasses)
                error('EmissionFactorsClass:AddSpeedClass:ExistingSpeedClass', 'Cannot add speed class ''%s'', it already exists.', SpeedClass)
            end
            Options.Like = -999;
            Options.Value = -999;
            Options.Add = 0;
            Options.Multiply = 1;
            Options = checkArguments(Options, varargin);
            
            if Options.Like ~= -999
                if Options.Value ~= -999
                    error('EmissionFactorsClass:AddSpeedClass:LikeAndValue', '''Like'' and ''Value'' are both specified. Only one should be.')
                end
                Like = Options.Like;
            else
                if Options.Value == -999
                    error('EmissionFactorsClass:AddSpeedClass:LikeNorValue', 'Neither ''Like'' nor ''Value'' have been specified. One should be.')
                end
                Like = obj.SpeedClasses{1};
            end
            
            obj.SpeedClasses{end+1} = SpeedClass;
            FF = obj.Factors;
            for Pi = 1:numel(obj.Pollutants)
                P = obj.Pollutants{Pi};
                for Vi = 1:numel(obj.VehicleClasses)
                    V = obj.VehicleClasses{Vi};
                    FF.(P).(V).(SpeedClass) = FF.(P).(V).(Like);
                end
            end
            obj.Factors = FF;
            
            if Options.Value ~= -999
                obj.Multiply(0, 'SpeedClass', SpeedClass)
                obj.Add(Options.Value, 'SpeedClass', SpeedClass)
            end
            
            obj.Multiply(Options.Multiply, 'SpeedClass', SpeedClass)
            obj.Add(Options.Add, 'SpeedClass', SpeedClass)
        end % function AddSpeedClass(obj, SpeedClass, varargin)
        
        function RemoveSpeedClass(obj, SpeedClass)
            % RemoveSpeedClass(obj, SpeedClass)
            %     Remove the specified speed class. See help
            %     See help EmissionFactorsClass.RemovePollutant for usage.
            if obj.Protected
                error('EmissionFactorsClass:RemoveSpeedClass:Protected', 'Cannot edit emission factors ''%s'', they are protected.', obj.Name)
            end
            if ismember(SpeedClass, obj.SpeedClasses);
                for Pi = 1:numel(obj.Pollutants)
                    P = obj.Pollutants{Pi};
                    for Vi = 1:numel(obj.VehicleClasses)
                        V = obj.VehicleClasses{Vi};
                        obj.FactorsP.(P).(V) = rmfield(obj.FactorsP.(P).(V), SpeedClass);
                    end
                end
                obj.VehicleClasses = fieldnames(obj.Factors.(P));
            end
        end % function RemoveSpeedClass(obj, SpeedClass)
    end % methods
    
    methods (Static)
        function obj = ImportFactorStruct(S, varargin)
            % Create a EmissionFactorsClass object from a suitable structure.
            % 
            % USAGE
            % obj = ImportFactorStruct(S, OptionalArguments)
            %
            % INPUTS
            % S        - struct
            %          A structure of emission factors of the collect form,
            %          e.g. Pollutant - Vehicle Class - Speed Class -
            %          Value.
            %
            % OPTIONAL INPUTS
            % Name     - string
            %          A name for the emission factor class.
            % StagnantSpeedClass  - string
            %          Which speed class should be used for stagnant
            %          traffic.
            obj = EmissionFactorsClass;
            Options.Name = 'Unnamed';
            Options.StagnantSpeedClass = 'Auto';
            Options = checkArguments(Options, varargin);
            if isequal(Options.Name, 'Unnamed')
                Answers = inputdlg('Emission factors name:');
                if numel(Answers) == 0
                    return
                end
                Options.Name = Answers{1};
            end
            obj.Name = Options.Name;
            obj.Pollutants = fieldnames(S);
            obj.VehicleClasses = fieldnames(S.(obj.Pollutants{1}));
            obj.SpeedClasses = fieldnames(S.(obj.Pollutants{1}).(obj.VehicleClasses{1}));
            if isequal(Options.StagnantSpeedClass, 'Auto')
                Vs = ones(1, numel(obj.SpeedClasses)); 
                for SPi = 1:numel(obj.SpeedClasses)
                    SP = obj.SpeedClasses{SPi};
                    Vs(SPi) = S.(obj.Pollutants{1}).(obj.VehicleClasses{1}).(SP);
                end
                [~, MaxI] = max(Vs);
                obj.StagnantSpeedClass = obj.SpeedClasses{MaxI};
            else
                obj.StagnantSpeedClass = Options.StagnantSpeedClass;
            end
            obj.Factors = S;
        end % function ImportFactorStruct
    end % methods (static)
end % classdef EmissionFactorsClass < handle