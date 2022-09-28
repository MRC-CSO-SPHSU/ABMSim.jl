"""
Main specification of a Simulation type 
"""

using Random
using Mixers 

using SomeUtil:   date2yearsmonths 

import MultiAgents: step!

export stepnumber, dt, startTime, finishTime, seed 
export initDefaultSimPars!, initDefaultFixedStepSimPars!
export DefaultSimulation

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed
#example(sim::AbstractSimulation)    = sim.example 
#time(sim::AbstractSimulation)       = sim.time  

@mix struct BasicPars 
    seed::Int 
    startTime::Int 
    finishTime::Int 
end # BasicPars 

@BasicPars mutable struct SimPars
    Simpars() = new(0,0,0)
end 

"Initialize default properties"
function initDefaultSimPars!(sim::AbstractSimulation;
                             seed=0,startTime=0,finishTime=0) 
    sim.parameters.seed       = seed 
    sim.parameters.startTime  = startTime
    sim.parameters.finishTime = finishTime
    # sim.time = Rational{Int}(startTime)
    nothing  
end 

abstract type AbsFixedStepSim <: AbstractSimulation end

dt(sim::AbsFixedStepSim)         = sim.parameters.dt
#currstep(sim::AbsFixedStepSim)   = sim.time 
stepnumber(sim::AbsFixedStepSim) = sim.stepnumber

@mix struct FixedPars 
    dt::Rational{Int} 
end 

@BasicPars @FixedPars mutable struct FixedStepSimPars
    FixedStepSimPars(dt) = new(0,0,0,dt)
end

function initDefaultFixedStepSimPars!(sim::AbsFixedStepSim;dt, 
                                      seed=0,startTime=0,finishTime=0) 

    initDefaultSimPars!(sim;seed=seed,startTime=startTime,finishTime=finishTime)
    sim.parameters.dt   = dt
    #sim.currstep        = Rational{Int}(startTime) 
    sim.stepnumber      = 0

    nothing 
end 


struct DefaultSimulation <: AbsFixedStepSim end 

step!(
    simulation::DefaultSimulation, 
    model,
    agent_step!,
    model_step!,  
    n::Int=1,
    agents_first::Bool=true,
)  = step!(model,agent_step!,model_step!,n,agents_first)

step!(
    simulation::DefaultSimulation, 
    model, 
    pre_model_step!,
    agent_step!,
    post_model_step!,  
    n::Int=1,
)  = step!(model,pre_model_step!,agent_step!,post_model_step!,n)

step!(
    simulation::DefaultSimulation,
    model::AbstractABM, 
    pre_model_steps::Vector{Function},
    agent_steps,
    post_model_steps,  
    n::Int=1,
)  = step!(model,pre_model_steps,agent_steps,post_model_steps,n)