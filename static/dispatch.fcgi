#!/usr/local/bin/ruby
$: << File.expand_path("../../lib", __FILE__)
require 'hoodwinkd'
require 'uri'
require 'fcgi'
Dir.chdir('/home/sites/hoodwink.d/public')
Hoodwinkd.connect '../config/database.yml'
Hoodwinkd.create if Hoodwinkd.respond_to? :create
FCGI.each do |req|
    # req.out << "Content-Type: text/html\n\n#{ req.env.inspect }"
    req.env['SCRIPT_NAME'] = '/'
    u = URI(req.env['REQUEST_URI'])
    req.env['PATH_INFO'] =
        u.path.gsub( %r!(.)/+$!, '\1' ).
                gsub( %r!/+!, '/' ).
                gsub( '?', '%3F' )
    req.env['QUERY_STRING'] = u.query
    req.out << Hoodwinkd.run(req.in, req.env)
    req.finish
end
