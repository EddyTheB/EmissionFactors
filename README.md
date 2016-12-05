# EmissionFactors
A set of MATLAB code for organising traffic emission factors.


## Data
Governments love excel.

### Dutch emission factors
Dutch emission factors are taken from published excel spreadsheets downloaded from the Dutch government at http://tinyurl.com/EF-NonMotorway and http://tinyurl.com/EF-Motorway for the non-motorway and mororway traffic respectively. They are updated anually and should therefore be periodically updated. The current set were downloaded on the 30th November 2016.

### Emission Factor Toolkit
The Emission Factor Toolkit (EFT) is an excel spreadsheet published by DEFRA. The latest version is available at http://laqm.defra.gov.uk/review-and-assessment/tools/emissions-factors-toolkit.html. Unfortunately, rather than just allowing access to the underlying data, the toolkit insists that users input road information for their specific situation and then calls a macro to retrieve the data. In order to get the data into a useable form the toolkit has been run for NOx, PM10 and PM2.5, for Scotland, for Emission rates, for every year available, and the results placed in a new excel spreadsheet, which is the EFT2016_v7.0_ScotlandResults.xlsx file. This was done using version 7.0 of the toolkit downloaded on the 1st December 2016.

#### Default
The default EFT spreadsheet was produced using the EFT's default euro class breakdown.

#### All Buses Euro VI
The AllBusesEuroVI EFT spreadsheet was produced by adjusting the euro class breakdown so that all buses and coaches are Euro VI class.

