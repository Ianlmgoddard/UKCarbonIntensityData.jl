function get_carbon_intensity(start_date, end_date)
    # get 10 days period as API only allows requests of less than 14 days
    date_ranges = collect(Iterators.partition(start_date:Day(1):end_date, floor(Int, 10)))

    parsed_dfs = map(date_ranges) do range
        try
            request = HTTP.request(
                "GET",
                "https://api.carbonintensity.org.uk/intensity/$(first(range))/$(last(range))"
            )
            data = JSON.parse(String(request.body))["data"]
            parsed_data = _parse_data(data)
            return _unpack_df(parsed_data, :intensity)
        catch e
            # fix this
            @warn(e)
        end
    end

    return reduce(vcat, parsed_dfs)
end


function get_todays_forecast(;regional::Bool=false)
    sd = Date(now())
    request_string = if regional
        "https://api.carbonintensity.org.uk/regional/intensity/$(sd)/fw24h"
    else
        "https://api.carbonintensity.org.uk/intensity/$(sd)/fw24h"
    end

    request = HTTP.request(
        "GET",
        request_string
    )
    data = JSON.parse(String(request.body))["data"]
    parsed_data = _parse_data(data)
    if regional
        return _unpack_df(_unpack_df(parsed_data, :regions), :intensity)
    else
        return _unpack_df(parsed_data, :intensity)
    end
end

function get_regional_data(start_date, end_date)
    # get 10 days period as API only allows requests of less than 14 days
    date_ranges = collect(Iterators.partition(start_date:Day(1):end_date, floor(Int, 10)))
    intensity_dfs = []
    generation_dfs = []

    for range in date_ranges
        try
            request = HTTP.request(
                "GET",
                "https://api.carbonintensity.org.uk/regional/intensity/$(first(range))/$(last(range))"
            )
            data = JSON.parse(String(request.body))["data"]
            parsed_data = _parse_data(data)
            region_unpack = _unpack_df(parsed_data, :regions)
            region_unpack.generationmix .= _convert_mix.(region_unpack.generationmix)
            intensity_df = _unpack_df(region_unpack, :intensity)
            generation_df = _unpack_df(region_unpack, :generationmix)

            push!(intensity_dfs, intensity_df)
            push!(generation_dfs, generation_df)
        catch e
            # fix this
            @warn(e)
        end
    end
    return (;
        intensity = reduce(vcat, intensity_dfs),
        generation = reduce(vcat, generation_dfs)
    )
end

"""
helper function to unpack the generation mix arrays into a single Dict.
"""
function _convert_mix(a)
    return Dict(getindex.(a, "fuel") .=> getindex.(a, "perc"))
end

_parse_data(data::AbstractArray) = _parse_data(reduce(vcat, DataFrame.(data)))

function _parse_data(parsed_df::DataFrame)
    parsed_df.from = _parse_datetime.(parsed_df.from)
    parsed_df.to = _parse_datetime.(parsed_df.to)
    return parsed_df
end


function _unpack_df(df, unpack_col)
    # copy so we don't mutate the input
    parsed_df = deepcopy(df)
    # add new columns to unpack the intensity data
    _unpacked_values = _unpack_values(parsed_df[!, unpack_col])
    for (counter, key) in enumerate(keys(first(parsed_df[!, unpack_col])))
        parsed_df[!, key] = _unpacked_values[counter, :]
    end
    return select(parsed_df, Not(unpack_col))
end

_unpack_values(d::AbstractDict) = [v for v in values(d)]
_unpack_values(d::AbstractArray)= reduce(hcat, _unpack_values.(d))


"""
helper function to parse timestamps.
"""
function _parse_datetime(dt)
    return DateTime.(first.(split.(dt, "Z")), dateformat"y-m-dTH:M")
end
