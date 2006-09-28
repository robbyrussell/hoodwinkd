require 'aes'
require 'clean-html'
require 'net/smtp'
require 'erb'
require 'redcloth'
require 'time'
require 'uri'

class << Gem; attr_accessor :loaded_specs; end

module Hoodwinkd::Helpers
    def output_json(ary, base = [])
        @headers['Content-Type'] = 'text/plain'
        if base.is_a? Hash
            ary.inject(base) do |hsh, row|
                row = row.attributes
                hsh.merge!(yield(row))
                hsh
            end.to_json
        else
            ary.map do |row|
                row = row.attributes
                yield row if block_given?
                row
            end.to_json
        end
    end
    def js_time(time, format = nil)
        capture do
            time = Time.at(time.to_i)
            span time.iso8601, :class => "PerfectTime#{format}", :gmt_time => time.to_i
        end
    end
    def time_coerce(str)
        ActiveRecord::ConnectionAdapters::Column.string_to_time(str)
    end
    def url_canonize(str, qs)
        str.gsub!( %r!(.)/+$!, '\1' )
        str.gsub!( %r!/+!, '/' )
        str = URI::escape(str).gsub('?', '%3F')
        str += "?#{qs}" unless qs.blank?
        str
    end
    def num( str )
        str.gsub(/(.)(?=.{3}+$)/, %q(\1,))
    end
    def decrypt( token, enc, salt = SALT )
        Aes.decrypt_block( 128, 'CBC', [token].pack("H*"), [salt].pack("H*"), [enc].pack( "H*" ) ).sub( /(.|\n)(\1*)\Z/, '' )
    end
    def encrypt( token, phrase, salt = SALT )
        Aes.encrypt_buffer( 128, 'CBC', [token].pack("H*"), [salt].pack("H*"), phrase ).unpack("H*")[0]
    end
    def red( str, post_process = nil ) 
        if spc = str[/^([ \t]*)\S/, 1]
            str.gsub!(/^#{spc}/, '')
        end
        html = RedCloth.new( str ).to_html
        if post_process 
            html.__send__(post_process)
        else
            html
        end
    end
    def winker_kind(freq)
        if freq == 0
            "unrealized"
        elsif freq < 0.1
            "oh-not-much-to-say-yet"
        elsif freq < 0.3
            "occassional"
        elsif freq < 0.7
            "once-in-a-half-moon"
        elsif freq < 1.0
            "decent-enough"
        elsif freq < 2.0
            "bravely-enduring"
        elsif freq < 4.0
            "active-and-gifted"
        elsif freq < 8.0
            "really-quite-chatty"
        else
            "ferocious-and-unstoppable"
        end
    end
    def n(number, delimiter=",")
        number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    end
    def send_password_reminder_to user
        Net::SMTP.start( 'localhost' ) do |smtp|
            smtp.send_message <<MSG, 'why@hobix.com', user.email
From: why the lucky stiff <why@hobix.com>
To: #{ user.login } <#{ user.email }>
Subject: your hoodwink.d account

Hi, here's your lost password: #{ decrypt( user.security_token, user.password ) }

Once you login, you can go to `profile' and change the password, if you
feel it's really been comprised.  I hope this little ordeal hasn't been
too rough on you.  Come back, we need you.

_why
MSG
        end
    end
end

module Hoodwinkd::Views
    def rss2_0
        feed = Builder::XmlMarkup.new( :indent => 2 )
        feed.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        feed.rss( 'xmlns:admin' => 'http://webns.net/mvcb/', 
                  'xmlns:sy' => 'http://purl.org/rss/1.0/modules/syndication/',
                  'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                  "xmlns:rdf" => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
                  'version' => "2.0" ) do |rss|
            rss.channel do |c|
            
                # channel stuffs
                c.dc :language, "en-us" 
                c.dc :creator, "XML::Builder #{ Gem.loaded_specs['builder'].version }"
                c.dc :date, Time.now.utc.strftime( "%Y-%m-%dT%H:%M:%S+00:00" )
                c.admin :generatorAgent, "rdf:resource" => "http://builder.rubyforge.org/"
                c.sy :updatePeriod, "hourly"
                c.sy :updateFrequency, 1
                yield c
            end
        end
    end
end
