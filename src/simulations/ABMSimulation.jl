"""
Definition of an ABM-Simulation type.
""" 

export ABMSimulation 

# using MultiAgents: defaultpoststep!, defaultprestep! 
using MultiAgents.Util: AbstractExample, DefaultExample

mutable struct ABMSimulation <: AbstractABMSimulation  
    parameters::FixedStepSimPars 
    
    pre_model_steps::Vector{Function} 
    agent_steps::Vector{Function}       
    post_model_steps::Vector{Function} 

    # example 
    stepnumber::Int 

    function ABMSimulation(pars::FixedStepSimPars;
                           example=DefaultExample(),setupEnabled=true) 
        # abmsimulation = new(pars,[defaultprestep!],[],[defaultpoststep!],0)
        abmsimulation = new(pars,[],[],[],0)
        setupEnabled ? setup!(abmsimulation,example) : nothing 
        abmsimulation 
    end

    function ABMSimulation(pars;example=DefaultExample(),setupEnabled=true) 
        parameters = FixedStepSimPars()
        initFixedStepSimPars!(parameters,pars)
        ABMSimulation(parameters,example=example,setupEnabled=setupEnabled)
    end
        

    ABMSimulation(;dt, startTime, finishTime, 
        example=DefaultExample(),
        seed=0,verbose=false,yearly=false, 
        setupEnabled = true) = 
            ABMSimulation(FixedStepSimPars( dt=dt, 
                                            startTime = startTime, finishTime = finishTime,
                                            seed = seed, verbose = verbose, yearly = yearly), 
                            example = example,
                            setupEnabled = setupEnabled) 
    
end 

