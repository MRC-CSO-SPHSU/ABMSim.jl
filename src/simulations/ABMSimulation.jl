"""
Definition of an ABM-Simulation type.
""" 

export ABMSimulation 

using MultiAgents: defaultpoststep!, defaultprestep! 
using MultiAgents.Util: AbstractExample, DummyExample 

mutable struct ABMSimulation <: AbstractABMSimulation  
    parameters 
    
    pre_model_steps::Vector{Function} 
    agent_steps::Vector{Function}       
    post_model_steps::Vector{Function} 

    # example 
    # time :: Rational{Int}

    function ABMSimulation(pars;
                           example::AbstractExample=DummyExample()) 
        abmsimulation = new(pars,[defaultprestep!],[],[defaultpoststep!],example)
        setup!(abmsimulation,example)
        abmsimulation 
    end
end 

