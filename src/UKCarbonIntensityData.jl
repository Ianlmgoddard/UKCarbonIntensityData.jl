module UKCarbonIntensityData

using DataFrames
using DataFramesMeta
using Dates
using HTTP
using JSON
using Measures
using RecipesBase
using Statistics
using TimeZones
using Measures

export get_regional_data, get_carbon_intensity, get_todays_forecast

include("fetch.jl")
end
