"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl, but with extension. Later this would be 
    probably renamed , e.g. XABM  
""" 

export ABM

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Vector{AgentType}
    
    t :: Rational{Int}      # time 
    parameters              # model parameters ideally as a struct data type
    data                   
    variables                

    ABM(agents::Vector{AgentType},t,pars,da,vars)  where AgentType  = 
        new{AgentType}(agents,t,pars,da,vars) 

    ABM{AgentType}(;t=0//1, parameters=nothing, 
                    data=nothing, variables=nothing,  
                    declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM(declare(parameters),t,parameters,data,variables)
    
end # AgentBasedModel  



