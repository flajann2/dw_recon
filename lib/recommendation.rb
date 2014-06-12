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
