require 'aes'
require 'clean-html'
require 'redcloth'
require 'uri'

module Hoodwinkd::Helpers
    def output_json(ary)
        @headers['Content-Type'] = 'text/plain'
        ary.map do |row|
            row = row.attributes
            yield row if block_given?
            row
        end.to_json
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
        %{
            <script type="text/javascript">
                document.write((new Date(#{unixt.to_i * 1000})).strftime(#{fmt.dump}));
            </script>
            <noscript>
                #{Time.at(unixt.to_i).strftime(fmt)}
            </noscript>
        }
    end
    def num( str )
        str.gsub(/(.)(?=.{3}+$)/, %q(\1,))
    end
    def decrypt( token, ct )
        Aes.decrypt_block( 128, 'CBC', [token].pack("H*"), [ct[0,32]].pack("H*"), [ct[32,32]].pack( "H*" ) ).sub( /(.|\n)(\1*)\Z/, '' )
    end
    def encrypt( token, salt, phrase )
        Aes.encrypt_buffer( 128, 'CBC', [token].pack("H*"), [salt].pack("H*"), phrase ).unpack("H*")[0]
    end
    def red( str ) 
        html = RedCloth.new( str ).to_html
        html.clean_html! 
    end
end
