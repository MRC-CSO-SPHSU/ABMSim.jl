"""
Specification of an abstract ABM type as a supertype for all
    (elementary) Agent based models. It resembles the ABM concept
    from Agents.jl
"""

import Random: seed!
using  ABMSim.Util: remove_first!, remove_first_opt!
import Agents: random_position, nearby_ids, add_agent_to_space!, remove_agent_from_space!,
    allagents, nagents, add_agent!, move_agent!, kill_agent!

export AbstractABM
export kill_agent_opt!, kill_agent_at!, kill_agent_at_opt!, add_agent!
export verify_majl

"Abstract ABM resembles the ABM concept from Agents.jl"
abstract type AbstractABM end

# Potential extensions of some agents.jl functions

random_position(::AbstractABM) = error("random_position not implemented")
nearby_ids(::Agents.AbstractSpace,::AbstractABM,r=1) = error("nearby_ids not implemented")
add_agent_to_space!(::AbstractXAgent,::AbstractABM) =
    error("add_agent_to_space! not implemented")
remove_agent_from_space!(::AbstractXAgent,::AbstractABM) =
    error("add_agent_to_space! not implemented")

"An AbstractABM subtype to have a list of agents"
allagents(model::AbstractABM) = model.agentsList

function verify_agentsjl(model::AbstractABM)
    #= all ids are unique =#
    agents = allagents(model)
    ids    = [ id for agent in agents for id = agent.id]
    return length(ids) == length(Set(ids))
end

verify_majl(model::AbstractABM) = error("to implement")

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
    return agents[0]
end

#========================================
Functionalities for agents within an ABM
=########################################

"random seed of the model (Agents.jl)"
seed!(model::AbstractABM,seed) =
    seed == 0 ? Random.seed!(floor(Int,time())) : seed!(seed)

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
add_agent!(agent,model::AbstractABM) = push!(allagents(model),agent)

"symmetry"
add_agent!(model::AbstractABM,agent) = add_agent!(agent,model)

#=
"add agent to the model"
function add_agent!(agent,pos,model::AgentBasedModel)
    nothing
end
=#

"to a given position (Agents.jl)"
move_agent!(agent,pos,model::AbstractABM) =  error("not implemented")

"remove an agent"
kill_agent!(agent,model::AbstractABM) = remove_first!(allagents(model),agent)

kill_agent_opt!(agent, model::AbstractABM) =
    remove_first_opt!(allagents(model), agent)

kill_agent!(id::Int, model::AbstractABM) = kill_agent!(model[id],model)

function kill_agent_at!(id::Int,model::AbstractABM)
    deleteat!(allagents(model),id)
    nothing
end

function kill_agent_at_opt!(id::Int,model::AbstractABM)
    agents = allagents(model)
    agents[id] = agents[length(agents)]
    # len = length(agents)
    # (agents[id], agents[len]) = (agents[len],agents[id])
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
