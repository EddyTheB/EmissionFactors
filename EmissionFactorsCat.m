classdef EmissionFactorsCat < handle
    % EmissionFactorsCat
    % An emission factor catalogue class. A way of storing multiple
    % EmissionFactors objects.
    %
    % PROPERTIES
    % FactorName          - string
    %                       The currently selected emission factor set.
    % FactorNames         - cell
    %                       A cell array of all of the available factors.
    % FactorCatalogue     - struct
    %                       A structure containing all of the available
    %                       factors. The fieldnames will be the available
    %                       factor names, and the values will be
    %                       EMissionFactorTools.EmissionFactorsClass objects.
    % FactorApportionment - struct
    %                       A structure that details how the vehicle
    %                       classes for each available factor set are
    %                       mapped to the NAEI vehicle classes. For example
    %                       the Factor Apportionment for the Ducth emission
    %                       factors might look like:
    %                       >> E.FactorApportionment.Dutch
    %                       ans = 
    %                            Light: {'Car'  'LGV'}
    %                           Medium: {'RHGV_2X'}
    %                            Heavy: {'RHGV_3X'  'RHGV_4X'  'AHGV_34X'  'AHGV_5X'  'AHGV_6X'}
    %                              Bus: {'Bus'}
    % ApportionedFactorCatalogue
    %                     - struct
    %                     A repeat of FactorCatalogue, except that the
    %                     original vehicle classes for each factor set will
    %                     have been replaced with the NAEI vehicle classes.
    % SourceFile          - string
    %                     The location where the emission factor catalogue
    %                     will be saved if the save method is used. Default
    %                     is an empty string.
    %
    % METHODS
    % Factor(OptionalArguments)
    %           Returns the factors for the currently selected emission
    %           factor set. See help EmissionFactorsCat.Factor for details.
    % save()    Saves any changes to the catalogue to the current
    %           SourceFile. If SourceFile is empty, then calls saveas().
    % saveas()  Raises a put file dialogue to invite the user to choose a
    %           new SourceFile. Saves the file at that location.
    % open()    Raises a get file dialogue to invite the user choose a file
    %           containing an EmissionFactorsCat object. 
    %
    % FUTURE WORK
    % Requires a method for adding or removing EMissionFactorTools.EmissionFactorsClass objects.
    % Could be useful to add a "year" attribute to emission factor objects.
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   EmissionFactorsCat.m  $
    % $Revision:   1.0  $
    % $Author:   edward.barratt  $
    % $Date:   Nov 24 2016 09:19:18  $
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        FactorCatalogue
        SourceFile@char
    end % properties
    
    properties (Dependent)
        FactorNames
        FactorName
        FactorApportionment
        ApportionedFactorCatalogue
    end % properties (Dependent)
    
    properties (GetAccess = private, SetAccess = private)
        FactorNameP
        FactorApportionmentP = {}
    end % properties (GetAccess = private, SetAccess = private)
    
    methods
        %% Constructor
        function obj = EmissionFactorsCat(varargin)
            if nargin == 0
                [DutchStruct, Dyear] = EmissionFactorTools.ReadFromSource.Dutch;
                Catalogue.Dutch = EmissionFactorTools.EmissionFactorsClass.ImportFactorStruct(DutchStruct, 'Name', 'Dutch', 'StagnantSpeedClass', 'Stagnated', 'Year', Dyear);    
                Catalogue.Dutch.Protected = true;
                [EFTStruct, Eyear] = EmissionFactorTools.ReadFromSource.EFT('Option', 'Default');
                Catalogue.EFT_Default = EmissionFactorTools.EmissionFactorsClass.ImportFactorStruct(EFTStruct, 'Name', 'EFT_Default', 'StagnantSpeedClass', 'Ignore', 'Year', Eyear);    
                Catalogue.EFT_Default.Protected = true;
                [EFTStruct, Eyear] = EmissionFactorTools.ReadFromSource.EFT('Option', 'BusesEuroVI');
                Catalogue.EFT_BusesEuroVI = EmissionFactorTools.EmissionFactorsClass.ImportFactorStruct(EFTStruct, 'Name', 'EFT_BusesEuroVI', 'StagnantSpeedClass', 'Ignore', 'Year', Eyear);    
                Catalogue.EFT_BusesEuroVI.Protected = true;
                [NAEIStruct, Nyear] = EmissionFactorTools.ReadFromSource.EFT('Option', 'Default', 'Year', '2012');
                Catalogue.NAEI_Default2012 = EmissionFactorTools.EmissionFactorsClass.ImportFactorStruct(NAEIStruct, 'Name', 'NAEI_Default2012', 'StagnantSpeedClass', 'Ignore', 'Year', Nyear);
                Catalogue.NAEI_Default2012.Protected = true;

                %Catalogue.EFT_Default = EmissionFactorTools.EmissionFactorsClass.ImportFactorStruct(EmissionFactorTools.ReadFromSource.EFT('year', 2016), 'Name', 'Dutch', 'StagnantSpeedClass', 'Stagnated');
                obj.FactorCatalogue = Catalogue;
                obj.FactorNameP = obj.FactorNames{1};
                obj.FactorApportionment = obj.DefaultFactorApportionment();
            elseif nargin == 1
                In = varargin{1};
                switch class(In)
                    case 'EmissionFactorsCat'
                        obj = In;
                    case 'char'
                        obj = EmissionFactorsCat.open(In);
                    otherwise
                        %C = load(obj.SourceFile, 'EmissionFactorsCat');
                        %C %#ok<NOPRT>
                        warning('What to do? 1')
                end
            else
                warning('What to do? 2')
            end
        end % function obj = EmissionFactorsCat(varargin)
        
        %% Getters
        function val = get.FactorNames(obj)
            val = fieldnames(obj.FactorCatalogue);
        end % function val = get.FactorNames(obj)
        
        function val = get.FactorName(obj)
            val = obj.FactorNameP;
        end % function val = get.FactorNameP(obj)
        
        function set.FactorName(obj, val)
            if ismember(val, obj.FactorNames)
                obj.FactorNameP = val;
            else
                error('EmissionFactorsCat:WrongName', '''%s'' is not the name of a set of emission factors in tis collection.', val)
            end 
        end % function set.FactorName(obj, val)
        
        function val = get.FactorApportionment(obj)
            val = obj.FactorApportionmentP;
        end % function val = get.FactorApportionment(obj)
        
        function set.FactorApportionment(obj, val)
            fff = fieldnames(val);
            for fi = 1:numel(fff)
                ff = fff{fi};
                if ~ismember(ff, obj.FactorNames)
                    error('EmissionFactorCat:SetFactorApportionment:WrongName', 'Cannot set factor apportionment for emission factor structure ''%s'', as it does not exist.', ff)
                end
            end
            obj.FactorApportionmentP = val;
        end % function set.FactorApportionment(obj, val)
        
        function val = get.ApportionedFactorCatalogue(obj)
            if ~numel(obj.FactorApportionment)
                AFC = obj.FactorCatalogue;
            else
                AFC = obj.FactorCatalogue;
                FactorApportionmentNames = fieldnames(obj.FactorApportionment);
                for FNi = 1:numel(obj.FactorNames)
                    FN = obj.FactorNames{FNi};
                    if ismember(FN, FactorApportionmentNames)
                        FC_ = struct;
                        for Pi = 1:numel(obj.FactorCatalogue.(FN).Pollutants)
                            PP = obj.FactorCatalogue.(FN).Pollutants{Pi};
                            FC_.(PP) = struct;
                            for Vi = 1:numel(obj.FactorCatalogue.(FN).VehicleClasses)
                                VV = obj.FactorCatalogue.(FN).VehicleClasses{Vi};
                                if ismember(VV, fieldnames(obj.FactorApportionment.(FN)))
                                    for Wi = 1:numel(obj.FactorApportionment.(FN).(VV))
                                        WW = obj.FactorApportionment.(FN).(VV){Wi};
                                        FC_.(PP).(WW) = obj.FactorCatalogue.(FN).Factors.(PP).(VV);
                                    end
                                end
                            end
                        end
                        AFC.(FN) = EmissionFactors.ImportFactorStruct(FC_, ...
                            'Name', sprintf('%s-Apportioned', FN), ...
                            'StagnantSpeedClass', obj.FactorCatalogue.(FN).StagnantSpeedClass);
                    end 
                end
            end
            val = AFC;
        end % function val = get.ApportionedFactorCatalogue(obj)
        
        %% Other Functions
        function val = Factor(obj, varargin)
            Nar = numel(varargin);
            try
                if Nar == 0
                    val = obj.FactorCatalogue.(obj.FactorName);
                elseif Nar == 1
                    val = obj.FactorCatalogue.(obj.FactorName).(varargin{1});
                elseif Nar == 2
                    val = obj.FactorCatalogue.(obj.FactorName).(varargin{1}).(varargin{2});
                elseif Nar == 3
                    val = obj.FactorCatalogue.(obj.FactorName).(varargin{1}).(varargin{2}).(varargin{3});
                elseif Nar == 4
                    val = obj.FactorCatalogue.(varargin{1}).(varargin{2}).(varargin{3}).(varargin{4});
                end
            catch Err
                if ~isequal(Err.identifier, 'MATLAB:nonExistentField')
                    disp(Err)
                    rethrow(Err)
                else
                    error('What Error')
                end
            end
        end % function Factor(varargin)
                
        function save(obj)
            if ~numel(obj.SourceFile)
                obj.saveas
            else
                EmissionFactorsCat = obj; %#ok<NASGU> Because it is used.
                save(obj.SourceFile, 'EmissionFactorsCat', '-mat')
            end
            %
        end % function save(obj)
        
        function saveas(obj)
            if ~numel(obj.SourceFile)
                Dir = fileparts(which('EmissionFactorsCat'));
                Name = 'UnnamedEmissionFactorCatalogue';
                Ext = '.efc';
                Path = GenerateFileName('Dir', Dir, 'Name', Name, 'Ext', Ext);
            else
                Path = GenerateFileName(obj.SourceFile);
            end
            [FF, PP] = uiputfile(Path, 'Save emission factor catalogue as...');
            if FF == 0
                return
            end
            Path = [PP, FF];
            obj.SourceFile = Path;
            obj.save
        end % function saveas(obj)
        
        function EFA = DefaultFactorApportionment(obj)
            EFA_ = struct;
            EFA_.Dutch = struct;
            EFA_.Dutch.Light = {'Car', 'LGV'};
            EFA_.Dutch.Medium = {'RHGV_2X'};
            EFA_.Dutch.Heavy = {'RHGV_3X', 'RHGV_4X', 'AHGV_34X', 'AHGV_5X', 'AHGV_6X'};
            EFA_.Dutch.Bus = {'Bus'};
            EFA_.NAEI = struct;
            EFA_.NAEI.MCycle = {'MCycle'};
            EFA_.NAEI.Car = {'Car'};
            EFA_.NAEI.LGV = {'LGV'};
            EFA_.NAEI.RHGV_2X = {'RHGV_2X'};
            EFA_.NAEI.RHGV_3X = {'RHGV_3X'};
            EFA_.NAEI.RHGV_4X = {'RHGV_4X'};
            EFA_.NAEI.AHGV_34X = {'AHGV_34X'};
            EFA_.NAEI.AHGV_5X = {'AHGV_5X'};
            EFA_.NAEI.AHGV_6X = {'AHGV_6X'};
            EFA_.NAEI.Bus = {'Bus'};
            EFA_.EFT = struct;
            EFA_.EFT.MCycle = {'MCycle'};
            EFA_.EFT.Car = {'Car'};
            EFA_.EFT.LGV = {'LGV'};
            EFA_.EFT.RHGV = {'RHGV_2X', 'RHGV_3X', 'RHGV_4X'};
            EFA_.EFT.AHGV = {'AHGV_34X', 'AHGV_5X', 'AHGV_6X'};
            EFA_.EFT.Bus = {'Bus'};
            
            EFA = struct;
            FNs = obj.FactorNames;
            for FNi = 1:numel(FNs)
                FN = FNs{FNi};
                if numel(strfind(FN, 'Dutch'))
                    EFA.(FN) = EFA_.Dutch;
                elseif numel(strfind(FN, 'NAEI'))
                    EFA.(FN) = EFA_.NAEI;
                elseif numel(strfind(FN, 'EFT'))
                    EFA.(FN) = EFA_.EFT;
                else
                    error('EmissionFactorsCat:DefaultFactorApportionment:NoIdea', 'Emission factor type isn''t recognised')
                    % Got to be a more sensible way of doing this. Probably
                    % by judging each emission factor class by the vehicle
                    % classes.
                end
            end
        end % function EFA = DefaultFactorApportionment()

        
    end % methods
    methods (Static)
        function obj = open(FileName)
            A = load(FileName, '-mat');
            obj = A.EmissionFactorsCat;
        end % function obj = open(FileName)
        
%         function EFA = DefaultFactorApportionment(obj)
%             obj
%             EFA = struct;
%             EFA.Dutch = struct;
%             EFA.Dutch.Light = {'Car', 'LGV'};
%             EFA.Dutch.Medium = {'RHGV_2X'};
%             EFA.Dutch.Heavy = {'RHGV_3X', 'RHGV_4X', 'AHGV_34X', 'AHGV_5X', 'AHGV_6X'};
%             EFA.Dutch.Bus = {'Bus'};
%             EFA.NAEI = struct;
%             EFA.NAEI.MCycle = {'MCycle'};
%             EFA.NAEI.Car = {'Car'};
%             EFA.NAEI.LGV = {'LGV'};
%             EFA.NAEI.RHGV_2X = {'RHGV_2X'};
%             EFA.NAEI.RHGV_3X = {'RHGV_3X'};
%             EFA.NAEI.RHGV_4X = {'RHGV_4X'};
%             EFA.NAEI.AHGV_34X = {'AHGV_34X'};
%             EFA.NAEI.AHGV_5X = {'AHGV_5X'};
%             EFA.NAEI.AHGV_6X = {'AHGV_6X'};
%             EFA.NAEI.Bus = {'Bus'};
%         end % function EFA = DefaultFactorApportionment()
    end % methods (Static)
end