class Person
    attr_reader :id
    attr_accessor :name, :age
    def initialize(name = "Unknown", age, parent_permission = true)
        @id = Random.rand(1..1000)
        @name = name
        @age = age
        @parent_permission = parent_permission
    end

    def can_use_services?
        @age >= 18 || @parent_permission === true
    end

    private

    def is_of_age?
        @age >= 18
    end

end