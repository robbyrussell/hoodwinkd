require 'rubygems'
require 'camping'

Camping.goes :Hoodwinkd

require 'hoodwinkd/helpers'
require 'hoodwinkd/models'
require 'hoodwinkd/controllers'
require 'hoodwinkd/views'

def Hoodwinkd.create
    unless Hoodwinkd::Models::Wink.table_exists?
        ActiveRecord::Schema.define(&Hoodwinkd::Models.schema)
    end
end
