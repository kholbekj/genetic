require "genetic"

# The eight queens problems is this:
# Assuming a regular chessboard (8x8), place 8 queens so that no one queen can
# take any other.
module EightQueens
  # Since we know 8 queens will have 2 be on 8 different rows, we can represent
  # the board with the position of a queen in each row.
  class QueenConfiguration < Chromosome(Array(Int32))
    def self.random
      list = 8.times.map { Random.rand(8).ceil.to_i }.to_a
      new(list)
    end

    def initialize(@dna : Array(Int32))
    end

    def crossover_strategy
      SinglePointCrossover
    end

    # Probably a decent fitness function is inverse of the moves where queens
    # can take another, but for that we have to decide how often two queens can.
    # I'll not spend a lot of time on an elegant / efficient algorithm here,
    # maybe I'll revisit that after I check out other solutions to the problem.
    def fitness : Int32
      moves_which_invalidate_solution = 0

      column_overlaps = dna.size - dna.uniq.size
      moves_which_invalidate_solution += column_overlaps

      # Diagonal overlaps
      dna.each_with_index do |locus, index|
        dna.each_with_index do |other_locus, other_index|
          hit = (locus - other_locus).abs == (index - other_index).abs
          hit = false if index == other_index
          moves_which_invalidate_solution += 1 if hit
        end
      end

      return 112 if moves_which_invalidate_solution == 0
      (1 / moves_which_invalidate_solution * 56).to_i
    end

    def solution?
      fitness == 112
    end

    # Let's make this easy to visually verify by printing like a chess board.
    def inspect_dna
      board_representation = BitArray.new(64)

      dna.each_with_index do |locus, index|
        n = index * 8 + locus
        board_representation[n] = true
      end

      chess_board = board_representation
        .map { |b| b ? "1" : "0" }
        .each_slice(8)
        .map { |row| row.join }
        .join("\n")
      "#{dna}\n#{chess_board}"
    end

    def mutate!
      bits_to_swap = 0.upto(7).to_a.sample(2)
      dna[bits_to_swap.first], dna[bits_to_swap.last] = dna[bits_to_swap.last], dna[bits_to_swap.first]
    end
  end

  class SinglePointCrossover < CrossoverStrategy(Array(Int32))
    def call(first_parent_dna, second_parent_dna)
      point = Random.rand(8).floor.to_i
      
      first_dna = first_parent_dna[0..point] + second_parent_dna[(point + 1)..-1]
      second_dna = second_parent_dna[0..point] + first_parent_dna[(point + 1)..-1]

      [first_dna, second_dna]
    end
  end

  # Yes, I chose this name because it sounds funny, sue me.
  class ConfigurationPopulation(QueenConfiguration) < Population(QueenConfiguration)
    def chromosome_class
      QueenConfiguration
    end

    def mutate?
      Random.rand < 0.02
    end

    def max_fitness
      112
    end
  end
end
