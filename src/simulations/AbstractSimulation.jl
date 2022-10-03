"""
Main specification of a Simulation type 
"""

using Random
using Mixers 
using Parameters 

using MultiAgents.Util: date2YearsMonths 

import MultiAgents: step!

export dt, startTime, finishTime, seed, verbose, yearly 
export stepnumber, 
export initDefaultSimPars!, initDefaultFixedStepSimPars!
export AbstractSimulation, AbsFixedStepSim, DefaultSimulation

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed
verbose(sim::AbstractSimulation)    = sim.parameters.verbose 
# sleeptime(sim::AbstractSimulation)  = sim.parameters.sleeptime

# The following could be employed (undecided)
#example(sim::AbstractSimulation)    = sim.example 
#time(sim::AbstractSimulation)       = sim.time  

@mix @with_kw struct BasicSimPars 
    seed :: Int       = 0
    startTime :: Int  = 0
    finishTime :: Int = 0 
    verbose :: False  = false
#    sleeptime :: Float64 = 0.0
end # BasicPars 

@BasicSimPars mutable struct SimPars end 

"Initialize default properties"
function initDefaultSimPars!(sim::AbstractSimulation;
                                startTime,finishTime,seed=0,verbose=false) 
    sim.parameters.seed       = seed 
    sim.parameters.startTime  = startTime
    sim.parameters.finishTime = finishTime
    sim.parameters.verbose    = verbose 
    # sim.time = Rational{Int}(startTime)
    
    nothing  
end 

abstract type AbsFixedStepSim <: AbstractSimulation end

dt(sim::AbsFixedStepSim)            = sim.parameters.dt 
yearly(sim::AbsFixedStepSim)        = sim.parameters.yearly
stepnumber(sim::AbsFixedStepSim)    = sim.stepnumber

@mix @with_kw struct FixedPars 
    dt :: Rational{Int}     = 0 // 1  
    yearly :: Bool          = false   # doing some extra stuffs at the begining of every year
end 

@BasicPars @FixedPars mutable struct FixedStepSimPars end

function initDefaultFixedStepSimPars!(sim::AbsFixedStepSim;dt,
                                      startTime,finishTime,seed=0,
                                      verbose=false,yearly=false) 

    initDefaultSimPars!(sim;startTime=startTime,finishTime=finishTime,
                            seed=seed,verbose=verbose)

    sim.parameters.dt   = dt
    sim.currstep        = Rational{Int}(startTime) 
    sim.stepnumber      = 0
    sim.yearly          = verbose 

    nothing 
end 

function verboseStep(sim::AbsFixedStepSim) 

    (year,month) = date2yearsmonths(sim.currstep) 
    yearly && month == 0 ? println("conducting simulation step year $(year)") : nothing 
    yearly               ? nothing : println("conducting simulation step year $(year) month $(month+1)")
                                     println("=========================================================")
    nothing 
end

"""
Run a simulation using stepping functions
    - agent_step
    - model_step
"""
function run!(model::AbstractABM,
              agent_step!,
              model_step!,
              simulation::AbsFixedStepSim) 

    Random.seed!(seed(simulation))

    for _ in startTime(simulation) : dt(simulation) : finishTime(simulation)
        sim.parameters.verbose ? verboseStep(simulation) : nothing 
        step!(model, agent_step!, model_step!)
        simulation.stepnumber += 1
        simulation.currstep += dt(simulation)
    end 

    nothing 
end 

"""
Run a simulation using stepping functions
"""
function run!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                simulation::AbsFixedStepSim) 

    Random.seed!(seed(simulation))

    for _ in startTime(simulation) : dt(simulation) : finishTime(simulation)
        sim.parameters.verbose ? verboseStep(sim) : nothing 
        step!(model,pre_model_step!, agent_step!, post_model_step!)
        simulation.stepnumber += 1
        simulation.currstep += dt(sim)
    end 

    nothing 
end 


#=
"""
  This type corresponds to use Agents.jl capabilities for simualtion without  
  using MultiAgents.jl, i.e. there will be no Simulation types and only Agents.jl
  will be used for simulation  
"""
struct DefaultSimulation <: AbstractSimulation end 

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
=# 

