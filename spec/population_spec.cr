require "./spec_helper"
require "./chromosome_spec"
require "../src/population"

class CatPopulation < Population(BitArray)
  getter current_population

  def chromosome_class
    Cat
  end

  def mutate?
    true
  end
end

describe Population do
  it "subclass can instatiate" do
    CatPopulation.new(10).should be_a(CatPopulation)
  end

  describe "#seed" do
    pop = CatPopulation.new(10)
    pop.current_population.size.should eq(0)
    pop.seed
    pop.current_population.size.should eq(10)
  end

  describe "#evolve!" do
    pop = CatPopulation.new(4)

    cats = [
      Cat.from_string("00000000"),
      Cat.from_string("00000000"),
      Cat.from_string("00000001"),
      Cat.from_string("00000010"),
    ] of Chromosome(BitArray)

    pop.seed(cats)

    pop.evolve!
    pop.current_population.map(&.inspect_dna).map(&.to_i(2)).each do |fitness|
      fitness.should be > 0
    end
  end
end
