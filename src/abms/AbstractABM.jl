"""
Specification of an abstract ABM type as a supertype for all 
    (elementary) Agent based models. It resembles the ABM concept
    from Agents.jl
"""

using  MultiAgents.Util: removeFirst!, removeFirstOpt!
import Random.seed!

export AbstractABM 
export allagents, nagents
export add_agent!, move_agent!, kill_agent!, kill_agent_opt!, 
        kill_agent_at!, kill_agent_at_opt!
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

verifyMAJLContract(model::AbstractABM) = error("to implement")

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
seed!(model::AbstractABM,seed) =
    seed == 0 ? seed!(floor(Int,time())) : seed!(seed)


"number of agents"
nagents(model::AbstractABM) = length(allagents(model))
 

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
    push!(allagents(model),agent)
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
kill_agent!(agent,model::AbstractABM) = removeFirst!(allagents(model),agent)

kill_agent_opt!(agent, model::AbstractABM) = 
    removeFirstOpt!(allagents(model), agent)

kill_agent!(id::Int, model::AbstractABM) = kill_agent!(model[id],model)

function kill_agent_at!(id::Int,model::AbstractABM)
    deleteat!(allagents(model),id) 
    nothing
end 

function kill_agent_at_opt!(id::Int,model::AbstractABM) 
    agents = allagents(model)
    agents[id] = agents[length(agents)] #(agents[id], agents[len]) = (agents[len],agents[id])
    pop!(agents) # deleteat!(agents,len)
    nothing 
end 


"symmety"
kill_agent!(model::AbstractABM,agent) = kill_agent!(agent,model)
kill_agent_opt!(model::AbstractABM,agent) = kill_agent_opt!(agent,model)

#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 

"ensure symmetry when initializing ABMs via their declaration"
initial_connect!(abm2::T2,
                 abm1::T1,
                 pars) where {T1 <: AbstractABM,T2 <: AbstractABM} = initial_connect!(abm1,abm2,pars)

