module Hoodwinkd::Controllers
    class DomainPage < R '/([^/]+\.[\w\-]+)'
        def get(domain)
            @site = Site.find_by_domain domain
            @posts = @site.recent_posts(20)
            @pop_posts = @site.popular_posts(10)
            @winkers = @site.top_winkers(5)
            render :domain
        end
    end
    class WinkerPage < R '/([\w\-]+)'
        def get(login)
            @user = User.find_by_login login
            @avg_winks = @user.winks.size.to_f / (((Time.now - @user.created_at) / 1.day) + 1)
            @winks = @user.recent_winks(20)
            @posts = @user.recent_posts(10)
            render :winker
        end
    end
end

module Hoodwinkd::Views
    def domain
        html do
        @auto_validation = false
        head do
            title "winks for #{@site.domain}"
            style <<-END, :type => 'text/css'
                @import '#{R(Static, 'css', 'domaind.css')}';
                @import '#{R(Static, 'css', 'winksum.css')}';
            END
            script :type => "text/javascript", :src => "/js/support.js"
        end
        body do
            div.page! do
                menu
                div.banner! do
                    div.logo! { img :src => R(Static, 'i', 'hoodwinkd-logo-ltblue.png') }
                    div.subscribe! do
                        a(:href => "/onslaught/search.xml?q=site:#{@site.domain}"){ img :src => '/i/feed-icon-24x24.png' }
                    end
                    h1 @site.domain
                    h3 "winked over since #{@site.created_at}"
                    h4 "#[@site.wink_count] winks -- an average of #[@site.wink_avg] winks each day"
                end
                div.content! do
                    div.blog! do
                        @posts.each do |post|
                            div.entry do
                                h3.title { a(:href => "http://#{@site.real_domain || @site.domain}#{post.permalink}"){self << post.title} }
                                div.detail { div.winks post.wink_count }
                                div.attrib { self << "last by "
                                    a(:href => "/#{post.login}"){ strong post.login } }
                                div.body { self << post.comment_html }
                                div.footer "thread started on #{post.created_at}"
                            end
                        end
                    end
                    div.sidebar! do
                        div.box do
                            ul { li { a "Dial profile", :href => R(DialSite, @site.domain) } }
                        end
                        div.box do
                            h2 "Frequently Seen"
                            h4 "Winker grand totals"
                            ul do
                                @winkers.each do |user|
                                    li { a user.login, :href => "/#{user.login}"
                                        div.detail { div.winks user.wink_count } }
                                end
                            end
                        end
                        div.box do
                            h2 "Wink Saturated"
                            h4 "Historically popular"
                            ul do
                                @pop_posts.each do |post|
                                    li { div.summary.mini { a(:href => "http://#{@site.real_domain || @site.domain}#{post.permalink}"){self<<post.title}
                                         div.date post.created_at
                                         div.detail { div.winks post.wink_count } } }
                                end
                            end
                        end
                    end
                    div.footer! do
                        div.box do
                            h3 "hoodwink.d"
                            div.pendingSites! do
                            end
                        end
                    end
                end
            end
        end
        end
    end
    def winker
        html do
        @auto_validation = false
        head do
            title "#{@user.login}, the winker"
            style <<-END, :type => 'text/css'
                @import '#{R(Static, 'css', 'winker.css')}';
                @import '#{R(Static, 'css', 'winksum.css')}';
            END
            script :type => "text/javascript", :src => "/js/support.js"
            script :type => "text/javascript", :src => "/js/perfecttime.js"
        end
        body do
            div.page! do
                menu
                div.banner! do
                    div.logo! { img :src => R(Static, 'i', 'hoodwinkd-logo-grey.png') }
                    div.subscribe! do
                        a(:href => "/onslaught/search.xml?q=who:#{@user.login}"){ img :src => '/i/feed-icon-24x24.png' }
                    end
                    h1 @user.login
                    h3 { self << "an <strong>#{winker_kind(@avg_winks)}</strong> winker since #{js_time @user.created_at, 'Day'}" }
                    h4 "%d winks -- an average of %0.2f winks each day" % [@user.winks.size, @avg_winks]
                end
                div.content! do
                    div.blog! do
                        @winks.each do |wink|
                            div.entry do
                                h3.title { a(:href => "http://#{wink.real_domain}#{wink.permalink}"){self << wink.title} }
                                div.detail { div.winks wink.wink_count }
                                div.attrib { "on #{js_time wink.created_at}" }
                                div.body { wink.comment_html }
                                div.footer { "posted to #{a wink.domain, :href => "/#{wink.domain}"}" }
                            end
                        end
                    end
                    div.sidebar! do
                        div.box do
                            h2 { self << "Recent Threads "; a(:href => "/onslaught/search.xml?q=anywho:#{@user.login}") {
                                 img :src => '/i/feed-icon-12x12.png' } }
                            h4 "All participation this week"
                            ul do
                                @posts.each do |post|
                                    li { div.summary.mini { a(:href => "http://#{post.real_domain}#{post.permalink}"){self<<post.title}
                                         div.date post.created_at
                                         div.detail { div.winks post.wink_count } } }
                                end
                            end
                        end
                    end
                    div.footer! do
                        div.box do
                            h3 "hoodwink.d"
                            div.pendingSites! do
                            end
                        end
                    end
                end
            end
        end
        end
    end
end
