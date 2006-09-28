require 'rubygems'
require 'camping'
require 'camping/session'

$:.unshift File.dirname(__FILE__)
Camping.goes :Hoodwinkd

DOMAIN = '[\w\-\.]+\.\w+'
STATIC = File.expand_path('../../static', __FILE__)
SALT = ""

require 'mimetypes_hash'
require 'hoodwinkd/helpers'
require 'hoodwinkd/models'
require 'hoodwinkd/controllers'
require 'hoodwinkd/views'

module Hoodwinkd::UserSession
    def service(*a)
        if @state.user_id
            @user = Hoodwinkd::Models::User.find @state.user_id
        end
        @user ||= Hoodwinkd::Models::User.new
        super(*a)
    end
end

module Hoodwinkd
    include Camping::Session, Hoodwinkd::UserSession
end

def Hoodwinkd.connect dbfile
    conf = YAML::load_file(dbfile)
    ::SALT.replace conf['salt']
    Hoodwinkd::Models::Base.establish_connection(conf)
    Hoodwinkd::Models::Base.logger = Logger.new('camping.log') if $DEBUG
    Hoodwinkd::Models::Base.threaded_connections=false
    Hoodwinkd::Models::Base.verification_timeout = 14400 if conf['adapter'] == 'mysql'
end

def Hoodwinkd.create
    Camping::Models::Session.create_schema
    unless Hoodwinkd::Models::Session.table_exists?
        ActiveRecord::Schema.define(&Hoodwinkd::Models.schema)
        Hoodwinkd::Models::Hash.replenish
        Hoodwinkd::Models::Session.reset_column_information
    end
end

def Hoodwinkd.serve
    require 'mongrel'
    require 'mongrel/camping'

    # Use the Configurator as an example rather than Mongrel::Camping.start
    config = Mongrel::Configurator.new :host => "0.0.0.0" do
        listener :port => 3301 do
            uri "/", :handler => Mongrel::Camping::CampingHandler.new(Hoodwinkd)
            uri "/favicon", :handler => Mongrel::Error404Handler.new("")
            trap("INT") { stop }
            run
        end
    end

    puts "** Hoodwinkd is running at http://localhost:3301/"
    config.join
end
