"""
Main specification of a Simulator type.
"""

using Mixers
using Parameters
using Random

using ABMSim.Util: date2years_months, AbstractExample, DefaultExample

import Agents: dummystep
export dt, starttime, finishtime, seed, verbose, yearly
export errorstep, stepnumber, currstep
export verify_majl

export AbstractSimulator, AbsFixedStepSim, FixedStepSim, FixedStepSimP, DefaultFixedStepSim
export init_parameters!

abstract type AbstractSimulator end

starttime(sim::AbstractSimulator)  = starttime(sim.parameters)
finishtime(sim::AbstractSimulator) = finishtime(sim.parameters)
seed(sim::AbstractSimulator)       = seed(sim.parameters)
verbose(sim::AbstractSimulator)    = verbose(sim.parameters)

@mix @with_kw struct BasicPars
    seed :: Int       = 0
    starttime :: Rational{Int}  = 0
    finishtime :: Rational{Int} = 0
    verbose :: Bool   = false          # whether to print intermediate results
    sleeptime :: Float64 = 0.0         # how long the exection sleeps when verbosing
    checkassumption :: Bool = false    # whether assumptions are being examined during execution
    logfile  :: String = "log.tsv"
end # BasicPars

@BasicPars mutable struct SimPars end

starttime(parameters) = parameters.starttime
finishtime(parameters) = parameters.finishtime
seed(parameters) = hasfield(typeof(parameters),:seed) ? parameters.seed : 0
verbose(parameters) = hasfield(typeof(parameters),:verbose) && parameters.verbose

"Initialize default properties"
function _init_parameters!(sim, starttime, finishtime, seed=0, verbose=false)

    if(hasfield(typeof(sim.parameters),:seed))
        sim.parameters.seed       = seed
    end
    sim.parameters.starttime  = starttime
    sim.parameters.finishtime = finishtime
    if(hasfield(typeof(sim.parameters),:verbose))
        sim.parameters.verbose    = verbose
    end
    # sim.time = Rational{Int}(starttime)

    nothing
end

"Initialize default properties"
init_parameters!(sim::AbstractSimulator;
                            starttime,
                            finishtime,
                            seed=0,
                            verbose=false) =
    _init_parameters(sim,starttime,finishtime,seed,verbose)


abstract type AbsFixedStepSim <: AbstractSimulator end

dt(sim::AbsFixedStepSim)            = dt(sim.parameters)
yearly(sim::AbsFixedStepSim)        = yearly(sim.parameters)
stepnumber(sim::AbsFixedStepSim)    = sim.stepnumber
currstep(sim::AbsFixedStepSim)      = stepnumber(sim) * dt(sim) + starttime(sim)
function verify_majl(sim::AbsFixedStepSim)
    try
        dt(sim)
        currstep(sim)
        stepnumber(sim)
        # Other parameter fields used within MA.jl
    catch e
        println(e)
        return false
    end
    return true
end

# for simulations agents.jl-way
# Just as a trait, since the above accessory functions are not needed
struct DefaultFixedStepSim <: AbsFixedStepSim end

"dummy stepping function for arbitrary agents"
dummystep(::AbstractAgent,
            ::AbstractABM,
            ::AbsFixedStepSim = DefaultFixedStepSim(),
            ::AbstractExample = DefaultExample()) = nothing

"default dummy model stepping function"
dummystep(::AbstractABM,
            ::AbsFixedStepSim = DefaultFixedStepSim(),
            ::AbstractExample = DefaultExample()) = nothing

"Default agent stepping function for reminding the client that it should be provided"
errorstep(::AbstractAgent,
            ::AbstractABM,
            ::AbsFixedStepSim=DefaultFixedStepSim(),
            ::AbstractExample = DefaultExample()) =
                error("agent stepping function has not been specified")

"Default model stepping function for reminding the client that it should be provided"
errorstep(::AbstractABM,
            ::AbsFixedStepSim = DefaultFixedStepSim(),
            ::AbstractExample = DefaultExample()) =
                error("model stepping function has not been specified")

