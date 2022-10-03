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
    
    time :: Rational{Int} 
    parameters              # model parameters ideally as a struct data type
    data                    # data structure to be improved 
    variables               # model properties Agents.jl   
    
    ABM(agents::Vector{AgentType},time,pars,da,vars)  where AgentType  = 
        new{AgentType}(agents,time,pars,da,vars) 

    ABM{AgentType}(;time=0//1, parameters=nothing, 
                    data=nothing, variables=nothing,  
                    declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM(declare(parameters),time,parameters,data,variables)
    
end # AgentBasedModel  



