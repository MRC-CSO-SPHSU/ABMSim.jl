module MultiAgents

    export init_majl, MAVERSION

    const MAVERSION = v"0.4.1" # Integrations of basic Agents.jl types

    include("src/Util.jl")

    include("src/abstractagent.jl")

    include("src/abms/abstractabm.jl")
    include("src/abms/abmtypes.jl")
    include("src/abms/multiabm.jl")

    """
    Generic interface specifying main functions for
    executing an ABM / MABM simulation.
    """

    include("src/simulations/abstractsimulator.jl")
    include("src/simulations/abstractabmsimulator.jl")
    include("src/simulations/abmsimulator.jl")

    function init_majl()
        resetIDCOUNTER()
        nothing
    end


end