@mix @with_kw struct FixedStepPars
    dt :: Rational{Int}     = 0 // 1
    yearly :: Bool          = false   # doing some extra stuffs at the begining of every year
end

@BasicPars @FixedStepPars mutable struct FixedStepSimPars end

dt(parameters) = parameters.dt
yearly(parameters) = hasfield(typeof(parameters),:yearly) && parameters.yearly

function init_parameters!(simPars::FixedStepSimPars,pars)
    if !(fieldnames(typeof(pars)) ⊆ fieldnames(FixedStepSimPars))
        #throw(ArgumentError("$(fieldnames(typeof(pars))) has fields not present in $(fieldnames(FixedStepSimPars))"))
        @warn "$(fieldnames(typeof(pars))) has fields not present in $(fieldnames(FixedStepSimPars))"
    end
    for sym in fieldnames(typeof(pars))
        # @info "$sym and $(hasfield(FixedStepSimPars,sym))"
        if(hasfield(FixedStepSimPars,sym))
            val = getproperty(pars,sym)
            setproperty!(simPars,sym,val)
        end
    end
    nothing
end

init_parameters!(sim::AbsFixedStepSim,pars) = init_parameters!(sim.parameters,pars)

function init_parameters!(sim::AbsFixedStepSim;
                                dt, starttime, finishtime,
                                seed=0, verbose=false, yearly=false)
    _init_parameters!(sim, starttime, finishtime, seed, verbose)
    sim.parameters.dt       = dt
    if hasfield(typeof(sim.parameters),:yearly)
        sim.parameters.yearly   = yearly
    end
    sim.stepnumber          = 0
    nothing
end

mutable struct FixedStepSimP{SimParType} <: AbsFixedStepSim
    parameters::SimParType
    stepnumber::Int

    function FixedStepSimP{SimParType}(simpar::SimParType) where SimParType
        sim = new(simpar,0)
        verify_majl(sim)
        sim
    end
end

const FixedStepSim = FixedStepSimP{FixedStepSimPars}

FixedStepSim(;dt,starttime,finishtime,seed=0,verbose=false,yearly=false) =
    FixedStepSim( FixedStepSimPars( dt=dt,
                            starttime = starttime, finishtime = finishtime,
                            seed = seed , verbose = verbose, yearly = yearly ))

function verboseStep(sim::AbsFixedStepSim)
    (year,month) = date2years_months(currstep(sim))
    iteryear = "########################################"
    yearly(sim) && month == 0   ?
        println("$(iteryear)\n simulation step year $(year) \n$(iteryear)") : nothing
    itermonth = "========================================================="
    yearly(sim) ?
        nothing :
        println("$(itermonth)\n simulation step year $(year) month $(month+1) \n$(itermonth)")
    nothing
end

function verboseStep(var,msg::String,sim::AbsFixedStepSim)
    if verbose(sim)
        if yearly(sim)
            curryear,currmonth = date2_yearsmonths(currstep(sim))
            currmonth == 0 ? println("$msg : $var") : nothing
        else
            println("$msg : $var")
        end
    end
    nothing
end

function prestep!(model::AbstractABM,sim::AbsFixedStepSim)
    verbose(sim) ? verboseStep(sim) : nothing
    sim.stepnumber += 1
    nothing
end

prestep!(model::AbstractABM,::DefaultFixedStepSim) = nothing

# todo : function argument to be first

function apply_agent_step!(model,
                            agent_step!::Function,
                            ::DefaultFixedStepSim,
                            ::DefaultExample)
    for agent in allagents(model)
        agent_step!(agent,model)
    end
    nothing
end

function apply_agent_step!(model,
                            agent_step!::Function,
                            sim::AbsFixedStepSim,
                            ::DefaultExample)
    for agent in allagents(model)
        agent_step!(agent,model,sim)
    end
    nothing
end

function apply_agent_step!(model,
                            agent_step!::Function,
                            sim::AbsFixedStepSim,
                            ex::AbstractExample)
    for agent in allagents(model)
        agent_step!(agent,model,sim,ex)
    end
    nothing
end

