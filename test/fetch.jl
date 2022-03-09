@testset "fetch.jl" begin
    @testset "_unpack_df" begin
        test_df = DataFrame(
            :a => [1, 2],
            :b => [Dict("s" => 5, "t" => 6), Dict("s" => 2, "t" => 7)]
        )

        expected = DataFrame(
            :a => [1, 2],
            :s => [5, 2],
            :t => [6, 7]
        )

        _test_df_inequality(_unpack_df(test_df, :b), expected)
    end

    @testset "_unpack_values" begin
        @testset "dicts" begin
            ex = Dict("s" => 5, "t" => 6)

            @test issetequal(_unpack_values(ex), [5, 6])
        end
        @testset "arrays" begin
            ex1 = Dict("s" => 5, "t" => 6)
            ex2 = Dict("s" => 2, "t" => 7)
            @test _unpack_values([ex1, ex2]) == [6 7; 5 2]
        end
    end

    @testset "_parse_datetime" begin
        dt = "2021-10-01T01:01Z"
        @test _parse_datetime(dt) == DateTime(2021, 10, 1, 1, 1)
    end

    @testset "_parse_data" begin
        @testset "dataframe dispatch" begin
            ex = DataFrame(
                :from => ["2021-10-01T01:01Z", "2021-05-01T01:01Z"],
                :to => ["2021-10-02T01:01Z", "2021-05-02T01:01Z"]
            )

            expected =  DataFrame(
                :from => [DateTime(2021, 10, 1, 1, 1), DateTime(2021, 05, 1, 1, 1)],
                :to => [DateTime(2021, 10, 2, 1, 1), DateTime(2021, 05, 2, 1, 1)]
            )
            @test _parse_data(ex) == expected
        end

        @testset "array dispatch" begin
            ex = DataFrame(
                :from => ["2021-10-01T01:01Z", "2021-05-01T01:01Z"],
                :to => ["2021-10-02T01:01Z", "2021-05-02T01:01Z"]
            )

            expected = DataFrame(
                :from => [
                    DateTime(2021, 10, 1, 1, 1),
                    DateTime(2021, 05, 1, 1, 1),
                    DateTime(2021, 10, 1, 1, 1),
                    DateTime(2021, 05, 1, 1, 1),
                ],
                :to => [
                    DateTime(2021, 10, 2, 1, 1),
                    DateTime(2021, 05, 2, 1, 1),
                    DateTime(2021, 10, 2, 1, 1),
                    DateTime(2021, 05, 2, 1, 1),
                ]
            )

            data = [ex, ex]
            @test _parse_data(data) == expected
        end

        @testset "convert_mix" begin
            ex1 = Dict("fuel" => "hydro", "perc" => 0.5)
            ex2 = Dict("fuel" => "gas", "perc" => 0.1)
            data = [ex1, ex2]

            expected = Dict("hydro"=> 0.5, "gas"=> 0.1)
            @test _convert_mix(data) == expected
        end
    end


    @testset "get carbon intensity" begin
        @testset "short date range" begin
            start_date = ZonedDateTime(2021, 1, 1, tz"UTC")
            end_date = ZonedDateTime(2021, 1, 10, tz"UTC")

            data = get_carbon_intensity(start_date, end_date)

            @test maximum(data.to) <= end_date.utc_datetime
            @test minimum(data.to) >= start_date.utc_datetime

            @test data isa DataFrame
            @test !isempty(data)
            @test issetequal(names(data), ["to", "from", "forecast", "actual", "index"])
        end

        @testset "longer daterange" begin
            start_date = ZonedDateTime(2021, 1, 1, tz"UTC")
            end_date = ZonedDateTime(2021, 2, 1, tz"UTC")

            data = get_carbon_intensity(start_date, end_date)

            @test maximum(data.to) <= end_date.utc_datetime
            @test minimum(data.to) >= start_date.utc_datetime

            @test data isa DataFrame
            @test !isempty(data)
            @test issetequal(names(data), ["to", "from", "forecast", "actual", "index"])
        end
    end

    @testset "get regional data" begin
        @testset "shorter daterange" begin
            start_date = ZonedDateTime(2021, 1, 1, tz"UTC")
            end_date = ZonedDateTime(2021, 1, 10, tz"UTC")

            data = get_regional_data(start_date, end_date)

            @test data isa NamedTuple
            @test issetequal(propertynames(data), [:intensity, :generation])

            intensity = data.intensity
            generation = data.generation

            @test maximum(intensity.to) <= end_date.utc_datetime
            @test minimum(intensity.to) >= start_date.utc_datetime

            @test maximum(generation.to) <= end_date.utc_datetime
            @test minimum(generation.to) >= start_date.utc_datetime

            @test intensity isa DataFrame
            @test !isempty(intensity)
            @test issetequal(
                names(intensity),
                [
                    "to", "from", "forecast", "shortname", "dnoregion",
                    "regionid", "generationmix", "index"
                ]
            )

            @test generation isa DataFrame
            @test !isempty(generation)
            @test issetequal(
                names(generation),
                [
                    "to", "from", "intensity", "shortname", "dnoregion",
                    "regionid", "coal", "hydro", "biomass", "imports",
                    "nuclear", "other", "solar", "gas", "wind"
                ]
            )
        end

        @testset "longer daterange" begin
            start_date = ZonedDateTime(2021, 1, 1, tz"UTC")
            end_date = ZonedDateTime(2021, 2, 1, tz"UTC")

            data = get_regional_data(start_date, end_date)


            @test data isa NamedTuple
            @test issetequal(propertynames(data), [:intensity, :generation])

            intensity = data.intensity
            generation = data.generation

            @test maximum(intensity.to) <= end_date.utc_datetime
            @test minimum(intensity.to) >= start_date.utc_datetime

            @test maximum(generation.to) <= end_date.utc_datetime
            @test minimum(generation.to) >= start_date.utc_datetime

            @test intensity isa DataFrame
            @test !isempty(intensity)
            @test  issetequal(
                names(intensity),
                [
                    "to", "from", "forecast", "shortname", "dnoregion",
                    "regionid", "generationmix", "index"
                ]
            )

            @test generation isa DataFrame
            @test !isempty(generation)
            @test issetequal(
                names(generation),
                [
                    "to", "from", "intensity", "shortname", "dnoregion",
                    "regionid",  "coal", "hydro", "biomass", "imports",
                    "nuclear", "other", "solar", "gas", "wind"
                ]
            )
        end
    end

    @testset "get todays forecast" begin
        @testset "default" begin
            data = get_todays_forecast()
            @test data isa DataFrame
            @test !isempty(data)
            @test issetequal(names(data), ["to", "from", "forecast", "actual", "index"])
        end

        @testset "region kwarg" begin
            data = get_todays_forecast(regional=true)

            @test data isa DataFrame
            @test !isempty(data)
            @test issetequal(
                names(data),
                [
                    "to", "from", "forecast", "shortname", "dnoregion",
                    "regionid", "generationmix", "index"
                ]
            )
        end

        @testset "specific region" begin
            data = get_todays_forecast(regional=true, region = "North Scotland")

            @test data isa DataFrame
            @test all(data.shortname.=="North Scotland")
            @test issetequal(
                names(data),
                [
                    "to", "from", "forecast", "shortname", "dnoregion",
                    "regionid", "generationmix", "index"
                ]
            )
        end

        @testset "throw error on bad region" begin
            @test_throws DomainError get_todays_forecast(regional=true, region = "not a region")
        end
    end
end
