#!/usr/bin/awk -f
function table(input) {
	# Translate SNOTEL variable names to typical MeteoIO variable names
	if(input=="timestamp_utc") {return "TIMESTAMP"};
	if(input=="rhp") {return "RH"};
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

