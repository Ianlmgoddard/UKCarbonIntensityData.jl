@userplot todays_plot
@recipe function f(CI::todays_plot)

    data = get_todays_forecast()

    # plot handles `NaN`s, not `nothing`
    data.actual = replace(data.actual, nothing=>NaN)

    :seriestype --> :line
    :yguide --> "Carbon Intensity"
    :title --> "UK Carbon Intensity"
    :xrotation --> 45
    :size --> (600, 600)

    @series begin
        :label --> ["Forecast" "Actual"]
        (data.to, [data.forecast data.actual])
    end
end


@userplot carbon_intensity
@recipe function f(CI::carbon_intensity)
    start_date, end_date = CI.args

    data = get_carbon_intensity(start_date, end_date)

    :seriestype --> :line
    :legend --> :false
    :yguide --> "Carbon Intensity"
    :title --> "UK Carbon Intensity"

    return (data.to, data.forecast)
end
