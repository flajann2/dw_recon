# Recommendation Algorithm
require 'set'
require 'smarter_csv'
require_relative 'minhash'

module Recommendation
  def recommend(user)
    recbase.get_similar_users(user)
    .map{ |u| [u, recbase.history[u].to_a, recbase.similarity(user, u)]}
    .sort{ |a, b| b.last <=> a.last}
    .reject{ |item| item.last < 0.0000001 }
  end

  # Given the recommendation deta
  def recommend_list(details)
    SortedSet.new details.map{|u, lst, sim| lst}.flatten
  end

  def all_users
    recbase.minhash.keys.sort
  end

  def recbase
    self.class.recbase
  end

  def self.included(base)
    base.send :extend, ClassMethods
  end

  class RecBase
    include MinHash
  end

  module ClassMethods
    def set_base(path)
      @datapath = path
    end

    def recbase
      @recbase ||= RecBase.new
    end

    def datapath
      @datapath ||= 'db'
    end

    def load_data(*csvs)
      @data = csvs.map { |csv|
        File.expand_path("#{csv}.csv", datapath)
      }.map { |p|
        SmarterCSV.process(p, col_sep: ';', strip_whitespace: true)
        .inject(Hash.new{|h,k| h[k] = SortedSet.new}) { |memo, row|
          memo[row[:userid]] << row[:productid]
          memo
        }
      }.inject({}) { |memo, hsh|
        memo.merge hsh
      }
      recbase.add_history @data
      recbase.compute_minhash
    end

    def rec_options(**opts)
      recbase.set_options **opts
    end
  end
end
