# Sinatra app to test recom
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra-websocket'
require 'barista'
require 'sass'
require 'haml'
require 'logger'
require_relative 'recommendation'

module Main
  class Recon < Sinatra::Base
    include Recommendation

    set :root, File.expand_path('..', File.dirname(__FILE__))
    set :logging, true
    set :server, 'thin'
    set :sockets, []

    register Barista::Integration::Sinatra
    register Sinatra::AssetPack

    configure do
      set port: 3912
      set static: true
      use Rack::CommonLogger, $log = ::Logger.new(::File.new('log/recon.log', 'a+'))
      $log.debug "Started Recon at #{Time.now}"
      Barista.add_preamble do |location|
        %{
          /* DO NOT MODIFY -- compiled from #{location}
           */
        }
      end
    end

    # recommendation DSL
    rec_options permutations: 12, buckets: 1001, bands: 4
    load_data :test #, :test2

    assets do
      serve '/js',      from: 'app/js'           # Default
      serve '/css',     from: 'app/css'          # Default
      serve '/images',  from: 'app/images'       # Default
    end

    get '/' do
      haml :index
    end

    post '/recom' do
      @recommendations = recommend(@user = params[:user].to_i)
      @items = recommend_list(@recommendations)
      haml :recommend
    end

  end
end

Main::Recon.run!
