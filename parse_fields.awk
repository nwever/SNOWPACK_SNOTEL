#!/usr/bin/awk -f
function table(input) {
	# Translate SNOTEL variable names to typical MeteoIO variable names
	if(input=="Date") {return "DATE"};
	if(input=="Time") {return "TIME"};
	if(input=="PREC.I-1 (in) ") {return "PSUM"};
	if(input=="TOBS.I-1 (degC) ") {return "TA"};
	if(input=="SNWD.I-1 (in) ") {return "HS"};
	if(input=="SNWD.I-2 (in) ") {return "HS2"};
	if(input=="SMS.I-1:-2 (pct)  (silt)") {return "SOILMOISTURE1"};
	if(input=="SMS.I-1:-8 (pct)  (silt)") {return "SOILMOISTURE2"};
	if(input=="SMS.I-1:-20 (pct)  (silt)") {return "SOILMOISTURE3"};
	if(input=="STO.I-1:-2 (degC) ") {return "SOILTEMPERATURE1"};
	if(input=="STO.I-1:-8 (degC) ") {return "SOILTEMPERATURE2"};
	if(input=="STO.I-1:-20 (degC) ") {return "SOILTEMPERATURE3"};
	if(input=="BATT.I-1 (volt) ") {return "BATT"};
	if(input=="WDIRV.H-1 (degr) ") {return "DW"};
	if(input=="WSPDX.H-1 (mph) ") {return "VW_MAX"};
	if(input=="WSPDV.H-1 (mph) ") {return "VW"};
	if(input=="SRADV.H-1 (watt) ") {return "ISWR"};
	print "[WARNING] Unknown field:", input >> "/dev/stderr"
	return "SKIP"
}
{
	fields=""
	for(i=1; i<=NF; i++) {
		if(length(fields) == 0) {
			fields=table($i)
		} else {
			fields=sprintf("%s %s", fields, table($i))
		}
	}
}
END {
	print fields
}

