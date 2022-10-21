"""
Main specification of a Simulation type. 
"""

using Mixers 
using Parameters 
using Random

using MultiAgents.Util: date2YearsMonths, AbstractExample, DefaultExample

export dummystep, errorstep
export dt, startTime, finishTime, seed, verbose, yearly
export stepnumber, currstep

export AbstractSimulation, AbsFixedStepSim, FixedStepSim, DefaultFixedStepSim
export initFixedStepSim!, initFixedStepSimPars!

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
    verbose :: Bool   = false          # whether to print intermediate results 
    sleeptime :: Float64 = 0.0         # how long the exection sleeps when verbosing 
    checkassumption :: Bool = false    # whether assumptions are being examined during execution
    logfile  :: String = "log.tsv"
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
            simulator::AbsFixedStepSim=DefaultFixedStepSim(), 
            example::AbstractExample = DefaultExample()) = nothing 
                                         
"default dummy model stepping function"
dummystep(::AbstractABM,
            simulator::AbsFixedStepSim=DefaultFixedStepSim(),
            example::AbstractExample = DefaultExample()) = nothing 
                                        
"Default agent stepping function for reminding the client that it should be provided"
errorstep(::AbstractAgent,::AbstractABM,
            simulator::AbsFixedStepSim=DefaultFixedStepSim(),
            example::AbstractExample = DefaultExample()) = 
                error("agent stepping function has not been specified")
                                        
"Default model stepping function for reminding the client that it should be provided"
errorstep(::AbstractABM,
            simulator::AbsFixedStepSim=DefaultFixedStepSim(),
            example::AbstractExample = DefaultExample()) = 
                error("model stepping function has not been specified")
                                        

@mix @with_kw struct FixedStepPars 
    dt :: Rational{Int}     = 0 // 1  
    yearly :: Bool          = false   # doing some extra stuffs at the begining of every year
end 

@BasicPars @FixedStepPars mutable struct FixedStepSimPars end

function initFixedStepSimPars!(simPars::FixedStepSimPars,pars) 
    if !(fieldnames(typeof(pars)) ⊆ fieldnames(FixedStepSimPars))  
        throw(ArgumentError("$(fieldnames(typeof(pars))) has fields not present in $(fieldnames(FixedStepSimPars))")) 
    end
    for sym in fieldnames(typeof(pars))
        val = getproperty(pars,sym)
        setproperty!(simPars,sym,val)
    end
    nothing 
end
 
initFixedStepSim!(sim::AbsFixedStepSim,pars) = 
    initFixedStepSimPars!(sim.parameters,pars)

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
    
    function FixedStepSim(pars) 
        sim = new(FixedStepSimPars(),0)
        initFixedStepSim!(sim,pars)
        sim
    end 
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

function prestep!(model::AbstractABM,sim::AbsFixedStepSim) 
    verbose(sim) ? verboseStep(sim) : nothing 
    sim.stepnumber += 1
    nothing 
end 

prestep!(model::AbstractABM,::DefaultFixedStepSim) = nothing 

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
    if Random.GLOBAL_SEED != seed(sim) 
        seed(sim) == 0 ?  seed!(floor(Int, time())) : seed!(seed(sim))
    end 
    trunc(Int,(finishTime(sim) - currstep(sim)) / dt(sim)) 
end

function run!(model::AbstractABM,
                agent_step!, 
                simulator::AbsFixedStepSim = DefaultFixedStepSim(),
                example::AbstractExample = DefaultExample())
    nsteps = prerun!(model,sim)
    step!(model,agent_step!,simulator,example,n=nsteps) 
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

