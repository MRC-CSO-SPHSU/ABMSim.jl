"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl, but with extension. Later this would be 
    probably renamed , e.g. XABM  
""" 

export ABMPV

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"""
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

    #=
    ABMPDV{A,P,D,V}(agents::Vector{A}; parameters=nothing, 
                              data=nothing, variables=nothing) where {A,P,D,V} =
        ABMPDV{A}(agents,parameters,data,variables)
     
    ABMPDV{A,P,D,V}(;parameters=nothing, 
                data=nothing, variables=nothing,  
                declare::Function = pars -> Vector{A}()) where {A,P,D,V}  = 
        ABMPDV{A,P,D,V}(declare(parameters),parameters,data,variables) 
    =# 
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


#=
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Vector{AgentType}
    
    parameters              # model parameters ideally as a struct data type
    data                   
    variables                

    ABM{AgentType}(agents::Vector{AgentType},pars,da,vars)  where AgentType  = 
        new{AgentType}(agents,pars,da,vars) 

    ABM{AgentType}(agents::Vector{AgentType}; parameters=nothing, 
                                  data=nothing, variables=nothing) where AgentType =
        ABM{AgentType}(agents,parameters,data,variables)
     
    ABM{AgentType}(;parameters=nothing, 
                    data=nothing, variables=nothing,  
                    declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM{AgentType}(declare(parameters),parameters,data,variables) 

end # AgentBasedModel  
=# 

