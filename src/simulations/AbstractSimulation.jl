"""
Main specification of a Simulation type 
"""

using Random
using Mixers 
using Parameters 

using SomeUtil:   date2yearsmonths 

import MultiAgents: step!

export stepnumber, dt, startTime, finishTime, seed 
export initDefaultSimPars!, initDefaultFixedStepSimPars!
export AbstractSimulation, AbsFixedStepSim, DefaultSimulation

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed

# The following could be employed (undecided)
#example(sim::AbstractSimulation)    = sim.example 
#time(sim::AbstractSimulation)       = sim.time  

@mix @with_kw struct BasicSimPars 
    seed::Int       = 0
    startTime::Int  = 0
    finishTime::Int = 0 
end # BasicPars 

@BasicSimPars mutable struct SimPars end 

"Initialize default properties"
function initDefaultSimPars!(sim::AbstractSimulation;startTime,finishTime,seed=0) 
    sim.parameters.seed       = seed 
    sim.parameters.startTime  = startTime
    sim.parameters.finishTime = finishTime
    # sim.time = Rational{Int}(startTime)
    
    nothing  
end 

abstract type AbsFixedStepSim <: AbstractSimulation end

dt(sim::AbsFixedStepSim)         = sim.parameters.dt 
stepnumber(sim::AbsFixedStepSim) = sim.stepnumber

@mix @with_kw struct FixedPars 
    dt::Rational{Int} = 0 // 1  
end 

@BasicPars @FixedPars mutable struct FixedStepSimPars end

function initDefaultFixedStepSimPars!(sim::AbsFixedStepSim;dt,
                                        startTime,finishTime,seed=0) 

    initDefaultSimPars!(sim;seed=seed,startTime=startTime,finishTime=finishTime)
    sim.parameters.dt   = dt
    sim.currstep        = Rational{Int}(startTime) 
    sim.stepnumber      = 0

    nothing 
end 

"""
  This type corresponds to use Agents.jl capabilities for simualtion without  
  using MultiAgents.jl, i.e. there will be no Simulation types and only Agents.jl
  will be used for simulation  
"""
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