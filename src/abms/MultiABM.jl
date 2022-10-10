"""
    A concept for multi ABMs for orchestering a set of 
        elemantary ABMs.

    This is intended to be just a demonstration of implementing a MABM. 
""" 

export AbstractMABM, MultiABM 
export dummyinit

abstract type AbstractMABM  <: AbstractABM end   

allabms(model::AbstractMABM)::Vector{AbstractABM} = error("not implemented")

# an implementation: find out all fields of type AbstractABM and extract allagents 
allagents(model::AbstractMABM)::Vector{AbstractAgent} = error("not implemented") 

function verifyAgentsJLContract(model::AbstractMABM) 
    for abm in allabms(model) 
        if !verifyAgentsJLContract(abm) return false end 
    end
    true 
end  

Base.getindex(model::AbstractMABM,id::Int) = error("not implemented") 

nagents(model::AbstractMABM) = error("not implemented") 

add_agent!(agent, model::AbstractMABM) = error("meaningless") 

move_agent!(agent,pos,model::AbstractMABM) = error("not implemented") 

kill_agent!(agent,model::AbstractMABM) = error("not implemented") 



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