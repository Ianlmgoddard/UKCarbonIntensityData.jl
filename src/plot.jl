"""
    todays_plot(; region = "")

Plot the 48 forecast for the carbon intensity starting from midnight on the day that the
function is called. By default shows the national forecast. If the `region` kwarg is a valid
region, then plot data for this region only. Valid regions are contained in
[`AVAILABLE_REGIONS`](@ref).
"""
@userplot todays_plot
@recipe function f(CI::todays_plot; region = "")

    data = if isempty(region)
        get_todays_forecast()
    else
        get_todays_forecast(;regional = true, region = region)
    end


    :seriestype --> :line
    :yguide --> "Carbon Intensity (gCO₂/kWh)"
    :title --> if isempty(region) "UK Carbon Intensity" else "$region Carbon Intensity" end
    :xrotation --> 45
    :size --> (700, 500)
    :legend --> :topleft
    :margin --> 10mm

    @series begin
        :label --> "Forecast"
        :seriescolor --> :black
        :linestyle --> :dot
        :linewidth --> 2
        (data.to, data.forecast)
    end

    if isempty(region)
        # plot handles `NaN`s, not `nothing`
        data.actual = replace(data.actual, nothing=>NaN)
        @series begin
            :label --> "Actual"
            :seriescolor --> :black
            :linewidth --> 2
            :linestyle --> :solid
            (data.to, data.actual)
        end
    end

    colors = PlotUtils.palette(:RdYlGn_10, length(CARBON_INDEX_BOUNDS), rev = true)
    for (counter, (label, boundaries)) in enumerate(CARBON_INDEX_BOUNDS)
        @series begin
            :seriestype --> :line
            :label --> label
            :seriescolor --> colors[counter]
            :fillrange --> (boundaries)
            :fillalpha --> 0.2
            :seriesalpha --> 0.8
            (data.to, fill(last(boundaries), length(data.to)))
        end
    end
end


"""
    carbon_intensity(start_date, end_date)

Plots the recorded carbon intensity over the period given by the `start_date`
and `end_date`.
"""
@userplot carbon_intensity
@recipe function f(CI::carbon_intensity)
    start_date, end_date = CI.args

    data = get_carbon_intensity(start_date, end_date)

    # plot handles `NaN`s, not `nothing`
    data.actual = replace(data.actual, nothing=>NaN)

    :yguide --> "Carbon Intensity (gCO₂/kWh)"
    :title --> "UK Carbon Intensity"
    :size --> (700, 500)
    :margin --> 10mm

    @series begin
        :seriestype --> :line
        :label --> "actual"
        :seriescolor --> :black
        (data.to, data.actual)
    end


    colors = PlotUtils.palette(:RdYlGn_10, length(CARBON_INDEX_BOUNDS), rev = true)
    for (counter, (label, boundaries)) in enumerate(CARBON_INDEX_BOUNDS)
        @series begin
            :seriestype --> :line
            :label --> label
            :seriescolor --> colors[counter]
            :fillrange --> (boundaries)
            :fillalpha --> 0.2
            :seriesalpha --> 0.8
            (data.to, fill(last(boundaries), length(data.to)))
        end
    end
end
