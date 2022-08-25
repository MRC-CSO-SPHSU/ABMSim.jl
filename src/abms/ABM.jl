"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    It specifies further functionalities needed (as a contract)
    for running an ABM simulation. (An imitation of Agents.jl) 
""" 

using  SomeUtil: read2DArray

export ABM, initial_connect!, attach2DData!, initDefaultProp!
export defaultprestep!, defaultpoststep!
export currstep, stepnumber, dt, startTime, finishTime

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties               # model properties Agents.jl   
    data::Dict{Symbol}       # data structure to be improved 
    parameters               # model parameters ideally as a struct data type

    #= TODO
    properties are from Agents.jl
    it is good to have parameters, variables etc. (that could be struct or dictionaries?) 
    =#

    #= Deprecated to be removed 
    ABM{AgentType}(properties = Dict{Symbol,Any}(); 
        declare::Function = dict -> AgentType[]) where AgentType <: AbstractAgent = 
             new(declare(properties),deepcopy(properties),Dict{Symbol,Any}(),nothing)
    =# 
         
    ABM{AgentType}(pars = nothing; 
        declare::Function = pars -> AgentType[]) where AgentType <: AbstractAgent = 
        new(declare(pars),Dict{Symbol,Any}(),Dict{Symbol,Any}(),deepcopy(pars))         

    
    # ^^^ to add an argument for data with default value empty 

end # AgentBasedModel  

""
function attach2DData!(abm::ABM{AgentType}, symbol::Symbol, fname ) where AgentType 
    abm.data[symbol] = read2DArray(fname) 
    nothing 
end

currstep(abm)    = abm.properties[:currstep] 
dt(abm)          = abm.properties[:dt] 
stepnumber(abm)  = abm.properties[:stepnumber] 
startTime(abm)   = abm.properties[:startTime] 
finishTime(abm)  = abm.properties[:finishTime] 

# initDefaultProp!(abm::ABM{AgentType},properties::Dict{Symbol,Any}) = abm.properties = deepcopy(properties) 

"Initialize default properties"
function initDefaultProp!(abm::ABM{AgentType};
                          dt=0,stepnumber=0,
                          startTime=0, finishTime=0) where AgentType 
    abm.properties[:currstep]   = startTime 
    abm.properties[:dt]         = dt
    abm.properties[:stepnumber] = stepnumber 
    abm.properties[:startTime]  = startTime
    abm.properties[:finishTime] = finishTime
    nothing  
end 

"Default instructions before stepping an abm"
function defaultprestep!(abm::ABM{AgentType}) where AgentType 
    abm.stepnumber += 1 
    nothing 
end

"Default instructions after stepping an abm"
function defaultpoststep!(abm::ABM{AgentType}) where AgentType 
    abm.currstep   +=  dt(abm)
    nothing 
end


