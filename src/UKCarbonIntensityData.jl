module UKCarbonIntensityData

using DataFrames
using DataFramesMeta
using Dates
using HTTP
using JSON
using Measures
using OrderedCollections
using PlotUtils
using RecipesBase
using Statistics
using TimeZones
using Measures

export get_regional_data, get_carbon_intensity, get_todays_forecast
export get_generation_mix
export todays_plot, carbon_intensity
export AVAILABLE_REGIONS

include("fetch.jl")
include("plot.jl")
include("mappings.jl")
end
