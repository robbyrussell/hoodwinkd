module Hoodwinkd::Controllers
    def self.constants
        super().sort
    end

    class Preview < R "/(#{DOMAIN})/preview"
        def get(domain)
            red(@input[:c])
        end
    end

    class Setup < R "/(#{DOMAIN})/setup"
        def get(domain)
            layers = Site.find_setup(domain)
            output_json(layers) do |layer| 
                layer['fullpost_qvars'] = layer['fullpost_qvars'].to_s.split(/\s*,\s+/)
            end
        end
    end

    class Winksoom < R "/(#{DOMAIN})/winksoom", "/(#{DOMAIN})/winksoom/(.+)"
        def get(domain, layer = nil)
            conditions = ['s.domain = ?', domain]
            conditions = ['s.domain = ? AND l.name = ?', domain, layer] if layer
            if @input.count or @input.start
                limit = "LIMIT %d, %d" % [@input.start.to_i, (@input.count || 10).to_i]
            end
            @posts =
                Post.find_by_sql([<<-END] + conditions[1..-1])
                    SELECT p.permalink, p.title, p.wink_count AS count, 
                           f.created_at AS started_at, fu.login AS started_by,
                           e.created_at AS ended_at, eu.login AS ended_by
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks f, hoodwinkd_users fu,
                         hoodwinkd_winks e, hoodwinkd_users eu
                    WHERE #{conditions[0]} AND s.id = l.site_id
                      AND l.id = p.layer_id 
                      AND f.id = p.first_wink_id AND fu.id = f.user_id
                      AND e.id = p.last_wink_id AND eu.id = e.user_id
                    ORDER BY e.created_at DESC #{limit}
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
            if @input.count or @input.start
                limit = "LIMIT %d, %d" % [@input.start.to_i, (@input.count || 10).to_i]
            end
            @posts =
                Post.find_by_sql [<<-END] + conditions[1..-1]
                    SELECT p.permalink, p.wink_count AS count, e.created_at AS ended_at
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks e
                    WHERE #{conditions[0]} AND s.id = l.site_id
                      AND l.id = p.layer_id 
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

    class WinkMain < R "/(#{DOMAIN})/wink(/.*)?"
        def get(domain, permalink)
            @headers['Content-Type'] = 'text/plain'
            @permalink = url_canonize(permalink || '/', @env['QUERY_STRING'])
            @winks =
                Wink.find_by_sql [<<-END, domain, @permalink]
                    SELECT u.login AS user, w.created_at, w.comment_html AS comment,
                           u.nameplate, u.namehue
                    FROM hoodwinkd_winks w, hoodwinkd_posts p, hoodwinkd_users u, 
                         hoodwinkd_layers l, hoodwinkd_sites s
                    WHERE w.post_id = p.id AND p.layer_id = l.id
                      AND l.site_id = s.id AND u.id = w.user_id 
                      AND s.domain = ? AND p.permalink = ?
                    ORDER BY w.created_at ASC
                END
            output_json(@winks)
        end

        def post(domain, permalink)
            @user = User.find_by_login @input.hoodwink_login
            @permalink = url_canonize(permalink, @env['QUERY_STRING'])
            pass_in = decrypt( @user.security_token, @input.hoodwink_passc[32,32], @input.hoodwink_passc[0,32] )
            if pass_in == decrypt( @user.security_token, @user.password )
                layer = Site.find_setup(domain).first
                if layer.domain != domain
                    site = AliasedSite.create(:creator_id => @user.id, :domain => domain, :linked_site => layer)
                    linklayer = Layer.create(:site => site, :name => '-')
                end
                @post = Post.find_by_sql([<<-END, domain, @permalink]).first
                    SELECT p.*, IFNULL(s.real_domain, s.domain) AS real_domain
                     FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s
                    WHERE p.layer_id = l.id AND l.site_id = s.id
                      AND s.domain = ? AND p.permalink = ?
                END
                if @post
                    domain = @post.real_domain
                else
                    @layer = 
                        Site.find_by_domain(domain, :include => :layers).layers.detect do |l|
                            @permalink =~ /#{ l.fullpost_url_match }/
                        end
                    @post = Post.create :layer_id => @layer.id, :permalink => @permalink,
                        :wink_count => 0
                end
                html = red( @input.hoodwink_writer )
                @wink = Wink.create :post_id => @post.id, :user_id => @user.id,
                    :comment_plain => @input.hoodwink_writer, :comment_html => html
                if @wink.errors.empty?
                    @post.wink_count += 1
                    if @post.first_wink_id.to_i == 0
                        @post.first_wink_id = @wink.id
                    end
                    @post.last_wink_id = @wink.id
                    @post.save
                    r 302,'','Location'=>"http://#{ domain }#{ @permalink }"
                end
            end
        end
    end

    class Static < R '/(i|js|css|themes)/(.+)'
        def get(dir, path)
            path = File.join(STATIC, dir, path.gsub(/\.+/, '.'))
            type = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
            @headers['Content-Type'] = type
            if File.exists? path
                @headers['X-Sendfile']= path
            end
        end
    end
end
