"""
    An Agent Based Model concept based on AbstractAgent type
    similar to Agents.jl, but with extension.
"""

export ABMPV, SimpleABM, SimpleABMS

const SpaceType = Union{Agents.AbstractSpace,Nothing}

"""
    SimpleABMS{AgentType,SpaceType}

 Simple ABM type with only agents as fields
"""
struct SimpleABMS{A <: AbstractAgent, S <: SpaceType} <: AbstractABM
    agentsList::Vector{A}
    space::S
    SimpleABMS{A}() where A = new{A,Nothing}(A[])
    SimpleABMS{A}(agents) where A = new{A,Nothing}(agents)
    SimpleABMS{A,S}(agents,s) where {A,S} = new{A,S}(agents,s)
    SimpleABMS{A,S}(s::S) where {A,S} = new{A,S}(A[],s)
end

const SimpleABM{A}  = SimpleABMS{A}

"""
    ABMPDV{A,P,D,V}

Agent based model specification for social simulations
    with data, parameters and variable fields
"""
mutable struct ABMPDV{A <: AbstractAgent, P, D, V} <: AbstractABM
    agentsList::Vector{A}

    parameters :: P             # model parameters ideally as a struct data type
    data       :: D
    variables  :: V

    ABMPDV{A,P,D,V}(agents,pars,da,vars)  where {A,P,D,V}  =
        new{A,P,D,V}(agents,pars,da,vars)

end # AgentBasedModel


# special cases

ABMPDV{A,Nothing,Nothing,Nothing}() where A =
    ABMPDV{A,Nothing,Nothing,Nothing}(A[],nothing,nothing,nothing)

ABMPDV{A,Nothing,Nothing,Nothing}(agents::Vector{A}) where A =
    ABMPDV{A,Nothing,Nothing,Nothing}(agents,nothing,nothing,nothing)

ABMPDV{A,Nothing,Nothing,V}(v::V) where {A,V} =
    ABMPDV{A,Nothing,Nothing,V}(A[],nothing,nothing,v)

ABMPDV{A,P,Nothing,V}(p::P,v::V) where {A,P,V} =
    ABMPDV{A,P,Nothing,V}(A[],p,nothing,v)
