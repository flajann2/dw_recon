require 'set'
require 'pp'
require 'prime'

module MinHash
  # Set all the options MimHash will use.
  # Current options are:
  #- :permutations -- number of permutations to use in MinHash
  #-
  def set_options(**opts)
    opts.each{|var, opt| instance_variable_set "@#{var}".to_sym, opt }
  end

  def universe
    @universe ||= SortedSet.new
  end

  def history
    @history ||= {}
  end

  def minhash
    @minhash ||= Hash.new do |hash, key|
      hash[key] = Array.new(permutations, Float::INFINITY)
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
  def next_prime_after(n = universe.size)
    n += 1 unless n.odd?
    while not n.prime?
      n += 2
    end
    n
  end

  # Compute the minhash given the current data.
  # The number of permutations will be, obviously,
  # the number of hashes per user.
  def compute_minhash
    @minhash = nil # Erase old minhash first, start afresh. TODO: add logic to compute minhash incrementally

  end

  # We wish to add indexability to the sorted set.
  class ::SortedSet
    def [](i)
      self.to_a[i]
    end
  end
end
