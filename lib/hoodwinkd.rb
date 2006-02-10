require 'rubygems'
require 'camping'

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

def Hoodwinkd.create
    unless Hoodwinkd::Models::Session.table_exists?
        ActiveRecord::Schema.define(&Hoodwinkd::Models.schema)
        Hoodwinkd::Models::Hash.replenish
        Hoodwinkd::Models::Session.reset_column_information
    end
end
