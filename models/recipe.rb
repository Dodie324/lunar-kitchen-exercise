require 'pry'

class Recipe
  attr_reader :id, :name, :description, :instructions, :ingredients
  def initialize(id, name, description = '', instructions = '', ingredients = [])
    @id = id
    @name = name
    @description = description
    @instructions = instructions
    @ingredients = ingredients
  end


  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end


  def self.all
    list_recipes = []
    sql = "SELECT name, id FROM recipes"
    recipes = db_connection { |conn| conn.exec(sql) }

    recipes.each do |recipe|
      list_recipes << Recipe.new(recipe["id"].to_i, recipe["name"])
    end

    list_recipes
  end

  def self.find(recipe_id)
    recipe_results = db_connection do |conn|
      conn.exec(
        "SELECT *
         FROM recipes
         WHERE recipes.id = #{recipe_id}" )
    end

    ingredients_results = db_connection do |conn|
      conn.exec(
        "SELECT name
         FROM ingredients
         WHERE ingredients.recipe_id = #{recipe_id}" )
    end

    recipe = recipe_results.to_a.first
    ingredients = ingredients_results.to_a

    ingredients_list = []
    ingredients.each do |ingredient|
      name = ingredient["name"]
      ingredients_list << Ingredient.new(name)
    end

    if recipe != nil
      if recipe["description"]
        Recipe.new(recipe["id"], recipe["name"], recipe["description"], recipe["instructions"], ingredients_list)
      else
        recipe["description"] = "This recipe doesn't have a description."
        Recipe.new(recipe["id"], recipe["name"], recipe["description"], recipe["instructions"], ingredients_list)
      end
    else
      Recipe.new("Unknown", "This recipe doesnt have a name", "This recipe doesn't have a description.", "This recipe doesn't have any instructions.")
    end

  end



end
