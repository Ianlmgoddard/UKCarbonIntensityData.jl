```@meta
CurrentModule = UKCarbonIntensityData
```

# UKCarbonIntensityData

Documentation for [UKCarbonIntensityData](https://github.com/ianlmgoddard/UKCarbonIntensityData.jl).

## Retrieving Data
We can use this package to retrieve the recorded carbon intensity (measured in gCO₂/kWh) over a specified date range. 

### National data
```@example Example
using UKCarbonIntensityData
using Plots
using TimeZones

start_date = ZonedDateTime(2022, 01, 01, tz"UTC")
end_date = ZonedDateTime(2022, 02, 28, tz"UTC")

# get national level intensity data for the given period
national_data = get_carbon_intensity(start_date, end_date)
first(national_data, 5)
```

### Regional data
We can also retrieve the forecasted carbon intensity at the regional level
```@example Example
regional_data = get_regional_data(start_date, end_date)
regional_intensity = regional_data.intensity;
regional_mix = regional_data.generation;
display(first(regional_mix))
```



## Todays forecast
We can also grab the forecast data for the next 48 hours, at both national or regional levels.
```@example Example 
national_data = get_todays_forecast()
first(national_data)
```

```@example Example 
regional_data = get_todays_forecast(regional = true)
first(regional_data)
```


## Plotting Data
This package also exports some recipes to plot the data. Below shows how we can retrieve the 48 hour forecast data, for the nation as a whole, 
```@example Example
todays_plot()
```

or for a specific region
```@example Example
todays_plot(region = "South Scotland")
```

```@example Example
todays_plot(region = "North West England")
```

We can also view the recorded carbon intensity over a given time period

```@example Example
carbon_intensity(start_date, end_date)
```