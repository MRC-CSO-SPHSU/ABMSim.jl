
"""
    A concept for ABM simulation 
"""

using  SomeUtil:    AbstractExample, DummyExample 

export AbstractABMSimulation
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!, step!, run! 

export initDefaultProp!
export defaultprestep!, defaultpoststep!
export currstep, stepnumber, dt, startTime, finishTime

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbstractSimulation end 

"""
    default setup the simulation stepping functions in the constructor 
    This guarantees that the client provides proper stepping functions 
    either by overloading this method or other explicit ways 
"""
setup!(::AbstractABMSimulation,::AbstractExample) = nothing  

"get a symbol property from a Simulation"
Base.getproperty(sim::AbstractABMSimulation,property::Symbol) = 
    property ∈ fieldnames(typeof(sim)) ?
        Base.getfield(sim,property) : 
        Base.getindex(sim.properties,property)

""
Base.setproperty!(sim::AbstractABMSimulation,property::Symbol,val) = 
    property ∈ fieldnames(typeof(sim)) ?
        Base.setfield!(sim,property,val) : 
        sim.properties[property] = val


# attaching a stepping function is done via a function call, 
# since data structure is subject to change, e.g. Vector{Function}

"attach an agent step function to the simulation"
function attach_agent_step!(simulation::AbstractABMSimulation,
                            agent_step::Function) 
    push!(simulation.agent_steps,agent_step)             
    nothing           
end  

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_pre_model_step!(simulation::AbstractABMSimulation,
                                model_step::Function) 
    # simulation.pre_model_step = model_step 
    push!(simulation.pre_model_steps,model_step) 
    nothing
end 

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_post_model_step!(simulation::AbstractABMSimulation,
                                 model_step::Function) 
    push!(simulation.post_model_steps,model_step)  
    nothing
end 

"step a simulation"
step!(simulation::AbstractABMSimulation,
      n::Int=1) = step!(simulation,
                        simulation.pre_model_steps, 
                        simulation.agent_steps,
                        simulation.post_model_steps,
                        n)

"Run a simulation of an ABM"
run!(simulation::AbstractABMSimulation) = 
                run!(simulation, 
                     simulation.pre_model_steps,
                     simulation.agent_steps,
                     simulation.post_model_steps)


currstep(sim)    = sim.properties[:currstep] 
dt(sim))         = sim.properties[:dt] 
stepnumber(sim)  = sim.properties[:stepnumber] 
startTime(sim)   = sim.properties[:startTime] 
finishTime(sim)  = sim.properties[:finishTime] 

# initDefaultProp!(abm::ABM{AgentType},properties::Dict{Symbol,Any}) = abm.properties = deepcopy(properties) 

"Initialize default properties"
function initDefaultProp!(sim::AbstractSimulation;
                          dt=0,stepnumber=0,
                          startTime=0, finishTime=0) 
    sim.properties[:currstep]   = Rational{Int}(startTime) 
    sim.properties[:dt]         = dt
    sim.properties[:stepnumber] = stepnumber 
    sim.properties[:startTime]  = startTime
    sim.properties[:finishTime] = finishTime
    nothing  
end 

"Default instructions before stepping an abm"
function defaultprestep!(abm::ABM{AgentType},sim::AbstractSimulation) where AgentType 
    sim.properties[:stepnumber] += 1 
    nothing 
end

"Default instructions after stepping an abm"
function defaultpoststep!(abm::ABM{AgentType),sim::AbstractSimulation) where AgentType 
    sim.properties[:currstep]   +=  dt(sim)
    nothing 
end

