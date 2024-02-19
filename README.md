# SNOWPACK_SNOTEL
Example SNOWPACK simulation for SNOTEL sites

## Requirements
- `curl`
- [MeteoIO](https://meteoio.slf.ch)

## Download SNOTEL data and prepare *smet files

1. Edit the file `settings.rc`, to define a list of sites, a starting year, and to provide the path to the `meteoio_timeseries` executable.
2. Execute the bash script `retrieve_data.sh`
3. Execute the bash script `convert_to_smet.sh`
