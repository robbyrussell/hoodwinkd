require 'digest/md5'
require 'json/objects'
require 'open-uri'

module Hoodwinkd::Models
    def self.schema(&block)
        @@schema = block if block_given?
        @@schema
    end

    class Base
      def self.validates_uri_format_of(*attr_names)
        configuration = { :message => "is not a valid web address" }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each attr_names do |m, a, v|
          next if v.blank?
          begin
            # Try to open the URI
            if URI(v).scheme != "http"
              m.errors.add(a, "is not an HTTP address")
            end
          rescue
            # Report the error if it throws an exception
            m.errors.add(a, configuration[:message])
          end
        end
      end
    end

    class Session < Base
        belongs_to :user
        serialize :ivars

        def self.generate(cookies)
            s = Session.create :hashid => Hash.rand
            cookies.hoodwinkd_sid = s.hashid
            s
        end
        def []=(k, v)
            self.ivars ||= {}
            self.ivars[k] = v
        end
        def [](k)
            self.ivars[k] rescue nil
        end
    end

    class Hash < Base
        def self.replenish
            if count('used_at IS NULL') < 100
                open( "http://random.org/cgi-bin/randbyte?nbytes=4096&format=hex" ) do |f|
                    f.each do |line|
                        Hash.create :hashid => line.gsub( /\s+/, '' )
                    end
                end
            end
        end
        def self.reserve
            replenish
            hash = find :first, :conditions => "used_at IS NULL", :limit => "LIMIT 1"
            hash.update_attributes( :used_at => Time.now )
            hash
        end
        def self.rand
            replenish
            hash = find :first, :conditions => "used_at IS NULL", :limit => "LIMIT 1"
            hash.destroy
            hash.hashid
        end
    end

    class Site < Base
        belongs_to :creator, :foreign_key => 'creator_id',
            :class_name => 'User'
        has_one :linked_site, :class_name => self.name
        has_many :layers
        validates_uniqueness_of :domain
        validates_presence_of :domain
        def link
            "http://#{real_domain || domain}/"
        end
        def recent_posts(count)
            Post.find_by_sql [%{
                SELECT p.*, w.*, u.login
                FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s, 
                     hoodwinkd_winks w, hoodwinkd_users u 
                WHERE p.layer_id = l.id AND l.site_id = s.id AND p.last_wink_id = w.id
                  AND w.user_id = u.id AND s.id = ?
                ORDER BY w.created_at DESC LIMIT ?}, self.id, count]
        end
        def popular_posts(count)
            Post.find_by_sql [%{
                SELECT p.*, w.*, u.login
                FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s, 
                     hoodwinkd_winks w, hoodwinkd_users u 
                WHERE p.layer_id = l.id AND l.site_id = s.id AND p.last_wink_id = w.id
                  AND w.user_id = u.id AND s.id = ?
                ORDER BY p.wink_count DESC LIMIT ?}, self.id, count]
        end
        def top_winkers(count)
            Post.find_by_sql [%{
                SELECT u.login, COUNT(*) AS wink_count 
                FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s, 
                     hoodwinkd_winks w, hoodwinkd_users u 
                WHERE p.layer_id = l.id AND l.site_id = s.id AND p.last_wink_id = w.id
                  AND w.user_id = u.id AND s.id = ?
                GROUP BY u.id ORDER BY wink_count DESC LIMIT ?}, self.id, count]
        end
        def self.popular(count)
            find_by_sql %{
                SELECT s.domain, s.real_domain,
                       COUNT(p.id) AS all_posts, SUM(p.wink_count) AS all_winks
                FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s 
                WHERE p.layer_id = l.id AND l.site_id = s.id AND s.enabled = 1
                GROUP BY s.id ORDER BY all_winks DESC LIMIT #{count.to_i}
            }
        end
        def self.latest(count)
            find_by_sql %{
                SELECT s.*, u.login, s.created_at
                FROM hoodwinkd_sites s, hoodwinkd_users u, hoodwinkd_layers l, hoodwinkd_posts p
                WHERE s.enabled = 1 AND s.creator_id = u.id AND l.site_id = s.id AND p.layer_id = l.id
                  AND p.layer_id IS NOT NULL
                GROUP BY s.id ORDER BY s.created_at DESC, s.id ASC LIMIT #{count.to_i}
            }
        end
    end
    class AliasedSite < Site; end
    class LinkedSite < Site; end
    class GlobbedSite < Site; end
    class TemplateSite < Site; end

    class Layer < Base
        belongs_to :site
        has_many :posts
        validates_uniqueness_of :name, :scope => 'site_id'
        validates_presence_of :name
    end

    class User < Base
        has_one  :session
        has_many :sites
        has_many :winks
        validates_uniqueness_of :login
        validates_uniqueness_of :email
        validates_confirmation_of :password
        validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
        validates_format_of :login, :with => /^[\w\-]+$/, 
            :message => "should be letters, nums, dash, underscore only."
        validates_uri_format_of :nameplate 
        validates_format_of :namehue, :with => /^(\#?[A-Fa-f0-9]+)?$/, 
            :message => "should be in hex format."
        def recent_winks(count)
            Wink.find_by_sql [%{
                SELECT w.*, p.title, s.domain, IFNULL(s.real_domain, s.domain) AS real_domain,
                       p.permalink, p.wink_count, s.domain
                FROM hoodwinkd_winks w, hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s
                WHERE w.post_id = p.id AND p.layer_id = l.id AND l.site_id = s.id AND w.user_id = ?
                  AND s.enabled = 1 ORDER BY w.created_at DESC LIMIT ?}, self.id, count]
        end
        def recent_posts(count)
            Post.find_by_sql [%{
                SELECT p.*, s.domain, IFNULL(s.real_domain, s.domain) AS real_domain
                FROM hoodwinkd_winks w, hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s
                WHERE w.post_id = p.id AND p.layer_id = l.id AND l.site_id = s.id AND w.user_id = ?
                  AND s.enabled = 1 AND w.created_at > ?
                  GROUP BY p.id ORDER BY w.created_at DESC
                }, self.id, Time.now - 1.week]
        end
        def self.most_active(count)
            find_by_sql %{
                SELECT u.login, u.created_at, COUNT(*) AS all_winks,
                SUM(w.created_at > NOW() - INTERVAL 1 DAY) AS new_winks 
                FROM hoodwinkd_users u, hoodwinkd_winks w 
                WHERE u.id = w.user_id 
                GROUP BY u.id ORDER BY new_winks DESC, all_winks DESC LIMIT #{count.to_i}
            }
        end
    end

    class Wink < Base
        belongs_to :post
        belongs_to :user
        validates_presence_of :comment_plain
        def self.recent(count)
            find_by_sql %{
                SELECT w.*, s.domain, p.permalink, u.login,
                       IF(p.title != '', p.title, s.domain) AS title
                FROM hoodwinkd_winks w, hoodwinkd_layers l, hoodwinkd_posts p, hoodwinkd_sites s, hoodwinkd_users u 
                WHERE w.post_id = p.id AND p.layer_id = l.id AND l.site_id = s.id AND w.user_id = u.id 
                  AND s.enabled = 1
                ORDER BY w.created_at DESC LIMIT 20
            }
        end
        def self.search_for terms, limit = 20, start = 0
            # special search options
            terms = "your search terms" if terms.to_s.strip.empty?
            search = {}
            joins, conditions = [], []
            users = ::Hash.new do |hsh, login|
                hsh[login] = User.find_by_login login
            end
            terms = terms.split( /\s+/ )
            terms.delete_if do |term|
                term.gsub!(/^~who:/, 'anywho:')
                term.gsub!(/^-who:/, 'notwho:')
                if term =~ /^(anywho|notwho|who|site):/
                    (search[$1] ||= []) << $'
                end
            end
            # form the query
            if search['who']
                conditions << "u.id IN (" + search['who'].map { |u| users[u].id }.join(', ') + ")"
            end
            if search['notwho']
                conditions << "u.id NOT IN (" + search['notwho'].map { |u| users[u].id }.join(', ') + ")"
            end
            if search['anywho']
                i = joins.length
                joins << ", hoodwinkd_winks w#{i}"
                conditions << "w#{i}.post_id = p.id AND w#{i}.user_id IN (" + 
                    search['anywho'].map { |u| users[u].id }.join(', ') + ")"
            end
            if search['site']
                conditions << "s.domain IN (" + search['site'].map { |x| quote(x) }.join(', ') + ")"
            end
            unless terms.empty?
                search['terms'] = terms.join ' '
                conditions << "match(w.comment_html) AGAINST (%s)" % [quote( search['terms'] )]
            end
            conditions = conditions.join(' AND ')
            conditions << " GROUP BY w.id ORDER BY w.created_at DESC"
            conditions << " LIMIT %d, %d" % [start, limit] if limit
            sqlq = "SELECT w.*, p.permalink, p.wink_count, s.domain, 
                    IFNULL(s.real_domain, s.domain) AS real_domain, u.login, p.title
                    FROM hoodwinkd_winks w, hoodwinkd_posts p, hoodwinkd_layers l,
                         hoodwinkd_sites s, hoodwinkd_users u %s
                    WHERE w.post_id = p.id AND p.layer_id = l.id AND l.site_id = s.id AND w.user_id = u.id AND s.enabled = 1
                      AND %s" % [joins * ' ', conditions]
            res = find_by_sql(sqlq)
            name = "winks "
            name << "by #{ search['who'].join ' or ' } " if search.has_key? 'who'
            name << "in threads with #{ search['anywho'].join ' or ' } " if search.has_key? 'anywho'
            name << "excluding #{ search['notwho'].join ' or ' } " if search.has_key? 'notwho'
            name << "on #{ search['site'].join ' or ' } " if search.has_key? 'site'
            name << "matching `#{ search['terms'] }'" if search.has_key? 'terms'
            [name.strip, res]
        end 
    end

    class Post < Base
        belongs_to :layer
        has_many :winks
        has_one :first_wink, :class_name => Wink.name, :foreign_key => 'first_wink_id'
        has_one :last_wink, :class_name => Wink.name, :foreign_key => 'last_wink_id'
        validates_uniqueness_of :permalink, :scope => 'layer_id'
        def self.incoming_posts(meta)
            find_by_sql %{
                SELECT s.domain, IFNULL(s.real_domain, s.domain) AS real_domain,
                    p.permalink, p.wink_count, MAX(w.created_at) AS max_date,
                    IF(p.title != '', p.title, s.domain) AS title, u.login,
                    SUM(w.created_at > NOW() - INTERVAL 1 DAY) AS new_winks,
                    UNIX_TIMESTAMP(MAX(w.created_at)) AS last_created_at
                FROM hoodwinkd_posts p, hoodwinkd_layers l, hoodwinkd_sites s, 
                    hoodwinkd_winks w, hoodwinkd_winks w2, hoodwinkd_users u
                WHERE p.layer_id = l.id AND l.site_id = s.id AND w.post_id = p.id 
                    AND w2.id = p.last_wink_id AND w2.user_id = u.id
                    AND s.id #{meta ? 'IN' : 'NOT IN'} (164, 295) AND s.enabled = 1
                GROUP BY p.id ORDER BY max_date DESC LIMIT 18
            }
        end
    end
end

Hoodwinkd::Models.schema do
    create_table :hoodwinkd_hashes do |t|
        t.column :id,         :integer, :null => false
        t.column :hashid,     :string,  :limit => 32
        t.column :used_at,    :datetime
    end
    create_table :hoodwinkd_posts do |t|
        t.column :id,         :integer, :null => false
        t.column :layer_id, :integer, :null => false
        t.column :permalink,  :string,  :limit => 192, :null => false
        t.column :wink_count, :integer
        t.column :created_at, :datetime
        t.column :title,      :string,  :limit => 192
        t.column :first_wink_id, :integer
        t.column :last_wink_id,  :integer
    end
    create_table :hoodwinkd_sessions do |t|
        t.column :id,          :integer, :null => false
        t.column :user_id, :integer
        t.column :hashid,      :string,  :limit => 16
        t.column :created_at,      :datetime
        t.column :ivars,           :text
    end
    create_table :hoodwinkd_sites do |t|
        t.column :id,          :integer, :null => false
        t.column :creator_id,  :integer, :null => false
        t.column :domain,      :string,  :limit => 64
        t.column :real_domain, :string,  :limit => 64
        t.column :type,        :string,  :limit => 16
        t.column :linked_site, :integer
        t.column :created_at,  :datetime
        t.column :enabled,     :boolean, :default => 1
    end
    add_index :hoodwinkd_sites, :domain, :unique
    create_table :hoodwinkd_layers do |t|
        t.column :id,          :integer, :null => false
        t.column :site_id, :integer, :null => false
        t.column :name,        :string,  :limit => 32
        t.column :fullpost_xpath,      :string, :limit => 96
        t.column :fullpost_url_match,  :string, :limit => 192
        t.column :fullpost_qvars,      :string, :limit => 32
        t.column :css,         :text
    end
    create_table :hoodwinkd_users do |t|
        t.column :id,             :integer, :null => false
        t.column :login,          :string,  :limit => 32
        t.column :password,       :string,  :limit => 40
        t.column :email,          :string,  :limit => 64
        t.column :theme_url,      :string,  :limit => 80
        t.column :theme_css,      :string,  :limit => 80
        t.column :nameplate,      :string,  :limit => 80
        t.column :namehue,        :string,  :limit => 8
        t.column :security_token, :string,  :limit => 40
        t.column :created_at,     :datetime
        t.column :activated_at,   :datetime
        t.column :deleted,        :integer, :default => 0
    end
    add_index :hoodwinkd_users, :login, :unique
    add_index :hoodwinkd_users, :email, :unique
    create_table :hoodwinkd_winks do |t|
        t.column :id,             :integer, :null => false
        t.column :post_id, :integer, :null => false
        t.column :user_id, :integer, :null => false
        t.column :created_at,     :datetime
        t.column :comment_plain,  :text
        t.column :comment_html,   :text
    end
end
