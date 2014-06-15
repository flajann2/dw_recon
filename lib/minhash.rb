require 'set'
require 'prime'

module MinHash
  include Math

  # Set all the options MimHash will use.
  # Current options are:
  #- :permutations -- number of permutations to use in MinHash
  #-
  # TODO: add checking for options' validity. It really should complain
  # TODO: if an option is invalid.
  def set_options(**opts)
    opts.each{|var, opt| self.instance_variable_set "@#{var}".to_sym, opt }
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
        },
        buckets:      %{ 50 },
        bands:        %{ 10 },
        bucket_ar:    %{
          Hash.new do |hash, num|
            hash[num] = Set.new
          end
        },
        user_buckets: %{
          Hash.new do |hash, key|
            hash[key] = Set.new
          end
        },
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

  def similarity(u1, u2)
    s1 = history[u1]
    s2 = history[u2]
    s1.intersection(s2).size.to_f / s1.union(s2).size.to_f
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
    n = sqrt(n).ceil
    n += 1 unless n.odd?
    while not n.prime?
      n += 2
    end
    n
  end

  RRANGE = 100000000
  SRANGE = 1000

  def permute
    prime = next_prime_after
    primesq = prime * prime
    (0...permutations).map{|pf| [pf, rand(1..SRANGE)*prime, rand(1..RRANGE), rand(1..RRANGE)]}
    .each{ |pf, a, b, c|
      (0...universe.size)
      .each{ |ux| yield pf, ux, ((a * ux ** 2 + b * ux + c) % primesq) % universe.size }
    }
  end

  # Compute the minhash given the current data.
  # The number of permutations will be, obviously,
  # the number of hashes per user.
  #
  # This also computes the LSH.
  # TODO: add logic to compute minhash incrementally.
  #
  # pf -- permute fuction (integer)
  # ux -- index
  # permuted -- ux bijective mapping (we hope!)
  def compute_minhash
    clear_minhash
    permute { |pf, ux, permuted|
      puts "[pf #{pf} ux #{ux} perm #{permuted}]"
      history.each{|user, hist|
        if hist.member? universe[permuted]
          minhash[user][pf] = permuted if permuted < minhash[user][pf]
        end
      }
    }
    compute_lsh
  end

  # This hashes the given numbers (presumably from a band), using a 'function'
  # generated from the funct number.
  #
  # The generated number here is an index to the bucket to use.
  def lsh_hash(funct, *v)
    v.inject(101){|memo, i| memo *(i ** funct + funct)} % buckets
  end

  # minhash must have already been computed before this is called.
  # NOTE WELL: permutations should be a multiple of bands for this to work
  def compute_lsh
    rows_per_band = permutations / bands
    raise "permutations #{permutations} not a multiple of bands #{bands}" unless rows_per_band * bands == permutations
    minhash.each{ |user, hsh|
      hsh = hsh.clone
      (1..bands).each{ |funct|
        bucket_ar[b = lsh_hash(funct, *hsh.shift(rows_per_band))] << user
        user_buckets[user] << bucket_ar[b]
      }
    }
  end

  def get_similar_users(user)
    user_buckets[user].flatten - Set[user]
  end

  # We wish to add indexability to the sorted set.
  class ::SortedSet
    def [](i)
      self.to_a[i]
    end
  end
end
