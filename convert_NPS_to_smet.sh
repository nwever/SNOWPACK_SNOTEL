source settings.rc

SiteSettings () {

	case $1 in

	CHMA2)
		siteid=CHMA2
		sitename="Chimney Lake"
		lat=67.7142
		lon=-150.585
		alt=1125
		;;

	*)
		echo "ERROR: site ${site} not found in settings!"
		;;

	esac
}


for site in ${NPSsites}
do
	SiteSettings ${site}
	echo "IMPORT_BEFORE = ./io_NPS_base.ini" > io.ini
	echo "[Output]" >> io.ini
	echo "METEOPATH = ./" >> io.ini
	echo "[Input]" >> io.ini

	echo "STATION1	= ${site}.csv" >> io.ini
	echo "POSITION1	= latlon ${lat} ${lon} ${alt}" >> io.ini
	echo "CSV1_NAME	= ${sitename}" >> io.ini
	echo "CSV1_ID	= ${siteid}" >> io.ini
	echo "CSV1_FIELDS = " $(fgrep "station_id" ${site}.csv | awk -F, -f parse_NPS_fields.awk) >> io.ini

	${pathtometeoiotimeseries}/meteoio_timeseries -c io.ini -b ${start_year}-10-01T00:00 -e ${end_year}-10-01T00:00

	rm io.ini
done