apply_agent_step!(model,
                    agent_steps::Vector{Function},
                    sim::AbsFixedStepSim,
                    ex::AbstractExample) =
    for k in 1:length(agent_steps)
        apply_agent_step!(model,agent_steps[k],sim,ex)
    end

apply_model_step!(model,model_step!::Function,
                    ::DefaultFixedStepSim,::DefaultExample) = model_step!(model)

apply_model_step!(model,model_step!::Function,
                    sim::AbsFixedStepSim,
                    ::DefaultExample) = model_step!(model,sim)

apply_model_step!(model,model_step!::Function,sim::AbsFixedStepSim,ex::AbstractExample) =
                    model_step!(model,sim,ex)

apply_model_step!(model,
                    model_steps::Vector{Function},
                    sim::AbsFixedStepSim,
                    ex::AbstractExample) =
    for k in 1:length(model_steps)
        apply_model_step!(model,model_steps[k],sim,ex)
    end


"""
Stepping function for a model of type AgentBasedModel with
    agent_step!(agentObj,modelObj::AgentBasedModel)
    model_step!(modelObj::AgentBasedModel)
    n::number of steps
    agents_first : agent_step! executed first before model_step
"""
function step!(model::AbstractABM,
                agent_step!,
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample();
                n::Int=1)

    for _ in 1:n
        prestep!(model,simulator)
        apply_agent_step!(model,agent_step!,simulator,example)
    end

    nothing
end

function prerun!(model,sim)::Int
    if hasfield(typeof(sim.parameters),:seed) && Random.GLOBAL_SEED != seed(sim)
        seed(sim) == 0 ?  seed!(floor(Int, time())) : seed!(seed(sim))
    end
    return trunc(Int,(finishtime(sim) - currstep(sim)) / dt(sim))
end

function run!(model::AbstractABM,
                agent_step!,
                sim::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample())
    nsteps = prerun!(model,sim)
    step!(model,agent_step!,sim,example,n=nsteps)
    nothing
end


function step!(model::AbstractABM,
                agent_step!,
                model_step!,
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample();
                n::Int=1,
                agents_first::Bool=true )

    for _ in 1:n

        prestep!(model,simulator)

        if agents_first
            apply_agent_step!(model,agent_step!,simulator,example)
        end

        apply_model_step!(model,model_step!,simulator,example)

        if !agents_first
            apply_agent_step!(model,agent_step!,simulator,example)
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
              simulator::AbsFixedStepSim = DefaultFixedStepSim(),
              example::AbstractExample = DefaultExample())
    nsteps = prerun!(model,simulator)
    step!(model,agent_step!,model_step!,simulator,example,n=nsteps)
    nothing
end

function step!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample();
                n::Int=1)

    for _ in 1:n

        prestep!(model,simulator)

        apply_model_step!(model,pre_model_step!,simulator,example)
        apply_agent_step!(model,agent_step!,simulator,example)
        apply_model_step!(model,post_model_step!,simulator,example)

    end

    nothing
end

function run!(model::AbstractABM,
                pre_model_step!, agent_step!, post_model_step!,
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample())
    nsteps = prerun!(model,simulator)
    step!(model,pre_model_step!, agent_step!, post_model_step!,
            simulator,example,n=nsteps)
    nothing
end

function step!(model::AbstractABM,
                pre_model_steps::Vector{Function},
                agent_steps::Vector{Function},
                post_model_steps::Vector{Function},
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample(),
                n::Int=1)

    for _ in 1:n

        prestep!(model,simulator)
        apply_model_step!(model,pre_model_steps,simulator,example)
        apply_agent_step!(model,agent_steps,simulator,example)
        apply_model_step!(model,post_model_steps,simulator,example)

    end

    nothing
end

function run!(model::AbstractABM,
                pre_model_steps::Vector{Function},
                agent_steps::Vector{Function},
                post_model_steps::Vector{Function},
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample())
    nsteps =  prerun!(model,simulator)
    step!(model,pre_model_steps, agent_steps, post_model_steps,
            simulator, example, n=nsteps)
    nothing
end

# Other versions of the step! function
#    model_step! is omitted
#    n(model,s)::Function
#    agent_step! function can be a dummystep
