"""
    A set of spaces on which common agents 
    and ABMs are operating. 

    Subject to progress in future to cope with Agents.jl
""" 
module Spaces 



    struct GridSpace 
        gridDimension::NTuple{D,Int} where D  
    end 
 
end # Spaces 