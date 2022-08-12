"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    It specifies further functionalities needed (as a contract)
    for running an ABM simulation. (An imitation of Agents.jl) 
""" 

using  SomeUtil: read2DArray

export ABM, initial_connect!, attach2DData!

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties
    data::Dict{Symbol}       # data structure to be improved 

    #= TODO
    properties are from Agent
    it is good to have parameters, variables etc. (that could be struct or dictionaries?) 
    =#

    ABM{AgentType}(properties = Dict{Symbol,Any}(); 
        declare::Function = dict -> AgentType[]) where AgentType <: AbstractAgent = 
             new(declare(properties),deepcopy(properties),Dict{Symbol,Any}())
    
    #=         
    ABM{AgentType}(pars; 
        declare::Function = pars -> AgentType[]) where AgentType <: AbstractAgent = 
        new(declare(pars),copy(pars),Dict{Symbol,Any}())         
    =# 
    
    # ^^^ to add an argument for data with default value empty 

end # AgentBasedModel  

""
function attach2DData!(abm::ABM{AgentType}, symbol::Symbol, fname ) where AgentType 
    abm.data[symbol] = read2DArray(fname) 
end

 
"ensure symmetry"
initial_connect!(abm2::ABM{T2},
                 abm1::ABM{T1},
                 pars) where {T1 <: AbstractABM,T2 <: AbstractABM} = initial_connect!(abm1,abm2,pars)
