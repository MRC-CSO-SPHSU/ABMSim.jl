"""
Main specification of a Simulation type. 
"""

using Mixers 
using Parameters 
using Random

using MultiAgents.Util: date2YearsMonths 

export dummystep, errorstep
export dt, startTime, finishTime, seed, verbose, yearly
export stepnumber, currstep

export AbstractSimulation, AbsFixedStepSim, FixedStepSim, DefaultFixedStepSim
export initFixedStepSim!, stepTime!

abstract type AbstractSimulation end 

startTime(sim::AbstractSimulation)  = sim.parameters.startTime
finishTime(sim::AbstractSimulation) = sim.parameters.finishTime
seed(sim::AbstractSimulation)       = sim.parameters.seed
verbose(sim::AbstractSimulation)    = sim.parameters.verbose 


# sleeptime(sim::AbstractSimulation)  = sim.parameters.sleeptime

# The following could be employed (undecided)
#example(sim::AbstractSimulation)    = sim.example 
# time(sim::AbstractSimulation)       = sim.time  

@mix @with_kw struct BasicPars 
    seed :: Int       = 0
    startTime :: Rational{Int}  = 0
    finishTime :: Rational{Int} = 0 
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

struct DefaultFixedStepSim <: AbsFixedStepSim end 

dt(sim::AbsFixedStepSim)            = sim.parameters.dt 
yearly(sim::AbsFixedStepSim)        = sim.parameters.yearly
stepnumber(sim::AbsFixedStepSim)    = sim.stepnumber
currstep(sim::AbsFixedStepSim)      = stepnumber(sim) * dt(sim) + 
                                        Rational{Int}(startTime(sim))

"dummy stepping function for arbitrary agents"
dummystep(::AbstractAgent,::AbstractABM,
            sim::AbsFixedStepSim=DefaultFixedStepSim()) = nothing 
                                         
"default dummy model stepping function"
dummystep(::AbstractABM,
            sim::AbsFixedStepSim=DefaultFixedStepSim()) = nothing 
                                        
"Default agent stepping function for reminding the client that it should be provided"
errorstep(::AbstractAgent,::AbstractABM,
            sim::AbsFixedStepSim=DefaultFixedStepSim()) = 
                error("agent stepping function has not been specified")
                                        
"Default model stepping function for reminding the client that it should be provided"
errorstep(::AbstractABM,
            sim::AbsFixedStepSim=DefaultFixedStepSim()) = 
                error("model stepping function has not been specified")
                                        

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
    
    # FixedStepSim() = new(FixedStepSimPars(),0)
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

stepTime!(model::AbstractABM,sim::AbsFixedStepSim) = 
    model.t += dt(sim)

function prestep!(model::AbstractABM,sim::AbsFixedStepSim) 
    verbose(sim) ? verboseStep(sim) : nothing 
    stepTime!(model,sim)
    sim.stepnumber += 1
    nothing 
end 

prestep!(model::AbstractABM,::DefaultFixedStepSim) = nothing 

function apply_agent_step!(model,agent_step!::Function,::DefaultFixedStepSim) 
    for agent in allagents(model)
        agent_step!(agent,model) 
    end
    nothing 
end

function apply_agent_step!(model,agent_step!::Function,sim::AbsFixedStepSim) 
    for agent in allagents(model)
        agent_step!(agent,model,sim) 
    end
    nothing 
end

apply_agent_step!(model,agent_steps::Vector{Function},sim::AbsFixedStepSim) = 
    for k in 1:length(agent_steps) 
        apply_agent_step!(model,agent_steps[k],sim)
    end 

apply_model_step!(model,model_step!::Function,::DefaultFixedStepSim) = model_step!(model) 
apply_model_step!(model,model_step!::Function,sim::AbsFixedStepSim) = model_step!(model,sim) 
apply_model_step!(model,model_steps::Vector{Function},sim::AbsFixedStepSim) = 
    for k in 1:length(model_steps) 
        apply_model_step!(model,model_steps[k],sim)
    end


"""
Stepping function for a model of type AgentBasedModel with 
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
    agents_first : agent_step! executed first before model_step
"""
function step!(model::AbstractABM,
                agent_step!, sim::AbsFixedStepSim=DefaultFixedStepSim(); 
                n::Int=1)

    for _ in 1:n 
        prestep!(model,sim)
        apply_agent_step!(model,agent_step!,sim)
    end

    nothing 
end 

function prerun!(model,sim)::Int  
    time(model) != currstep(sim) ? 
        throw(ArgumentError("$(time(model)) is not initially equal to simulation currentstep $(currstep(sim))")) :
        nothing 
    if Random.GLOBAL_SEED != seed(sim)
        seed(sim) == 0 ?  seed!(floor(Int, time())) : seed!(seed(sim))
    end 
    trunc(Int,(finishTime(sim) - currstep(sim)) / dt(sim)) 
end

function run!(model::AbstractABM,
                agent_step!, 
                sim::AbsFixedStepSim=DefaultFixedStepSim())
    nsteps = prerun!(model,sim)
    step!(model,agent_step!,sim,n=nsteps) 
    nothing 
end 


function step!(model::AbstractABM,
                agent_step!,
                model_step!,
                sim::AbsFixedStepSim=DefaultFixedStepSim();  
                n::Int=1,
                agents_first::Bool=true ) 
    
    for _ in 1:n 

        prestep!(model,sim)

        if agents_first 
            apply_agent_step!(model,agent_step!,sim) 
        end
    
        apply_model_step!(model,model_step!,sim)
    
        if !agents_first
            apply_agent_step!(model,agent_step!,sim)
        end
        
    end 
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
              sim::AbsFixedStepSim) 
    nsteps = prerun!(model,sim)
    step!(model,agent_step!,model_step!,sim,n=nsteps) 
    nothing 
end 

function step!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                sim::AbsFixedStepSim = DefaultFixedStepSim(); 
                n::Int=1) 

    for _ in 1:n

        prestep!(model,sim)
        
        apply_model_step!(model,pre_model_step!,sim)
        apply_agent_step!(model,agent_step!,sim)
        apply_model_step!(model,post_model_step!,sim)

    end
    
    nothing 
end

function run!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                sim::AbsFixedStepSim) 
    nsteps = prerun!(model,sim) 
    step!(model,pre_model_step!, agent_step!, post_model_step!,sim,n=nsteps)  
    nothing 
end 

function step!(model::AbstractABM,
                pre_model_steps::Vector{Function}, 
                agent_steps::Vector{Function}, 
                post_model_steps::Vector{Function},
                sim::AbsFixedStepSim = DefaultFixedStepSim(); 
                n::Int=1) 

    for _ in 1:n

        prestep!(model,sim)
        apply_model_step!(model,pre_model_steps,sim)
        apply_agent_step!(model,agent_steps,sim)
        apply_model_step!(model,post_model_steps,sim)

    end

    nothing 
end

function run!(model::AbstractABM,
                pre_model_steps::Vector{Function}, 
                agent_steps::Vector{Function}, 
                post_model_steps::Vector{Function},
                sim::AbsFixedStepSim) 
    nsteps =  prerun!(model,sim)
    step!(model,pre_model_steps, agent_steps, post_model_steps,sim,n=nsteps)
    nothing 
end 

# Other versions of the step! function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 

