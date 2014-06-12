require 'set'
require 'pp'
require 'prime'

module MinHash
  # Set all the options MimHash will use.
  # Current options are:
  #- :permutations -- number of permutations to use in MinHash
  #-
  # TODO: add checking for options' validity. It really should complain
  # TODO: if an option is invalid.
  def set_options(**opts)
    opts.each{|var, opt| instance_variable_set "@#{var}".to_sym, opt }
  end

  def self.included(mod)
    # We need variables that can set themselves to default objects.
    # This is an effective way to accomplish that.
    # TODO: create a gem to do this in a cleaner fashion.
    {
        universe:     %{ SortedSet.new }, # Universe of elements to compute the minhahs over.
        history:      %{ Hash.new },      # History of the user's activities to compute the minhash on.
        permutations: %{ 5 },             # number of hash functions for permutations
        minhash:      %{
          Hash.new do |hash, key|
            hash[key] = Array.new(permutations, Float::INFINITY)
          end
        }
    }.each_pair do |sym, func|
      mod.class_eval <<-EOF
        def #{sym}
          @#{sym} ||= #{func}
        end

        def clear_#{sym}
          @#{sym} = nil
        end
      EOF
    end
  end

  # Add history of 'clicks' in the form of userid: [history]
  # hashes to the MinHash.
  #
  # If a block is given, the block is expected to return
  # a singular hash.
  def add_history(*hist, &block)
    hist << block.() if block_given?
    hist.each { |hsh|
      hsh.each { |user, activiy| universe.merge activiy}
      history.merge! hsh
    }
    pp universe
    pp history
  end

  # Delete history -- here for completeness, though
  # not apart of this test.
  def delete_history(*hist)
    raise 'TODO: Not Implemented Yet'
  end

  # For permutation hashes, we need to pick the next prime bigger than
  # the universe size.
  # NOTE WELL: This is an expensive operation.
  def next_prime_after(n = universe.size)
    n += 1 unless n.odd?
    while not n.prime?
      n += 2
    end
    n
  end

  # f is the permute function number, which will then iterate the
  # permuted indicies for that function.
  def permute
    prime = next_prime_after
    0..permutations
  end

  # Compute the minhash given the current data.
  # The number of permutations will be, obviously,
  # the number of hashes per user.
  # TODO: add logic to compute minhash incrementally.
  def compute_minhash
    clear_minhash

  end

  # We wish to add indexability to the sorted set.
  class ::SortedSet
    def [](i)
      self.to_a[i]
    end
  end
end
