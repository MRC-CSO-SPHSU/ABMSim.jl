module MultiAgents

    include("src/AbstractXAgent.jl")

    include("src/abms/AbstractABM.jl")
    include("src/abms/ABM.jl")
    include("src/abms/MultiABM.jl")

    """
    Generic interface specifying main functions for
    executing an ABM / MABM simulation. 
    """

    include("src/simulations/AbstractSimulation.jl")
    include("src/simulations/AbstractABMSimulation.jl")
    include("src/simulations/ABMSimulation.jl")

    include("src/simulations/AbstractMABMSimulation.jl")
    include("src/simulations/MABMSimulation.jl") 

end 