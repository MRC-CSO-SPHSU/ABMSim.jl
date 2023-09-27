module ABMSim

    export init_abmsim, ABMSIMVERSION

    const ABMSIMVERSION = v"0.6.1" # Integrate Space Concept into ABM types

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

    function init_abmsim()
        resetIDCOUNTER()
        nothing
    end


end
