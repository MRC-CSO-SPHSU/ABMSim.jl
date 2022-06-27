module MultiAgents

    include("src/AbstractXAgent.jl")

    include("src/abms/AbstractABM.jl")
    include("src/abms/ABM.jl")
    include("src/abms/MultiABM.jl")

end 