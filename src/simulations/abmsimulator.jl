"""
Definition of an ABM-Simulation type.
""" 

export ABMSimulation 

# using MultiAgents: defaultpoststep!, defaultprestep! 
using MultiAgents.Util: AbstractExample, DefaultExample

mutable struct ABMSimulationP{SimParType} <: AbstractABMSimulation  
    parameters::SimParType 
    
    pre_model_steps::Vector{Function} 
    agent_steps::Vector{Function}       
    post_model_steps::Vector{Function} 

    # example 
    stepnumber::Int 

    function ABMSimulationP{SimParType}(
                    pars::SimParType;
                    example=DefaultExample(),setupEnabled=true) where SimParType 
        # abmsimulation = new(pars,[defaultprestep!],[],[defaultpoststep!],0)
        abmsimulation = new(pars,[],[],[],0)
        setupEnabled ? setup!(abmsimulation,example) : nothing 
        verify_majl(abmsimulation)
        abmsimulation 
    end

end # ABMSimulationP

const ABMSimulation = ABMSimulationP{FixedStepSimPars}

ABMSimulation(;dt, starttime, finishtime, 
example=DefaultExample(),
seed=0,verbose=false,yearly=false, 
setupEnabled = true) = 
    ABMSimulation(FixedStepSimPars( dt=dt, 
                                    starttime = starttime, finishtime = finishtime,
                                    seed = seed, verbose = verbose, yearly = yearly), 
                    example = example,
                    setupEnabled = setupEnabled) 
