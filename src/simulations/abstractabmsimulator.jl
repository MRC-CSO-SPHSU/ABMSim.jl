
"""
    A concept for ABM simulation
"""

using  MultiAgents.Util: AbstractExample, DummyExample

import Agents: step!, run!

export AbstractABMSimulator
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!

# export defaultprestep!, defaultpoststep!

"Abstract type for ABMs"
abstract type AbstractABMSimulator <: AbsFixedStepSim end

"""
    default setup the simulation stepping functions in the constructor
    This guarantees that the client provides proper stepping functions
    either by overloading this method or other explicit ways
"""
setup!(sim::AbstractABMSimulator,::AbstractExample) =
    error("setup! function for $(typeof(sim)) should be implemented")

#=  TODO update with sim.parameters
"get a symbol property from a Simulator"
Base.getproperty(sim::AbstractABMSimulator,property::Symbol) =
    property ∈ fieldnames(typeof(sim)) ?
        Base.getfield(sim,property) :
        Base.getindex(sim.properties,property)

""
Base.setproperty!(sim::AbstractABMSimulator,property::Symbol,val) =
    property ∈ fieldnames(typeof(sim)) ?
        Base.setfield!(sim,property,val) :
        sim.properties[property] = val

=#


"attach an agent step function to the simulation"
function attach_agent_step!(simulation::AbstractABMSimulator,
                            agent_step::Function)
    push!(simulation.agent_steps,agent_step)
    nothing
end

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_pre_model_step!(simulation::AbstractABMSimulator,
                                model_step::Function)
    # simulation.pre_model_step = model_step
    push!(simulation.pre_model_steps,model_step)
    nothing
end

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_post_model_step!(simulation::AbstractABMSimulator,
                                 model_step::Function)
    push!(simulation.post_model_steps,model_step)
    nothing
end

step!(model::AbstractABM,
    simulator::AbstractABMSimulator,
    example::AbstractExample = DefaultExample();
    n::Int=1) =
        step!(model,simulator.pre_model_steps,
                    simulator.agent_steps,
                    simulator.post_model_steps,
                simulator,
                example,n=n)

run!(model::AbstractABM,
        simulator::AbstractABMSimulator,
        example::AbstractExample = DefaultExample())   =
    run!(model,simulator.pre_model_steps,
               simulator.agent_steps,
               simulator.post_model_steps,
            simulator,
            example)
