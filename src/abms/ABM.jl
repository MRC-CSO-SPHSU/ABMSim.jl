"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl, but with extension. Later this would be 
    probably renamed , e.g. XABM  
""" 

export ABM

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"""
Agent based model specification for social simulations
    with data, parameters, time and variable fields 
"""
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Vector{AgentType}
    
    parameters              # model parameters ideally as a struct data type
    data                   
    variables                

    ABM(agents::Vector{AgentType},pars,da,vars)  where AgentType  = 
        new{AgentType}(agents,pars,da,vars) 

    ABM{AgentType}(agents::Vector{AgentType}; parameters=nothing, 
                                  data=nothing, variables=nothing) where AgentType =
        ABM(agents,parameters,data,variables)
     
    ABM{AgentType}(;parameters=nothing, 
                    data=nothing, variables=nothing,  
                    declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM(declare(parameters),parameters,data,variables) 

end # AgentBasedModel  


