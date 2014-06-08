# Recommendation Algorithm
require 'pp'
require 'set'
require 'smarter_csv'
require_relative 'minhash'

module Recommendation
  def recommend(user)
    [11,22,33,44,55]
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

    def load_data(*csvs)
      @datapath ||= 'db'
      @recbase ||= RecBase.new
      @data = csvs.map { |csv|
        File.expand_path("#{csv}.csv", @datapath)
      }.map { |p|
        SmarterCSV.process(p, col_sep: ';', strip_whitespace: true)
        .inject(Hash.new{|h,k| h[k] = SortedSet.new}) { |memo, row|
          memo[row[:userid]] << row[:productid]
          memo
        }
      }.inject({}) { |memo, hsh|
        memo.merge hsh
      }
      pp @data
      @recbase.add_history @data
    end
  end
end
