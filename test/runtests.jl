using UKCarbonIntensityData
using UKCarbonIntensityData: _unpack_df, _unpack_values, _parse_datetime, _parse_data
using UKCarbonIntensityData: _convert_mix
using DataFrames
using Dates
using Test
using TimeZones


function _test_df_inequality(a, b)
    @test issetequal(names(a), names(b))
    @test select(a, sort(names(a))) == select(b, sort(names(a)))
end

@testset "UKCarbonIntensityData.jl" begin
    include("fetch.jl")
end
