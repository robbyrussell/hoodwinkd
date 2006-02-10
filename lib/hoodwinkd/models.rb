require 'digest/md5'
require 'json/objects'
require 'open-uri'

module Hoodwinkd::Models
    def self.schema(&block)
        @@schema = block if block_given?
        @@schema
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
    end
    class AliasedSite < Site; end
    class LinkedSite < Site; end
    class GlobbedSite < Site; end
    class TemplateSite < Site; end

    class Layer < Base
        belongs_to :site
        has_many :posts
        validates_uniqueness_of :name, :scope => 'hoodwinkd_site_id'
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
    end

    class Wink < Base
        belongs_to :post
        belongs_to :user
    end

    class Post < Base
        belongs_to :layer
        has_many :winks
        has_one :first_wink, :class_name => Wink.name
        has_one :last_wink, :class_name => Wink.name
        validates_uniqueness_of :permalink, :scope => 'hoodwinkd_site_id'
    end
end

Hoodwinkd::Models.schema do
    create_table :hoodwinkd_hashes, :force => true do |t|
        t.column :id,         :integer, :null => false
        t.column :hashid,     :string,  :limit => 32
        t.column :used_at,    :datetime
    end
    create_table :hoodwinkd_posts, :force => true do |t|
        t.column :id,         :integer, :null => false
        t.column :hoodwinkd_layer_id, :integer, :null => false
        t.column :permalink,  :string,  :limit => 192, :null => false
        t.column :winks,      :integer
        t.column :created_at, :datetime
        t.column :title,      :string,  :limit => 192
        t.column :first_wink, :integer, :null => false
        t.column :last_wink,  :integer, :null => false
    end
    create_table :hoodwinkd_sessions, :force => true do |t|
        t.column :id,          :integer, :null => false
        t.column :hoodwinkd_user_id, :integer
        t.column :hashid,      :string,  :limit => 16
        t.column :created_at,      :datetime
        t.column :ivars,           :text
    end
    create_table :hoodwinkd_sites, :force => true do |t|
        t.column :id,          :integer, :null => false
        t.column :creator_id,  :integer, :null => false
        t.column :domain,      :string,  :limit => 64
        t.column :type,        :string,  :limit => 16
        t.column :linked_site, :integer
        t.column :created_at,  :datetime
        t.column :enabled,     :boolean, :default => 1
    end
    add_index :hoodwinkd_sites, :domain, :unique
    create_table :hoodwinkd_layers, :force => true do |t|
        t.column :id,          :integer, :null => false
        t.column :hoodwinkd_site_id, :integer, :null => false
        t.column :name,        :string,  :limit => 32
        t.column :fullpost_xpath,      :string, :limit => 96
        t.column :fullpost_url_match,  :string, :limit => 192
        t.column :fullpost_qvars,      :string, :limit => 32
        t.column :css,         :text
    end
    create_table :hoodwinkd_users, :force => true do |t|
        t.column :id,             :integer, :null => false
        t.column :login,          :string,  :limit => 32
        t.column :password,       :string,  :limit => 40
        t.column :email,          :string,  :limit => 64
        t.column :theme_url,      :string,  :limit => 80
        t.column :theme_css,      :string,  :limit => 80
        t.column :security_token, :string,  :limit => 40
        t.column :created_at,     :datetime
        t.column :activated_at,   :datetime
        t.column :deleted,        :integer, :default => 0
    end
    add_index :hoodwinkd_users, :login, :unique
    add_index :hoodwinkd_users, :email, :unique
    create_table :hoodwinkd_winks, :force => true do |t|
        t.column :id,             :integer, :null => false
        t.column :hoodwinkd_post_id, :integer, :null => false
        t.column :hoodwinkd_user_id, :integer, :null => false
        t.column :created_at,     :datetime
        t.column :comment_plain,  :text
        t.column :comment_html,   :text
    end
end
