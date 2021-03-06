# Keeps track of population, generations, selection.
class Population(T)
  getter generation, best_solution
  
  @best_solution : T?

  def initialize(@n : Int32)
    @current_population = [] of T
    @generation = 0
  end

  # Seed the genesis generation.
  def seed(population : Array(T) = [] of T)
    if population.any?
      @current_population = population
      return
    end

    @n.times do
      @current_population << T.random
    end
  end

  # Calls fitness function on ALL chromosomes, and returns highest.
  # Be mindful of the expense.
  def winner
    raise "Empty population" if @current_population.empty?
    @current_population.max_by(&.fitness)
  end

  # Selects chromosomes for breeding (using `#select_pair`), creates the next generation.
  # Adds random mutation depending on `#mutate?`
  def evolve!
    @generation += 1
    new_population = [] of T
    until new_population.size >= @n
      pair = select_pair
      offspring = pair.first.breed(pair.last)
      
      [offspring].flatten.each do |o|
        o.mutate! if mutate?
        new_population << o
      end
    end
    @current_population = new_population
    @best_solution = winner
  end

  # Select a pair of chromosomes using proportional selection.
  def select_pair
    [accept_reject_pick, accept_reject_pick]
  end

  private def accept_reject_pick
    current_max_fitness = max_fitness
    loop do
      candidate = @current_population.sample
      return candidate if Random.rand(current_max_fitness) < candidate.fitness
    end
  end

  def max_fitness
    winner.fitness
  end

  # A bit naive perhaps, but easy to override.
  def mutate?
    Random.rand < 0.05
  end
end

class PopulationConfiguration
  property size : Int32

  def initialize
    @size = 0
  end
end
