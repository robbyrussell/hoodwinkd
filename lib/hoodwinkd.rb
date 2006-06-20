require 'rubygems'
require 'camping'
require 'camping/session'

$:.unshift File.dirname(__FILE__)
Camping.goes :Hoodwinkd

DOMAIN = '[\w\-\.]+\.\w+'
STATIC = File.expand_path('../../static', __FILE__)
SALT = "c4fc5ae625134d2a9cb392f05d94c0be"

require 'mimetypes_hash'
require 'hoodwinkd/helpers'
require 'hoodwinkd/models'
require 'hoodwinkd/controllers'
require 'hoodwinkd/views'

# extensions to the core
require 'hoodwinkd/dial'

module Hoodwinkd::UserSession
    def service(*a)
        if @state.user_id
            @user = Hoodwinkd::Models::User.find :first, @state.user_id
        end
        @user ||= Hoodwinkd::Models::User.new
        super(*a)
    end
end

module Hoodwinkd
    include Camping::Session, Hoodwinkd::UserSession
end

def Hoodwinkd.create
    Camping::Models::Session.create_schema
    unless Hoodwinkd::Models::Session.table_exists?
        ActiveRecord::Schema.define(&Hoodwinkd::Models.schema)
        Hoodwinkd::Models::Hash.replenish
        Hoodwinkd::Models::Session.reset_column_information
    end
end
