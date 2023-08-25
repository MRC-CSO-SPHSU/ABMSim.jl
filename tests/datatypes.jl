using ABMSim.Util: date2years_months, AbstractExample, DefaultExample
using ABMSim: AbstractXAgent, ABMPDV, SimpleABM, AbstractMABM
using ABMSim: getIDCOUNTER, add_agent!
using Random: seed!

mutable struct Person <: AbstractXAgent
    id::Int
    pos::String
    age::Rational{Int}
    income::Float64
    Person(position,a::Rational{Int}) = new(getIDCOUNTER(),position,a,10000.0)
    Person(id,position,a::Rational{Int}) = new(id,position,a,10000.0)
end

const PopulationABM = SimpleABM{Person}
const PopulationType = ABMPDV{Person,P,D,V} where {P,D,V}


# List of persons
function createInvalidPopulation!(pop)

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
function createPopulation!(pop)

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
        pr = (rand() + 1) * 10
        qu = trunc(Int, person.income / pr)
        new(person.id,rand(1:7),qu,pr)
    end
end

mutable struct Demography <: AbstractMABM

    pop :: PopulationABM   # population
    shares :: ABMPDV{Stock, Nothing, Nothing, Nothing} # stocks

end

function Demography()

    seed!(floor(Int,time()))

    population = PopulationABM()

    createPopulation!(population)

    stocks = ABMPDV{Stock,Nothing,Nothing,Nothing}()

    for person in allagents(population)
        stock = Stock(person)
        add_agent!(stocks,stock)
        person.income -= stock.quantity * stock.price
    end

    Demography(population,stocks)
end

mainabm(demography::Demography) = demography.pop

import ABMSim: allagents
allagents(demography::Demography) = allagents(mainabm(demography))
