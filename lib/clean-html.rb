class String
    BASIC_TAGS = {
        'a' => ['href', 'title'],
        'img' => ['src', 'alt', 'title'],
        'br' => [],
        'i' => nil,
        'u' => nil,
        'b' => nil,
        'pre' => nil,
        'kbd' => nil,
        'code' => ['lang'],
        'cite' => nil,
        'strong' => nil,
        'em' => nil,
        'ins' => nil,
        'sup' => nil,
        'sub' => nil,
        'strike' => nil,
        'del' => nil,
        'table' => nil,
        'tr' => nil,
        'td' => nil,
        'th' => nil,
        'ol' => nil,
        'ul' => nil,
        'li' => nil,
        'p' => nil,
        'h1' => nil,
        'h2' => nil,
        'h3' => nil,
        'h4' => nil,
        'h5' => nil,
        'h6' => nil,
        'blockquote' => ['cite']
    }
    def clean_html!( tags = BASIC_TAGS )
        gsub!( /<!\[CDATA\[/, '' )
        gsub!( /<(\/*)(\w+)([^>]*)>/ ) do
            raw = $~
            tag = raw[2].downcase
            if tags.has_key? tag
                pcs = [tag]
                tags[tag].each do |prop|
                    ['"', "'", ''].each do |q|
                        q2 = ( q != '' ? q : '\s' )
                        if raw[3] =~ /#{prop}\s*=\s*#{q}([^#{q2}]*)#{q}/i
                            attrv = $1.to_s
                            next if prop == 'src' and attrv !~ /^http/
                            pcs << "#{prop}=\"#{attrv.gsub('"', '\\"')}\""
                            break
                        end
                    end
                end if tags[tag]
                "<#{raw[1]}#{pcs.join " "}>"
            else
                " "
            end
        end
    end
end

