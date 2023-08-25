"""
Definition of an ABM-Simulator type.
"""

export ABMSimulator

# using ABMSim: defaultpoststep!, defaultprestep!
using ABMSim.Util: AbstractExample, DefaultExample

mutable struct ABMSimulatorP{SimParType} <: AbstractABMSimulator
    parameters::SimParType

    pre_model_steps::Vector{Function}
    agent_steps::Vector{Function}
    post_model_steps::Vector{Function}

    # example
    stepnumber::Int

    function ABMSimulatorP{SimParType}(
                    pars::SimParType;
                    example=DefaultExample(),setupEnabled=true) where SimParType
        # abmsimulation = new(pars,[defaultprestep!],[],[defaultpoststep!],0)
        abmsimulation = new(pars,[],[],[],0)
        setupEnabled ? setup!(abmsimulation,example) : nothing
        verify_majl(abmsimulation)
        abmsimulation
    end

end # ABMSimulatorP

const ABMSimulator = ABMSimulatorP{FixedStepSimPars}

ABMSimulator(;dt, starttime, finishtime,
example=DefaultExample(),
seed=0,verbose=false,yearly=false,
setupEnabled = true) =
    ABMSimulator(FixedStepSimPars( dt=dt,
                                    starttime = starttime, finishtime = finishtime,
                                    seed = seed, verbose = verbose, yearly = yearly),
                    example = example,
                    setupEnabled = setupEnabled)
