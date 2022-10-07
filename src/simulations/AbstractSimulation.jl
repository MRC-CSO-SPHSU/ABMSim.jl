"""
Main specification of a Simulation type. 
"""

using Random 
import Random.seed! 
export seed!

using Mixers 
using Parameters 

using MultiAgents.Util: date2YearsMonths 

import MultiAgents: step!

export dt, startTime, finishTime, seed, verbose, yearly
export stepnumber, currstep

export AbstractSimulation, AbsFixedStepSim, FixedStepSim
export initFixedStepSim!

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed
seed!(sim::AbstractSimulation)      = seed(sim) == 0 ?  Random.seed!(floor(Int, time())) : Random.seed!(seed)  
verbose(sim::AbstractSimulation)    = sim.parameters.verbose 


# sleeptime(sim::AbstractSimulation)  = sim.parameters.sleeptime

# The following could be employed (undecided)
#example(sim::AbstractSimulation)    = sim.example 
# time(sim::AbstractSimulation)       = sim.time  

@mix @with_kw struct BasicPars 
    seed :: Int       = 0
    startTime :: Int  = 0
    finishTime :: Int = 0 
    verbose :: Bool   = false
#    sleeptime :: Float64 = 0.0
end # BasicPars 

@BasicPars mutable struct SimPars end 

"Initialize default properties"
function initSimPars!(sim::AbstractSimulation;
                                startTime, finishTime,
                                seed=0, verbose=false) 

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
currstep(sim::AbsFixedStepSim)      = stepnumber(sim) * dt(sim) + 
                                        Rational{Int}(startTime(sim))

@mix @with_kw struct FixedStepPars 
    dt :: Rational{Int}     = 0 // 1  
    yearly :: Bool          = false   # doing some extra stuffs at the begining of every year
end 

@BasicPars @FixedStepPars mutable struct FixedStepSimPars end


function initFixedStepSim!(sim::AbsFixedStepSim;
                                        dt, startTime, finishTime,
                                        seed=0, verbose=false, yearly=false) 

    initSimPars!(sim;startTime=startTime, finishTime=finishTime,
                            seed=seed, verbose=verbose)

    sim.parameters.dt       = dt
    sim.parameters.yearly   = yearly
    # sim.currstep            = Rational{Int}(startTime) 
    sim.stepnumber          = 0

    nothing 
end 

mutable struct FixedStepSim <: AbsFixedStepSim
    parameters::FixedStepSimPars 
    stepnumber::Int 

    FixedStepSim(;dt,startTime,finishTime,seed=0,verbose=false,yearly=false) = 
        new( FixedStepSimPars( dt=dt, 
                startTime = startTime, finishTime = finishTime,
                seed = seed , verbose = verbose, yearly = yearly ), 0) 
    
    FixedStepSim() = new(FixedStepSimPars(),0)
end

function verboseStep(sim::AbsFixedStepSim) 
    (year,month) = date2YearsMonths(currstep(sim)) 
    iteryear = "########################################"
    yearly(sim) && month == 0   ? 
        println("conducting simulation step year $(year) \n$(iteryear)") : nothing 
    itermonth = "========================================================="
    yearly(sim) ? 
        nothing : 
        println("conducting simulation step year $(year) month $(month+1) \n$(itermonth)")
                  
    nothing 
end

function verboseStep(var,msg::String,sim::AbsFixedStepSim)
    if verbose(sim) 
        if yearly(sim) 
            curryear,currmonth = date2YearsMonths(currstep(sim)) 
            currmonth == 0 ? println("$msg : $var") : nothing 
        else 
            println("$msg : $var")
        end 
    end
    nothing 
end


function step!(model::AbstractABM,
                agent_step!,
                model_step!,
                sim::AbsFixedStepSim) 
    
    sim.parameters.verbose ? verboseStep(sim) : nothing 
    step!(model, agent_step!, model_step!)
    model.t += dt(sim)
    sim.stepnumber += 1
    # sim.currstep += dt(sim)
    nothing 
end

"""
Run a fixed step ABM simulation using stepping functions
    - agent_step
    - model_step 
    & 
    - abstract fxed step simulaton parameters 
"""
function run!(model::AbstractABM,
              agent_step!,
              model_step!,
              simulation::AbsFixedStepSim) 

    time(model) != currstep(simulation) ? 
        throw(ArgumentError("$(time(model)) is not initially equal to simulation currentstep $(currstep(simulation))")) : 
        nothing 

    seed!(simulation)

    for _ in currstep(simulation) : dt(simulation) : finishTime(simulation)
        step!(model,agent_step!,model_step!,simulation)
    end 

    nothing 
end 

function step!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                sim::AbsFixedStepSim) 

    sim.parameters.verbose ? verboseStep(sim) : nothing 
    step!(model, pre_model_step!, agent_step!, post_model_step!)
    model.t += dt(sim)
    sim.stepnumber += 1
    # sim.currstep += dt(sim)
    nothing 
end


function run!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                sim::AbsFixedStepSim) 

    time(model) != currstep(sim) ? 
        throw(ArgumentError("$(time(model)) is not equal to simulation currentstep $(currstep(sim))")) : 
        nothing 
    
    seed!(sim)

    for _ in currstep(sim) : dt(sim) : finishTime(sim)
        step!(model,pre_model_step!, agent_step!, post_model_step!,sim)
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

