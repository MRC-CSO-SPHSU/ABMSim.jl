"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    It specifies further functionalities needed (as a contract)
    for running an ABM simulation. (An imitation of Agents.jl) 
""" 

export ABM

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Vector{AgentType}
    
    # time :: Rational{Int} 
    
    parameters               # model parameters ideally as a struct data type
    data                     # data structure to be improved 
    properties               # model properties Agents.jl   
    
    ABM(agents::Vector{AgentType},pars,da)  where AgentType  = 
        new{AgentType}(agents,deepcopy(pars),da,nothing) 

    ABM{AgentType}(pars=nothing,da=nothing; 
        declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM(declare(pars),pars,da)
    
end # AgentBasedModel  



