"""
Specification of an abstract agent supertype

The idea is to add an additional layer of absraction that distinguishes
declared agents from the library Agents.jl to the sophisticated agents
we want to employ for sophisticated socio-econmic ABMs. This is to allow
extension of Agents.jl (without modifying it)

AbstractAgent could be replaced by using Agents.jl in case Agents.jl will turn
to be directly usable
"""

using Agents: AbstractAgent

export AbstractXAgent
export verify_agentsjl, getIDCOUNTER, finalize, resetIDCOUNTER

"The ID assigned to an agent for every new agent"
global IDCOUNTER = 0::Int              # This is differnt than agents.jl

"A counter for assigning unique ID for each agent"
getIDCOUNTER() = global IDCOUNTER = IDCOUNTER + 1

"reset counter to 0"
resetIDCOUNTER() = global IDCOUNTER = 0

#"Supertype of any Agent type"
#abstract type AbstractAgent end        # to be replaceable by > using Agents.jl

"Verify the requirements of abstract agent type"
verify_agentsjl(a::AbstractAgent) = verify_agentsjl(typeof(a))

"verify that a data type follows AbstractAgent contract"
verify_agentsjl(agentType::DataType) =
    agentType <: AbstractAgent &&
    :id in fieldnames(agentType) &&
    :pos in fieldnames(agentType)


"""
Specific abstract type for the type of agent exampels to be modelled using this package
X implies that a name of this type of agents is still not determined
"""
abstract type AbstractXAgent <: AbstractAgent end

#=

Possible extensions could realize the following

# A contract for any agent subtype:
function addVariable!(agent::AbstractXAgent,var::Symbol,initValue)  end
function addParameter!(agent::AbstractXAgent,par::Symbol,val)  end
function addConstant!(agent::AbstractXAgent,cst::Symbol,val)  end
function deleteVariable!(agent::AbstractXAgent,var::Symbol)  end

=#
