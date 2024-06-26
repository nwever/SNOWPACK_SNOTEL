source settings.rc

SiteSettings () {

	case $1 in

	957)
		siteid=957
		sitename="Atigun Pass"
		lat=68.1298
		lon=-149.4782
		alt=1463
		;;

	*)
		echo "ERROR: site ${site} not found in settings!"
		;;

	esac
}

for site in ${sites}
do
	SiteSettings ${site}
	echo "IMPORT_BEFORE = ./io_base.ini" > io.ini
	echo "[Output]" >> io.ini
	echo "METEOPATH = ./${site}" >> io.ini
	echo "[Input]" >> io.ini

	let i=0
	for f in ${site}/*csv
	do
		let i=${i}+1
		nrh=$(awk -F, '{if($1=="Site Id") {print NR; exit}}' ${f})
		echo "STATION${i} = ${f}" >> io.ini
		echo "POSITION${i}	= latlon ${lat} ${lon} ${alt}" >> io.ini
		echo "CSV${i}_NR_HEADERS = ${nrh}" >> io.ini
		echo "CSV${i}_NAME	= ${sitename}" >> io.ini
		echo "CSV${i}_ID	= ${siteid}" >> io.ini
		echo "CSV${i}_FIELDS	= " $(fgrep "Site Id" ${f} | awk -F, -f parse_fields.awk) >> io.ini
	done

	${pathtometeoiotimeseries}/meteoio_timeseries -c io.ini -b ${start_year}-10-01T00:00 -e ${end_year}-10-01T00:00

	rm io.ini
done
