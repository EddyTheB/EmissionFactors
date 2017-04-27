function WriteEmissionFactors(Factors)
%WRITEEMISSIONFACTORS Summary of this function goes here
%   Detailed explanation goes here

    FileName = 'BlhBlh.csv';
    F = fopen(FileName, 'w');
    try
        fprintf(F, 'Name,%s\r\n', Factors.Name);
        fprintf(F, 'Units,%s\r\n', Factors.Units);
        fprintf(F, 'Stagnant Speed Class,%s\r\n', Factors.StagnantSpeedClass);
        fprintf(F, 'Year,Pollutant,Vehicle,%s(kmph)\r\n', strrep(strjoin(Factors.SpeedClasses', ' (kmph),'), 'S', ''));
        NumYs = numel(Factors.Years);
        NumPs = numel(Factors.Pollutants);
        NumVs = numel(Factors.VehicleClasses);
        NumSs = numel(Factors.SpeedClasses);
        for Yi = 1:NumYs
            Y = Factors.Years{Yi};
            Yv = Factors.YearVs(Yi);
            for Pi = 1:NumPs
                P = Factors.Pollutants{Pi};
                for Vi = 1:NumVs
                    V = Factors.VehicleClasses{Vi};
                    fprintf(F, '%04d,%s,%s', Yv, P, V);
                    for Si = 1:NumSs
                        S = Factors.SpeedClasses{Si};
                        Val = Factors.Factors.(Y).(P).(V).(S);
                        fprintf(F, ',%.6e', Val);
                    end
                    fprintf(F, '\r\n');
                end
            end
        end
        fclose(F);
    catch err
        fclose(F);
        disp(err)
        rethrow(err)        
    end
end

