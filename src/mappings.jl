"""
The carbon index bounds are static per year and defined in the
[Methodology](https://carbon-intensity.github.io/api-definitions/#carbon-intensity-api-v2-0-0) paper published byNG ESO
"""
const CARBON_INDEX_BOUNDS = OrderedDict(
    "Very Low" => (0, 44),
    "Low" => (45, 129),
    "Moderate" => (130, 209),
    "High" => (210, 310),
    "Very High" => (310, 400)
)

"""
Dict mapping region names to region ids.
"""
const AVAILABLE_REGIONS = Dict(
    "North Scotland" => 1,
    "South Scotland" => 2,
    "North West England" => 3,
    "North East England" => 4,
    "Yorkshire" => 5,
    "North Wales & Merseyside" => 6,
    "South Wales" => 7,
    "West Midlands" => 8,
    "East Midlands" => 9,
    "East England" => 10,
    "South West England" => 11,
    "South England" => 12,
    "London" => 13,
    "South East England" => 14,
    "England" => 15,
    "Scotland" => 16,
    "Wales" => 17,
    "GB" => 18
)
