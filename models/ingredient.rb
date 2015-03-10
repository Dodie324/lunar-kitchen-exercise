class Ingredient
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def summary
    "#{@name}"
  end

end

