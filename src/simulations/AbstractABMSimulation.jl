
"""
    A concept for ABM simulation 
"""

using  MultiAgents.Util: AbstractExample, DummyExample 

export AbstractABMSimulation
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!, step!, run! 

# export defaultprestep!, defaultpoststep!

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbsFixedStepSim end
 
"""
    default setup the simulation stepping functions in the constructor 
    This guarantees that the client provides proper stepping functions 
    either by overloading this method or other explicit ways 
"""
setup!(sim::AbstractABMSimulation,::AbstractExample) = 
    error("setup! function for $(typeof(sim)) should be implemented")  

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

step!(model::AbstractABM;
    simulator::AbstractABMSimulation,
    example::AbstractExample = DefaultExample(),
    n::Int=1) = 
        step!(model,sim.pre_model_steps,sim.agent_steps,sim.post_model_steps,
                simulator=simulator,example=example,n=n)

run!(model::AbstractABM; 
        simulator::AbstractABMSimulation,
        example::AbstractExample = DefaultExample())   = 
    run!(model,sim.pre_model_steps,sim.agent_steps,sim.post_model_steps,
            simulator=simulator,example=example)

