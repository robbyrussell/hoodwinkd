
DOMAIN = '[^/]+\.[\w\-]+'

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
                    SELECT p.permalink, p.title, p.winks, 
                           f.created_at AS started_at, fu.login AS started_by,
                           e.created_at AS ended_at, eu.login AS ended_by
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks f, hoodwinkd_users fu,
                         hoodwinkd_winks e, hoodwinkd_users eu
                    WHERE #{conditions[0]} AND s.id = l.hoodwinkd_site_id
                      AND l.id = p.hoodwinkd_layer_id 
                      AND f.id = p.first_wink AND fu.id = f.hoodwinkd_user_id
                      AND e.id = p.first_wink AND eu.id = e.hoodwinkd_user_id
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
                    SELECT p.permalink, p.winks, e.created_at AS ended_at
                    FROM hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_layers l, 
                         hoodwinkd_winks e
                    WHERE #{conditions[0]} AND s.id = l.hoodwinkd_site_id
                      AND l.id = p.hoodwinkd_layer_id 
                      AND e.id = p.first_wink
                    ORDER BY e.created_at DESC #{limit}
                END
            output_json(@posts) do |post|
                post['ended_at'] = time_coerce(post['ended_at'])
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
    end
end
