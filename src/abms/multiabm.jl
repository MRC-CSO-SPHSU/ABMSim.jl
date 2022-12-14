"""
    A concept for multi ABMs for orchestering a set of 
        elemantary ABMs.

    This is intended to be just a demonstration of implementing a MABM. 
""" 

export AbstractMABM
export verify_majl

abstract type AbstractMABM  <: AbstractABM end   

#= 
A MutliABM looks similar to the following, though not recommned
due to the non-crete type abms field.
Instread the individual abms could be explicitly declared 
"A MultiABM concept" 
mutable struct MultiABM   <: AbstractMABM 
    abms::Vector{AbstractABM} 
    """
    Cor expecting a declaration function that declares 
        a list of elemantary ABMs together with
        MABM-level properties  
    """  
    function MultiABM(pars; 
                        declare::Function,
                        initialize::Function = dummyinit) 
        mabm = new(declare(pars))
        initialize(mabm) 
        mabm
    end 

end # MultiABM  
=# 

allabms(model::AbstractMABM)::Vector{AbstractABM} = error("should be implemented")

# an implementation: find out all fields of type AbstractABM and extract allagents 
allagents(model::AbstractMABM) = error("should be implemented") 

function verify_agentsjl(model::AbstractMABM) 
    for abm in allabms(model) 
        if !verify_agentsjl(abm) return false end 
    end
    return true 
end  

verify_majl(model::AbstractMABM) = error("to implement")

move_agent!(agent,pos,model::AbstractMABM) = error("not implemented") 
