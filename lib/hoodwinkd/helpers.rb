require 'aes'
require 'clean-html'
require 'erb'
require 'redcloth'
require 'uri'

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
    def js_time( unixt, fmt = "%d %b %Y at %I:%M:%S %p" )
        %{<script type="text/javascript">
              document.write((new Date(#{unixt.to_i * 1000})).strftime(#{fmt.dump}));
          </script><noscript>
              #{Time.at(unixt.to_i).strftime(fmt)}
          </noscript>}
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
end
