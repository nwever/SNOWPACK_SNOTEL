source ../settings.rc

# First, collect files

# Create required directories
mkdir -p ./input/
mkdir -p ./output/
mkdir -p ./log/

# Copy required smet files
cp ../CHMA2.smet ./input/
cp ../957/957.smet ./input/
cp ../957/957_filt_cutoff.smet ./input/

# Create *sno file
function WriteSnoFile {
	echo "SMET 1.1 ASCII" > ${snofile}
	echo "[HEADER]" >> ${snofile}
	echo "station_id = ${stnid}" >> ${snofile}
	echo "station_name = ${stnname}" >> ${snofile}
	echo "latitude     = ${latitude}" >> ${snofile}
	echo "longitude    = ${longitude}" >> ${snofile}
	echo "altitude = ${altitude}" >> ${snofile}
	echo "nodata = -999" >> ${snofile}
	echo "tz = 0" >> ${snofile}
	echo "ProfileDate = ${profiledate}" >> ${snofile}
	echo "HS_Last = 0.0" >> ${snofile}
	echo "SlopeAngle = ${SlopeAngle}" >> ${snofile}
	echo "SlopeAzi = ${SlopeAzi}" >> ${snofile}
	echo "nSoilLayerData = 6" >> ${snofile}
	echo "nSnowLayerData = 0" >> ${snofile}
	echo "SoilAlbedo = 0.2" >> ${snofile}
	echo "BareSoil_z0 = 0.02" >> ${snofile}
	echo "CanopyHeight = 0" >> ${snofile}
	echo "CanopyLeafAreaIndex = 0" >> ${snofile}
	echo "CanopyDirectThroughfall = 1" >> ${snofile}
	echo "WindScalingFactor = 0" >> ${snofile}
	echo "ErosionLevel = 0" >> ${snofile}
	echo "TimeCountDeltaHS = 0" >> ${snofile}
	echo "fields = timestamp Layer_Thick T Vol_Frac_I Vol_Frac_W Vol_Frac_V Vol_Frac_S Rho_S Conduc_S HeatCapac_S rg rb dd sp mk mass_hoar ne CDot metamo" >> ${snofile}
	echo "[DATA]" >> ${snofile}
	echo "1980-10-01T01:00 1.0 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 4 0 0" >> ${snofile}
	echo "1980-10-01T01:00 1.0 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 5 0 0" >> ${snofile}
	echo "1980-10-01T01:00 0.6 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 4 0 0" >> ${snofile}
	echo "1980-10-01T01:00 0.3 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 3 0 0" >> ${snofile}
	echo "1980-10-01T01:00 0.1 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 2 0 0" >> ${snofile}
	echo "1980-10-01T01:00 0.1 281.15 0 0.25 0.125 0.625 2700 2.5 871 7.5 0 0 0 0 0 5 0 0" >> ${snofile}
}

# Create ini file
function WriteIniFile {
	echo "IMPORT_BEFORE		= ./io_base.ini" > ${inifile}
	echo "[INPUT]" >> ${inifile}
	echo "STATION1			= ${stn}" >> ${inifile}
	echo "STATION2			= ${stn2}" >> ${inifile}
	echo "[InputEditing]" >> ${inifile}
	echo "CHMA2::edit1		= KEEP" >> ${inifile}
	echo "CHMA2::arg1::params = RH" >> ${inifile}
	echo "957::edit1		= EXCLUDE" >> ${inifile}
	echo "957::arg1::params = PSUM" >> ${inifile}
	echo "957::edit2		= MERGE" >> ${inifile}
	echo "957::arg2::merge	= CHMA2" >> ${inifile}
	echo "957::arg2::merge_strategy = FULL_MERGE" >> ${inifile}
	echo "[FILTERS]" >> ${inifile}
	echo "HS::filter10		= MAX" >> ${inifile}
	echo "HS::arg10::soft	= FALSE" >> ${inifile}
	echo "HS::arg10::max	= 1.3" >> ${inifile}
}

stn=957
stn2=CHMA2
echo Running SNOWPACK for: ${stn}
stnid=${stn}
smetfile="../${stn}/${stn}.smet"
inifile="./io_${stn}.ini"
logfile="./log/${stn}.log"
> ${logfile}

stnname=$(grep -m1 station_name ${smetfile} | awk -F= '{print $NF}')
latitude=$(grep -m1 latitude ${smetfile} | awk -F= '{print $NF}')
longitude=$(grep -m1 longitude ${smetfile} | awk -F= '{print $NF}')
altitude=$(grep -m1 altitude ${smetfile} | awk -F= '{print $NF}')
profiledate=$(awk '{if(/\[DATA\]/) {getline; print $1; exit}}' ${smetfile})

# Flat field
SlopeAngle=0
SlopeAzi=0
snofile="./input/${stn}.sno"
WriteSnoFile
# Virtual slopes
SlopeAngle=38
for vs in $(seq 1 4)
do
	SlopeAzi=$(echo "(${vs}-1)*90" | bc)
	snofile="./input/${stn}${vs}.sno"
	WriteSnoFile
done
WriteIniFile

# Generate processed meteo
${pathtometeoiotimeseries}/meteoio_timeseries -c io_${stn}.ini -b ${start_year}-10-01T00:00 -e ${end_year}-10-01T00:00
${pathtometeoiotimeseries}/meteoio_timeseries -c io_${stn}_filt_cutoff.ini -b ${start_year}-10-01T00:00 -e ${end_year}-10-01T00:00
mv ./output/957.smet ./output/957_forcing.smet
mv ./output/957.smet ./output/957_filt_cutoff_forcing.smet

# Run SNOWPACK year-by-year
for yr_s in $(seq ${start_year} ${end_year})
do
	let yr_e=${yr_s}+1
	echo "Running: ${pathtosnowpack}snowpack -s ${stn} -c io_${stn}.ini -b ${yr_s}-10-01T00:00 -e ${yr_e}-10-01T00:00" >> ${logfile}
	${pathtosnowpack}snowpack -s ${stn} -c io_${stn}.ini -b ${yr_s}-10-01T00:00 -e ${yr_e}-10-01T00:00
	echo "Running: ${pathtosnowpack}snowpack -s ${stn} -c io_${stn}_filt_cutoff.ini -b ${yr_s}-10-01T00:00 -e ${yr_e}-10-01T00:00" >> ${logfile}
	${pathtosnowpack}snowpack -s ${stn} -c io_${stn}_filt_cutoff.ini -b ${yr_s}-10-01T00:00 -e ${yr_e}-10-01T00:00 >> ${logfile}
done