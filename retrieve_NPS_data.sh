source settings.rc

curl -o WC_G_2023_ARCN_Corrected_Data.zip https://irma.nps.gov/DataStore/DownloadFile/694997

for site in ${NPSsites}
do
	unzip -p WC_G_2023_ARCN_Corrected_Data.zip WC_G_*_${site}.csv > ${site}.csv
done
