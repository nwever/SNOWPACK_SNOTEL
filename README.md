# SNOWPACK_SNOTEL
Example SNOWPACK simulation for SNOTEL sites, including data from National Park Service Arctic Network (ARCN) sites

## Requirements
- `curl`
- [MeteoIO](https://meteoio.slf.ch)

## Download SNOTEL data and prepare *smet files

1. Edit the file `settings.rc`, to define a list of sites (sites=""), a starting year, and to provide the path to the `meteoio_timeseries` executable.
2. Execute the bash script `retrieve_data.sh`
3. Execute the bash script `convert_to_smet.sh`


## Download National Park Service Arctic Network (ARCN) and prepare *smet files

1. Edit the file `settings.rc`, to define a list of sites (NPSsites), a starting year, and to provide the path to the `meteoio_timeseries` executable.
2. Execute the bash script `retrieve_NPS_data.sh`
3. Execute the bash script `convert_NPS_to_smet.sh`
