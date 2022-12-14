"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl, but with extension. 
""" 

export ABMPV


"""
    SimpleABM{AgentType}

 Simple ABM type with only agents as fields    
""" 
struct SimpleABM{A <: AbstractAgent} <: AbstractABM
    agentsList::Vector{A}

    SimpleABM{A}() where A = new{A}(A[]) 
    SimpleABM{A}(agents) where A = new{A}(agents)
end 

"""
    ABMPDV{A,P,D,V} 

Agent based model specification for social simulations
    with data, parameters, time and variable fields 
"""
mutable struct ABMPDV{A <: AbstractAgent, P, D, V} <: AbstractABM
    agentsList::Vector{A}
    
    parameters :: P             # model parameters ideally as a struct data type
    data       :: D            
    variables  :: V               

    ABMPDV{A,P,D,V}(agents::Vector{A},pars::P,da::D,vars::V)  where {A,P,D,V}  = 
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



