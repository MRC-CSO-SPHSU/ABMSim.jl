
"""
    A concept for ABM simulation 
"""

using  MultiAgents.Util: AbstractExample, DummyExample 

export AbstractABMSimulation
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!, step!, run! 

export defaultprestep!, defaultpoststep!

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbsFixedStepSim end
 
"""
    default setup the simulation stepping functions in the constructor 
    This guarantees that the client provides proper stepping functions 
    either by overloading this method or other explicit ways 
"""
setup!(sim::AbstractABMSimulation,::AbstractExample) = 
    error("setup! function for $(typeof(sim)) should be implemented")  
    # nothing     

#=  TODO update with sim.parameters 
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

=# 

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

"""
Step an ABM given a set of independent stepping functions
    pre_model_steps[:](modelObj::AgentBasedModel,simObj::SimulationType)
    agent_steps[:](agentObj,modelObj::AgentBasedModel,simObj::SimulationType) 
    model_step[:](modelObj::AgentBasedModel,simObj::SimulationType)
    n::number of steps 
"""
function step!(model::AbstractABM,sim::AbstractABMSimulation, n::Int=1) 

    for _ in 1:n 
 
        sim.parameters.verbose ? verboseStep(sim) : nothing 

        for k in 1:length(sim.pre_model_steps)
            sim.pre_model_steps[k](model,sim)
        end
 
        for agent in allagents(model)
            for k in 1:length(agent_steps)
                sim.agent_steps[k](agent,model,sim)
            end 
        end
                                
        for k in 1:length(post_model_steps)
            sim.post_model_steps[k](model,sim)
        end
                        
    end # for _ 

    nothing 
end # step! 

"Default instructions before stepping an abm"
function defaultpoststep!(abm::AbstractABM,sim::AbstractABMSimulation)  
    sim.stepnumber += 1 
    nothing 
end

"Default instructions after stepping an abm"
function defaultprestep!(abm::AbstractABM,sim::AbstractABMSimulation)  
    sim.currstep   +=  dt(sim)
    nothing 
end
 