module Hoodwinkd::Controllers
    class Setup < R "/(#{DOMAIN})/setup"
        def get(domain)
            layers = 
                Site.find_by_sql [<<-END, domain]
                    SELECT l.name, l.fullpost_qvars, l.css, l.fullpost_xpath, l.fullpost_url_match,
                           s.domain, s.enabled, s.created_at
                    FROM hoodwinkd_sites s, hoodwinkd_layers l
                    WHERE s.domain = ? AND l.hoodwinkd_site_id = s.id
                END
            output_json(layers) do |layer| 
                layer['fullpost_qvars'] = layer['fullpost_qvars'].to_s.split(/\s*,\s+/)
            end
        end
    end

    class Winksoom < R "/(#{DOMAIN})/winksoom", "/(#{DOMAIN})/winksoom/(.+)"
        def get(domain, layer = nil)
            conditions = ['s.domain = ?', domain]
            conditions = ['s.domain = ? AND l.name = ?', domain, layer] if layer
            if input.count or input.start
                limit = "LIMIT %d, %d" % [input.start.to_i, (input.count || 10).to_i]
            end
            @posts =
                Post.find_by_sql([<<-END] + conditions[1..-1])
                    SELECT p.permalink, p.title, p.wink_count AS count, 
                           f.created_at AS started_at, fu.login AS started_by,
                           e.created_at AS ended_at, eu.login AS ended_by
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks f, hoodwinkd_users fu,
                         hoodwinkd_winks e, hoodwinkd_users eu
                    WHERE #{conditions[0]} AND s.id = l.hoodwinkd_site_id
                      AND l.id = p.hoodwinkd_layer_id 
                      AND f.id = p.first_wink_id AND fu.id = f.hoodwinkd_user_id
                      AND e.id = p.first_wink_id AND eu.id = e.hoodwinkd_user_id
                    ORDER BY e.created_at DESC
                END
            output_json(@posts) do |post|
                %w[ended_at started_at].each { |c| post[c] = time_coerce(post[c]) }
            end
        end
    end

    class Winksum < R "/(#{DOMAIN})/winksum", "/(#{DOMAIN})/winksum/(.+)"
        def get(domain, layer = nil)
            conditions = ['s.domain = ?', domain]
            conditions = ['s.domain = ? AND l.name = ?', domain, layer] if layer
            if input.count or input.start
                limit = "LIMIT %d, %d" % [input.start.to_i, (input.count || 10).to_i]
            end
            @posts =
                Post.find_by_sql [<<-END] + conditions[1..-1]
                    SELECT p.permalink, p.wink_count AS count, e.created_at AS ended_at
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks e
                    WHERE #{conditions[0]} AND s.id = l.hoodwinkd_site_id
                      AND l.id = p.hoodwinkd_layer_id 
                      AND e.id = p.first_wink_id
                    ORDER BY e.created_at DESC #{limit}
                END
            output_json(@posts, {}) do |post|
                post['ended_at'] = time_coerce(post['ended_at'])
                {post.delete('permalink') => post}
            end
        end
    end

    class Stat < R "/(#{DOMAIN})/stat(/.*)"
        def get(domain, permalink)
            @headers['Content-Type'] = 'text/plain'
            url_canonize(permalink, @env['QUERY_STRING'])
        end
    end

    class WinkMain < R "/(#{DOMAIN})/wink(/.*)"
        def get(domain, permalink)
            @headers['Content-Type'] = 'text/plain'
            @permalink = url_canonize(permalink, @env['QUERY_STRING'])
            @winks =
                Wink.find_by_sql [<<-END, domain, permalink]
                    SELECT u.login AS user, w.created_at, w.comment_html AS comment
                    FROM hoodwinkd_winks w, hoodwinkd_posts p, hoodwinkd_users u, 
                         hoodwinkd_layers l, hoodwinkd_sites s
                    WHERE w.hoodwinkd_post_id = p.id AND p.hoodwinkd_layer_id = l.id
                      AND l.hoodwinkd_site_id = s.id AND u.id = w.hoodwinkd_user_id 
                      AND s.domain = ? AND p.permalink = ?
                    ORDER BY w.created_at ASC
                END
            output_json(@winks)
        end

        def post(domain, permalink)
            @user = User.find_by_login input.hoodwink_login
            @permalink = url_canonize(permalink, @env['QUERY_STRING'])
            pass_in = decrypt( @user.security_token, input.hoodwink_passc[32,32], input.hoodwink_passc[0,32] )
            if pass_in == decrypt( @user.security_token, @user.password )
                @post = Post.find_by_sql([<<-END, domain, @permalink]).first
                    SELECT p.* FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s
                    WHERE p.hoodwinkd_layer_id = l.id AND l.hoodwinkd_site_id = s.id
                      AND s.domain = ? AND p.permalink = ?
                END
                unless @post
                    @layer = 
                        Site.find_by_domain(domain, :include => :layers).layers.detect do |l|
                            @permalink =~ /#{ l.fullpost_url_match }/
                        end
                    @post = Post.create :hoodwinkd_layer_id => @layer.id, :permalink => @permalink,
                        :wink_count => 0
                end
                html = red( input.hoodwink_writer )
                @wink = Wink.create :hoodwinkd_post_id => @post.id, :hoodwinkd_user_id => @user.id,
                    :comment_plain => input.hoodwink_writer, :comment_html => html
                @post.wink_count += 1
                unless @post.first_wink_id
                    @post.first_wink_id = @wink.id
                end
                @post.last_wink_id = @wink.id
                @post.save
                redirect "http://#{ domain }#{ permalink }"
            end
        end
    end

    class Static < R '/static/(.+)'
        def get(path)
            path = File.join(STATIC, path.gsub(/\.+/, '.'))
            if File.exists? path
                type = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
                @headers['Content-Type'] = type
                src = File.read(path)
                if type =~ %r!^text/!
                    src.gsub!(/\$(R\(.+?\))/) { eval($1) }
                end
                src
            end
        end
    end
end
