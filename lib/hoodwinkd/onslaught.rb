module Hoodwinkd::Controllers
    class Onslaught < R '/onslaught'
        def get
            @recent_posts = Post.incoming_posts(false)
            @meta_posts = Post.incoming_posts(true)
            @popular_sites = Site.popular(30)
            @top_winkers = User.most_active(10)
            @newest_sites = Site.latest(20)
            @users, @winks, @posts = User.count, Wink.count, Post.count
            render :onslaught, 'onslaught of the hoodwink.d underground', :index
        end
    end
    class OnslaughtSearch < R '/onslaught/search'
        def get
            render :onslaught, 'search', :search
        end
        def post
            @search_title, @winks = Wink.search_for @input.q
            render :onslaught, "hoodwink.d: #{@search_title}", :search
        end
    end
    class OnslaughtSearchXml < R '/onslaught/search.xml'
        def get
            @search_title, @winks = Wink.search_for @input.q, 20
            @headers['Content-Type'] = 'text/xml'
            onslaught_search_xml
        end
    end
end

module Hoodwinkd::Views
    def onslaught(t, p)
        html do
        @auto_validation = false
        head do
            title t
            style <<-END, :type => 'text/css'
                @import '#{R(Static, 'css', 'winker.css')}';
                @import '#{R(Static, 'css', 'winksum.css')}';
                @import '#{R(Static, 'css', 'onslaught.css')}';
                .hoodwinkSummary { visibility: hidden; }
            END
            script :type => "text/javascript", :src => R(Static, 'js', 'perfecttime.js')
        end
        body do
            div.page! do
                menu
                __send__("onslaught_#{p}")
            end
        end
        end
    end

    def onslaught_index
        div.header! do
            h3 "#{n @users} winkers with"
            h1 "#{n @winks} winks"
            h2 "on #{n @posts} blogposts"
            form :name => "searchForm", :method => "post", :action => R(OnslaughtSearch) do
                label "search:", :for => "q"
                div.search! do
                    input.q! :type => "text"
                    a :href => "javascript:document.forms['searchForm'].submit();" do
                        img :src => "/i/onslaught-arrow.png", :border => "0"
                    end
                end
            end
        end
        div.sidebar! do
            self << %{
                <h2>recent stuff <a href="http://hoodwink.d/onslaught/latest-posts.xml"><img src="/i/feed-icon-12x12.png" border="0" /></a></h2>
                <p style="margin: 0px 2px 4px 2px; color: #999; font-size: 7pt;">hoodwink.d and wasteland winks have <a href="#meta-discussion">moved</a>.</p>
            }
            onslaught_posts @recent_posts
        end
        div.board do
            h2 "we're canvasing over"
            ul do
                ct = 1
                @popular_sites.each_with_index do |site, ct|
                    li do
                        div.summary do
                            a site.domain, :href => "/#{site.domain}"
                            div.detail do
                                div.winks site.all_winks
                                div.fade "#{site.all_posts} posts"
                            end
                        end
                    end
                end
            end
        end
        div.wide.board do
            h2 "with the help of"
            ol do
                @top_winkers.each_with_index do |winker, ct|
                    li do
                        div.summary do
                            a winker.login, :href => "/#{winker.login}"
                        end
                        div.detail do
                            if winker.all_winks == winker.new_winks
                                div.winks winker.all_winks
                            else
                                div.winks winker.new_winks
                                div.fade winker.all_winks
                            end
                        end
                    end
                end
            end
            h2 do
                self << "and fresh sites even "
                a(:href => "/onslaught/newest-sites.xml") { img :src => "/i/feed-icon-12x12.png" }
            end
            ul do
                @newest_sites.each do |site|
                    li { div.summary { a site.domain, :href => site.link }
                         div.detail { div.fade { self << "added on #{js_time site.created_at}" } } }
                end
            end
        end
        br :clear => "both"
        div.footer! do
            a :name => "meta-discussion"
            div.box do
                h2 "meta discussion"
                onslaught_posts @meta_posts
            end
            br :clear => "both"
        end
    end

    def onslaught_posts(posts)
        ul do
            posts.each_with_index do |post, ct|
                li do
                    div.summary.__send__(ct > 7 ? :mini : :full) do
                        div.wink do
                            title = post['title'].gsub( /\b\S{28,}\b/ ) { |word| word[0,26] + "&#8230;" }
                            a.permalink(:href => "http://#{post.real_domain}#{post.permalink}"){self<<title}
                            text " <nobr>by #{a post.login, :href => "/#{post.login}"}</nobr>"
                        end
                    end
                    div.date { js_time post.last_created_at }
                    div.detail do
                        if post.wink_count == post.new_winks
                            div.winks post.wink_count
                        else
                            div.winks post.new_winks
                            div.fade "#{post.wink_count} total"
                        end
                    end
                end
            end
        end
    end

    def onslaught_search_xml
        rss2_0 do |c|
            c.title "hoodwink'd .. #{ @search_title }"
            c.link "http://hoodwink.d/onslaught/search?q=#{ @input.q }"
            c.description "together we are unintentionally making a perfect shark shadow on the basement wall!"
            @winks.each do |post|
            c.item do |item|
                link = "http://#{ post.real_domain }#{ post.permalink }#wink-#{ post.id }"
                item.title post.title
                item.link link
                item.guid "wink-#{ post.id }@http://hoodwink.d", "isPermaLink" => false
                item.dc :creator, post.login
                item.dc :date, post.created_at
                item.description post.comment_html
            end
            end
        end
    end

    def onslaught_search
        div.header! do
            h3 "your search results for"
            h2 @search_title
            form :name => "searchForm", :method => "post" do
                label 'search:', :for => 'q'
                div.search! do
                    input.q! :type => 'text', :value => @input.q
                    a(:href => "javascript:document.forms['searchForm'].submit();") do
                        img :src => '/i/onslaught-arrow.png'
                    end
                end
            end
        end
        div.results! do
            h2 { self << "Matching Winks ";
                a(:href => R(OnslaughtSearchXml) + "?#{@input.q}") { img :src => '/i/feed-icon-24x24.png' } }
            ul do
            @winks.each do |post|
                li { div.summary { a post.title, :href => "http://#{post.real_domain}#{post.permalink}" }
                     div.detail { div.winks post.wink_count }
                     div.attrib { strong post.login; self << " said on #{js_time post.created_at}" }
                     div.body { self << post.comment_html } }
            end
            end
        end
    end
end
