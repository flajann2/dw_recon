# Recommendation Algorithm

module Recommendation
  def recommend(user)
    [11,22,33,44,55]
  end

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def set_base(path)
      @datapath = path
    end

    def load_data(*csvs)
      @datapath ||= 'db'
      csvs.map do |csv|
        File.expand_path("#{csv}.csv", @datapath)
      end.each { |p| puts p }
    end
  end
end
