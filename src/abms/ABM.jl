"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    It specifies further functionalities needed (as a contract)
    for running an ABM simulation. (An imitation of Agents.jl) 
""" 

export ABM, initial_connect!, initDefaultProp!
export defaultprestep!, defaultpoststep!
export currstep, stepnumber, dt, startTime, finishTime

# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Vector{AgentType}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    parameters               # model parameters ideally as a struct data type
    data                     # data structure to be improved 
    properties               # model properties Agents.jl   
    
    ABM(agents::Vector{AgentType},pars,da)  where AgentType  = 
        new{AgentType}(agents,deepcopy(pars),da,Dict{Symbol,Any}()) 

    ABM{AgentType}(pars=nothing,da=nothing; 
        declare::Function = pars -> Vector{AgentType}()) where AgentType  = 
        ABM(declare(pars),pars,da)
    
end # AgentBasedModel  

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
    abm.properties[:currstep]   = Rational{Int}(startTime) 
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


