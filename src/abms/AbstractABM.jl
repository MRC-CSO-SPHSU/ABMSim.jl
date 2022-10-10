"""
Specification of an abstract ABM type as a supertype for all 
    (elementary) Agent based models. It resembles the ABM concept
    from Agents.jl
"""

using  MultiAgents.Util: removeFirst!
import Base.time 

export AbstractABM 
export allagents, nagents, time
export add_agent!, move_agent!, kill_agent!
export step!, dummystep, errorstep
export verifyAgentsJLContract


"Abstract ABM resembles the ABM concept from Agents.jl"
abstract type AbstractABM end 

"interface used by verifyAgentsJLContract functions"
# function allagents(::AbstractABM)::Vector{AgentType} where AgentType <: AbstractAgent end

"An AbstractABM subtype to have a list of agents"
allagents(model::AbstractABM) = model.agentsList

function verifyAgentsJLContract(model::AbstractABM)
    #= all ids are unique =# 
    agents = allagents(model)
    ids    = [ id for agent in agents for id = agent.id]
    length(ids) == length(Set(ids))
end

time(model::AbstractABM) = model.t

# The following part is to be seperated in an another file, to be excluded
# when agents.jl is used 
#========================================
Fields of an ABM
=########################################

#=
"get a symbol property from a model"
Base.getproperty(model::AbstractABM,property::Symbol) = 
    property ∈ fieldnames(typeof(model)) ?
        Base.getfield(model,property) : 
        Base.getindex(model.properties,property)

""
Base.setproperty!(model::AbstractABM,property::Symbol,val) = 
    property ∈ fieldnames(typeof(model)) ?
        Base.setfield!(model,property,val) : 
        model.properties[property] = val
=#

# equivalent to operator [], i.e. model[id] 
# Agents.jl is better since there is a hash linked list
"@return the id-th agent (Agents.jl)"
function Base.getindex(model::AbstractABM,id::Int64) 
    agents = allagents(model) 
    for agent in agents
        if agent.id == id 
            return agent
        end 
    end   
    error("index id in $model does not exist")
end 



#========================================
Functionalities for agents within an ABM
=########################################


"random seed of the model (Agents.jl)"
seed!(model::AbstractABM,seed) = error("not implemented") 

"numbe of  agents"
nagents(model::AbstractABM) = length(model.agentsList)
 

#= 
Couple of other useful functions may include:

randomagent(model) : a random agent 

randomagent(model,condition) : allagents 

function allids(model)    : iterator over ids

=# 

#========================================
Functionalities for agents within an ABM
=########################################

"add agent with its position to the model"
function add_agent!(agent::AbstractAgent,model::AbstractABM) # where T <: AbstractAgent
    push!(model.agentsList,agent)
end 

"symmetry"
add_agent!(model::AbstractABM,agent::AbstractAgent) = add_agent!(agent,model)

#=
"add agent to the model"
function add_agent!(agent,pos,model::AgentBasedModel) 
    nothing 
end
=# 

"to a given position (Agents.jl)" 
move_agent!(agent,pos,model::AbstractABM) =  error("not implemented")

"remove an agent"
kill_agent!(agent,model::AbstractABM) = removeFirst!(model.agentsList,agent)

"symmety"
kill_agent!(model::AbstractABM,agent) = kill_agent!(agent,model)

#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 

#===========================
General stepping functions / imitating Agents.jl 
=###########################

"dummy stepping function for arbitrary agents"
dummystep(::AbstractAgent,::AbstractABM) = nothing 
 
"default dummy model stepping function"
dummystep(::AbstractABM) = nothing 

"Default agent stepping function for reminding the client that it should be provided"
errorstep(::AbstractAgent,::AbstractABM) = error("agent stepping function has not been specified")

"Default model stepping function for reminding the client that it should be provided"
errorstep(::AbstractABM) = error("model stepping function has not been specified")


"""
Stepping function for a model of type AgentBasedModel with 
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
    agents_first : agent_step! executed first before model_step
"""
function step!(
    model::AbstractABM,
    agent_step!,
    n::Int=1
)
    for _ in 1:n 
        for agent in allagents(model)
            agent_step!(agent,model) 
        end
    end 
    nothing 
end


"""
Stepping function for a model of type AgentBasedModel with 
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
    agents_first : agent_step! executed first before model_step
"""
function step!(
    model::AbstractABM, 
    agent_step!,
    model_step!;  
    n::Int=1,
    agents_first::Bool=true 
)  
    
    for _ in 1:n 
        
        if agents_first 
            for agent in model.agentsList
                agent_step!(agent,model) 
            end
        end
    
        model_step!(model)
    
        if !agents_first
            for agent in model.agentsList
                agent_step!(agent,model)
            end
        end
    
    end
    nothing 
end # step! 


"""
Stepping function for a model of type AgentBasedModel with 
    pre_model_step!(modelObj::AgentBasedModel)
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
"""
function step!(
    model::AbstractABM,
    pre_model_step!, 
    agent_step!,
    post_model_step!;  
    n::Int=1,
)  
    
    for _ in 1:n
        
        pre_model_step!(model)
    
        for agent in model.agentsList
            agent_step!(agent,model)
        end
        
        post_model_step!(model)
    
    end
    nothing 
end # step! 

# Other versions of the step! function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 

"ensure symmetry when initializing ABMs via their declaration"
initial_connect!(abm2::T2,
                 abm1::T1,
                 pars) where {T1 <: AbstractABM,T2 <: AbstractABM} = initial_connect!(abm1,abm2,pars)

