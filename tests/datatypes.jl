import Base.time

mutable struct Person <: AbstractXAgent 
    id::Int 
    pos 
    age::Rational{Int}
    income::Float64  
    Person(position,a::Rational{Int}) = new(getIDCOUNTER(),position,a,10000.0)
    Person(id,position,a::Rational{Int}) = new(id,position,a,10000.0)

end 

# List of persons 
function createInvalidPopulation!(pop::ABM{Person}) 

    person1 = Person(1,"Edinbrugh",46//1) 
    person2 = person1               
    person3 = Person(2,"Abderdeen",25 + 3 // 12) 
    person4 = Person(3,"Edinbrugh", 26 // 1) 
    person5 = Person(4,"Glasgow", 25 // 1)
    person6 = Person(5,"Edinbrugh", 29 + 5 // 12)

    add_agent!(pop,deepcopy(person1))
    add_agent!(pop,deepcopy(person2))
    add_agent!(pop,deepcopy(person3))
    add_agent!(pop,deepcopy(person4))
    add_agent!(deepcopy(person5),pop)
    add_agent!(deepcopy(person6),pop)      

    nothing 
end 


# List of persons 
function createPopulation!(pop::ABM{Person}) 

    person1 = Person(1,"Edinbrugh",46//1)             
    person3 = Person(2,"Abderdeen",25 + 3 // 12) 
    person4 = Person(3,"Edinbrugh", 26 // 1) 
    person5 = Person(4,"Glasgow", 25 // 1)
    person6 = Person(5,"Edinbrugh", 29 + 5 // 12)

    add_agent!(pop,person1)
    add_agent!(pop,person3)
    add_agent!(pop,person4)
    add_agent!(person5,pop)
    add_agent!(person6,pop)      

    nothing 
end 


mutable struct Stock <: AbstractXAgent
    id :: Int 
    pos :: Int  # Risk 
    quantity :: Int 
    price :: Float64
    function Stock(person::Person)
        pr = rand(10.0:100.0) 
        qu = trunc(Int, person.income / pr)    
        new(getIDCOUNTER(),rand(1:7),qu,pr) 
    end 
end

mutable struct Demography <: AbstractMABM

    pop :: ABM{Person}   # population 
    shares :: ABM{Stock} # stocks 

end 

function Demography()

    population = ABM{Person}(   parameters = nothing, 
                                variables = nothing) 
        
    createPopulation!(population)
    
    stocks = ABM{Stock}(t = time(population), 
                            parameters = nothing,
                            variables = nothing) 

    for person in allagents(population)
        stock = Stock(person) 
        add_agent!(stocks,stock)
        person.income -= stock.quantity * stock.price 
    end 

    Demography(population,stocks)
end  

allagents(demography::Demography) = allagents(demography.pop)
time(demography::Demography) = time(demography.pop)

