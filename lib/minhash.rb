require 'set'
require 'pp'

module MinHash
  # Add history of 'clicks' in the form of userid: [history]
  # hashes to the MinHash.
  #
  # If a block is given, the block is expected to return
  # a singular hash.
  def add_history(*hist, &block)
    hist << block.() if block_given?
    @universe ||= SortedSet.new
    hist.each { |hsh| hsh.each { |user, activiy| @universe.merge activiy}}
    pp @universe
  end

  # Delete history -- here for completeness, though
  # not apart of this test.
  def delete_history(*hist)
    raise 'TODO: Not Implemented Yet'
  end

  class ::SortedSet
    # TODO: there may be some performance issues here.
    def [](i)
      self.to_a[i]
    end
  end
end
