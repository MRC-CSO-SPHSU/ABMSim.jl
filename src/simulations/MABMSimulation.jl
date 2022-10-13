"""
    Definition of a multi ABM simulation based on MultiABM concept/ 

        This file is part of  Simulations module 
"""

using  MultiAgents.Util: AbstractExample, DummyExample 

export MABMSimulation


mutable struct MABMSimulation <: AbstractMABMSimulation 

    simulations::Array{ABMSimulation,1}
    
    function MABMSimulation(mabm::AbstractMABM,properties::Dict{Symbol};
                            example::AbstractExample=DummyExample())
        n = length(mabm.abms)
        simulations = AbstractABMSimulation[] 
        for i in 1:n 
            abmsim = ABMSimulation(mabm.abms[i],properties,example=example)
            push!(simulations,abmsim)
        end 
        sim = new(mabm,simulations,properties)
        setup!(sim,example)
        sim 
    end

end # MABMSimulation 



