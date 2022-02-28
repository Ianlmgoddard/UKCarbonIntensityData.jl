# UKCarbonIntensityData.jl

A Julia wrapper for the UK Electricity System operator (UK-ESO) [carbon intensity data API.](https://carbon-intensity.github.io/api-definitions/?python#carbon-intensity-api-v2-0-0)

## Examples

The Carbon intensity API lets us grab data at different spatial scales, either nationwide or regional, and over different time period. The following examples show how we can use this package to retrieve this data. Note that the data has half hourly temporal resolution.

```Julia
using TimeZones
using DataFrames
using UKCarbonIntensityData

start_date = ZonedDateTime(2022, 01, 01, tz"UTC")
end_date = ZonedDateTime(2022, 02, 28, tz"UTC")

# get national level intensity data for the given period
national_data = get_carbon_intensity(start_date, end_date)
```

We can also fetch data at the regional level, the `get_regional_data` function returns a NamedTuple with two fields. The fields contain a DataFrame of the carbon intensity in each region, and the generation mix for the region respectively. 
```Julia
regional_data = get_regional_data(start_date, end_date)
regional_intensity = regional_data.intensity;
regional_mix = regional_data.generation;
```

To quickly grab the forecast for todays forecast and realised carbon intensities, we can use `get_todays_forecast`. By default this will return national level data, however we can pass the `regional_kwarg` to return regional data.
```Julia
national_data = get_todays_forecast()

regional_data = get_todays_forecast(regional = true)
```



