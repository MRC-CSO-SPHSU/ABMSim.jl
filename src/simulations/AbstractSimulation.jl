"""
Main specification of a Simulation type 
"""

using Random
using Mixers 

using SomeUtil:   date2yearsmonths 

import MultiAgents: step!

export stepnumber, dt, startTime, finishTime, seed 
export initDefaultSimPars!, initDefaultFixedStepSimPars!

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed
#example(sim::AbstractSimulation)    = sim.example 
#time(sim::AbstractSimulation)       = sim.time  

@mix BasicPars 
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

@mix FixedPars 
    dt::Rational{Int} 
end 

@BasicPars @BasicPars mutable struct FixedStepSimPars
    FixedStepSimPars(dt) = new(0,0,0,dt)
end

function initDefaultFixedStepSimPars!(sim::AbsFixedStepSim;dt, 
                                      seed=0,startTime=0,finishTime=0) 

    initDefaultSimPars!(sim;seed=seed,startTime=startTime,finishTime=finishTime)
    sim.parameters.dt   = dt
    sim.currstep        = Rational{Int}(startTime) 
    sim.stepnumber      = 0

    nothing 
end 


struct DefaultSimulation <: AbsFixedStepSim end 