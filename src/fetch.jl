"""
    get_carbon_intensity(start_date::ZonedDateTime, end_date::ZonedDateTime)

Returns a DataFrame of the nationwide forecast and actual carbon intensity between the
given `start_date` and `end_date`.
"""
function get_carbon_intensity(start_date::ZonedDateTime, end_date::ZonedDateTime)
    return _common_get_request(start_date, end_date, :intensity, "intensity")
end

"""
    get_generation_mix(start_date::ZonedDateTime, end_date::ZonedDateTime)

Returns a DataFrame of the national generation mix over period defined by the `start_date`
and `end_date`.
"""
function get_generation_mix(start_date, end_date)
    return _common_get_request(start_date, end_date, :generationmix, "generation")
end

"""
    get_todays_forecast(;regional::Bool=false, region::AbstractString="")

Returns a DataFrame of the forecast and actual carbon intensity between for the 48 hours
of the day the query is called. By default return national level data, pass `regional=true`
to return data with regional spatial resolution. To retreive data for a single region, pass
the `region = <desired region>` where <desired region> must be included in the the
`AVAILABLE_REGIONS`.
"""
function get_todays_forecast(;regional::Bool=false, region::AbstractString="")

    # TODO: When passing `region` != "", query the API for only that region,
    # as opposed to all regions. The reason this isn't done already is because the
    # retruned data has a different format when querying for a single region.


    if !isempty(region) && !in(region, keys(AVAILABLE_REGIONS))
        throw(DomainError("`$region` not in available regions, choose one of
        $(collect(keys(AVAILABLE_REGIONS)))"))
    end

    sd = Date(now())
    request_string = if regional
        "https://api.carbonintensity.org.uk/regional/intensity/$(sd)/fw48h"
    else
        "https://api.carbonintensity.org.uk/intensity/$(sd)/fw48h"
    end

    request = HTTP.request(
        "GET",
        request_string
    )
    data = JSON.parse(String(request.body))["data"]
    parsed_data = _parse_data(data)
    if !regional
        return _unpack_df(parsed_data, :intensity)
    elseif isempty(region)
        return _unpack_df(_unpack_df(parsed_data, :regions), :intensity)
    else
        df = _unpack_df(_unpack_df(parsed_data, :regions), :intensity)
        return @subset(df, :shortname.==region)
    end
end

"""
    get_carbon_intensity(start_date::ZonedDateTime, end_date::ZonedDateTime)

Returns a NamedTuple with two fields named `intensity` and `generation`.
Both tables contain data spanning the period defined by the `start_date` and `end_date`.
the `intensity` field contains a dataframe of the forecast data of the regional carbon
intensity, and the `generation` field contains a dataframe of the
regional generation as a percent of the total generation.
"""
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
            @warn("error $e for date range $range")
        end
    end
    return (;
        intensity = reduce(vcat, intensity_dfs),
        generation = reduce(vcat, generation_dfs)
    )
end


"""
function to fetch and process data return via the API in common format.
"""
function _common_get_request(start_date, end_date, unpack_column, url_branch)
    date_ranges = collect(Iterators.partition(start_date:Day(1):end_date, floor(Int, 10)))
    parsed_dfs = map(date_ranges) do range
        try
            request = HTTP.request(
                "GET",
                "https://api.carbonintensity.org.uk/$(url_branch)/$(first(range))/$(last(range))"
            )
            data = JSON.parse(String(request.body))["data"]
            parsed_data = _parse_data(data)
            return _unpack_df(parsed_data, unpack_column)
        catch e
            @warn("error $e for date range $range")
        end
    end

    return reduce(vcat, parsed_dfs)
end

"""
helper function to unpack the generation mix arrays into a single Dict.
"""
function _convert_mix(a)
    return Dict(getindex.(a, "fuel") .=> getindex.(a, "perc"))
end

"""
helper function to parse the JSON data requested.

# TODO: Don't convert each element of `data` to DataFrame as this adds a lot of
unnecessary allocations
"""
_parse_data(data::AbstractArray) = _parse_data(reduce(vcat, DataFrame.(data)))

function _parse_data(parsed_df::DataFrame)
    parsed_df.from = _parse_datetime.(parsed_df.from)
    parsed_df.to = _parse_datetime.(parsed_df.to)
    return parsed_df
end

"""
helper function to unpack nested dictionaries.
"""
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
