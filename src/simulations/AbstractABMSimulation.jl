
"""
    A concept for ABM simulation 
"""

using  SomeUtil:    AbstractExample, DummyExample 

export AbstractABMSimulation
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!, step!, run! 

export defaultprestep!, defaultpoststep!

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbstractSimulation end 

"""
    default setup the simulation stepping functions in the constructor 
    This guarantees that the client provides proper stepping functions 
    either by overloading this method or other explicit ways 
"""
setup!(::AbstractABMSimulation,::AbstractExample) = nothing  


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

"Default instructions before stepping an abm"
function defaultprestep!(abm::ABM{AgentType},sim::AbstractSimulation) where AgentType 
    sim.properties[:stepnumber] += 1 
    nothing 
end

"Default instructions after stepping an abm"
function defaultpoststep!(abm::ABM{AgentType},sim::AbstractSimulation) where AgentType 
    sim.properties[:currstep]   +=  dt(sim)
    nothing 
end




# Other versions of the above function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 

#===
Stepping and simulation run function 
===# 

step!(
    simulation::DefaultSimulation, 
    model,
    agent_step!,
    model_step!,  
    n::Int=1,
    agents_first::Bool=true 
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


function verboseStep(simulation_step::Rational,yearly=true) 
    (year,month) = date2yearsmonths(simulation_step) 
    yearly && month == 0 ? println("conducting simulation step year $(year)") : nothing 
    yearly               ? nothing : println("conducting simulation step year $(year) month $(month+1)")
end

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              agent_step!,
              model_step!;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,agent_step!,model_step!)
    end 

end 
 

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              pre_model_step!, 
              agent_step!,
              post_model_step!;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,pre_model_step!,agent_step!,post_model_step!)
    end 

end 
 
"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              pre_model_steps::Vector{Function}, 
              agent_steps,
              post_model_steps;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,pre_model_steps,agent_steps,post_model_steps)
    end 

end 
 

"""
Step an ABM given a set of independent stepping functions
    pre_model_steps[:](modelObj::AgentBasedModel)
    agent_steps[:](agentObj,modelObj::AgentBasedModel) 
    model_step[:](modelObj::AgentBasedModel)
    n::number of steps 
"""
function step!(
    sim::AbstractABMSimulation,
    model::AbstractABM,
    pre_model_steps::Vector{Function}, 
    agent_steps::Vector{Function},
    post_model_steps::Vector{Function},  
    n::Int=1
)  
    
    for i in range(1,n)
        
        for k in 1:length(pre_model_steps)
            pre_model_steps[k](model,sim)
        end
    
        for agent in model.agentsList
            for k in 1:length(agent_steps)
                agent_steps[k](agent,model,sim)
            end 
        end
        
        for k in 1:length(post_model_steps)
            post_model_steps[k](model,sim)
        end
    
    end

end # step! 


