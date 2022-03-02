using UKCarbonIntensityData
using Documenter

DocMeta.setdocmeta!(UKCarbonIntensityData, :DocTestSetup, :(using UKCarbonIntensityData); recursive=true)

makedocs(;
    modules=[UKCarbonIntensityData],
    authors="Ian Goddard",
    repo="https://github.com/ianlmgoddard/UKCarbonIntensityData.jl/blob/{commit}{path}#{line}",
    sitename="UKCarbonIntensityData.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ianlmgoddard.github.io/UKCarbonIntensityData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md"
    ],
    checkdocs=:exports,
    strict=false,
)

deploydocs(;
    repo="github.com/Ianlmgoddard/UKCarbonIntensityData.jl",
    #devbranch="main",
    push_preview=true,
)
