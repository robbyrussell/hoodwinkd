
module Hoodwinkd::Controllers
    class DialSite < R "/dial/site", "/dial/site/(#{DOMAIN})"
        def load(domain)
            @site = Site.find_by_domain(domain, :include => :layers) || Site.new(:domain => domain)
            if @site.layers
                @layer = @site.layers[0]
            end
            @layer ||= Layer.new(:name => 'Root')
        end
        def get(domain)
            self.load(domain)
            render :dial, "editing #{domain}", :site
        end
        def post(domain)
            self.load(domain)
            if @site.creator_id.to_i.zero?
                @site.creator_id = @user.id
            end
            if @site.save
                @input.layer.update(:site_id => @site.id)
                @layer.update_attributes(@input.layer)
            end
            render :dial, "editing #{domain}", :site
        end
    end

    class DialWelcome < R '/dial/welcome'
        def get
            render :dial, "welcome, #{@user.login}", :welcome
        end
    end

    class DialProfile < R '/dial/profile'
        def get
            render :dial, "profile for #{@user.login}", :profile
        end
        def post
            if @input.profile.password.blank? and @input.profile.password_confirmation.blank?
                ["password", "password_confirmation"].each {|k| @input.profile.delete(k)}
            end
            @user.attributes = @input.profile
            if @user.valid? and not @input.profile.password.blank?
                @user.password = encrypt(@user.security_token, @input.profile.password)
                @user.password_confirmation = nil
            end
            if @user.save
                render :dial, "saved profile", :saved_profile
            else
                get
            end
        end
    end

    class DialSites < R '/dial/sites'
        def get
            @site_list = Site.find :all
            render :dial, 'all sites', :sites
        end
    end

    class DialUserJs < R '/dial/hoodwinkd.user.js'
        def get
            @headers['Content-Type'] = 'text/javascript'
            ::ERB.new( File.read("#{STATIC}/src/hoodwinkd.user.js") ).result(binding)
        end
    end

    class DialLogout < R '/dial/logout'
        def get
            @state.clear
            redirect DialHome
        end
    end

    class DialHome < R '/', '/dial'
        def get
            if @user.login.blank?
                render :dial, "login", :home
            else
                redirect DialWelcome
            end
        end
    end

    class DialLogin < R '/dial/login'
        def post
            user = User.find_by_login @input.login
            if user
                if @input.fgot
                    send_password_reminder_to user
                elsif @input.password == decrypt( user.security_token, user.password )
                    @user = user
                    @state.user_id = @user.id
                    return redirect(DialWelcome)
                else
                    @user.errors.add(:password, 'is incorrect')
                end
            else
                @user.errors.add(:login, 'not found')
            end
            render :dial, "login", :login
        end
    end

    class DialRegister < R '/dial/register'
        def post
            @user = User.new @input.register
            if @user.valid?
                @user.security_token = Hash.rand
                @user.password = encrypt(@user.security_token, @user.password)
                @user.password_confirmation = nil
                @user.save!
                @state.user_id = @user.id
                redirect DialWelcome
            else
                render :dial, "register", :register
            end
        end
    end
end

module Hoodwinkd::Views
    def dial(str, view)
        html do
            @auto_validation = false
            head do
                title { "the winker's satellite office &raquo; " + str }
                script :language => 'javascript', :src => R(Static, 'js', 'prototype.js')
                script :language => 'javascript', :src => R(Static, 'js', 'support.js')
                style "@import '#{self / R(Static, 'css', 'dial.css')}';", :type => 'text/css'
            end
            body do
                div.shade! do
                    div.header! do
                        unless @user.login.blank?
                        div.menu do
                            ul do
                                li { a 'welcome', :href => R(DialWelcome) }
                                li { a 'profile', :href => R(DialProfile) }
                                li { a 'sites',   :href => R(DialSites)   }
                                li { a 'user.js', :href => R(DialUserJs)  }
                                # li { a 'user.rb', :href => R(DialUserRb)  }
                                li { a 'logout',  :href => R(DialLogout)  }
                            end
                        end
                        end
                    end
                    div.content! do
                        __send__ "dial_#{view}"
                    end
                end
            end
        end
    end

    def dial_home
        dial_loginform
        dial_regform
    end

    def dial_login
        dial_loginform
    end

    def dial_register
        dial_regform
    end

    def dial_sites
        div.currentSites! do

        form :action => R(DialSites), :method => 'post' do
            h1 "Wink'd Sites"
            p "Here's a list of sites which are all set up, ready to wink."
            ul do
                select.site_name! do
                    unless @site_list.empty?
                        option '>> sites you added <<', :value => ''
                        @site_list.each do |s|
                            option s.domain, :value => s.domain
                        end
                    else
                        option '-- no sites yet --', :value => ''
                    end
                end
                a 'edit', :class => 'button', :href => 'javascript:void(0)', :onClick =>
                    "window.location='" + R(DialSite) + "/'+$F('site_name')"
            end
        end

        script <<-END, :language => 'javascript'
            function editDomain() {
                var domain = $F('domain');
                domain = domain.replace( /^www\.(.*)$/, '$1' );
                window.location = "#{URL('/dial/site/')}"+domain;
                return false;
            }
        END

        h1 "New Site"
        p "Enter the name of a new site here.  If the site exists, no problem, you'll
           just go straight to the edit page anyway."
        form(:method => 'post', :onSubmit => 'return editDomain();') do
            fieldset.unruled do
                div.required do
                    label 'Site Host:', :for => 'domain'
                    input.domain! :type => 'text'
                    small { red "Domain or subdomain without 'www.': *boingboing.net*, *weblog.rubyonrails.com*" }
                end
                input.editgo! :type => 'submit', :value => "Add Site"
            end
        end

        end
    end

    def dial_site
        div.currentSites! do
            h1 "Edit Site Settings"
            dial_siteform
        end
        div.pendingSites! do
            h1 "The Druid's Manual"
            p "Hello, doing the regexps is easy.  Doing the XPath is a bit harder."
    
            h2 "Regexp Help"
            self << red(%q{
                <dl>
                <dt>@/|/index\.html@</dt>
                <dd>Matches @/@ or @/index.html@.</dd>
                <dt>@/|/(archives|links|ext)/index\.html@</dt>
                <dd>Matches @/@ or @/archives/index.html@ or @/links/index.html@ or @/ext/index.html@.</dd>
                <dt>@/users/\w+/?@</dt>
                <dd>Matches anything in the @/users/@ directory with a page name that contains only alphanumeric characters or an underscore.  Also can have an optional ending slash.</dd>
                </dl>
                <h2>XPath Help</h2>
                <dl><dt>@//div@</dt>
                <dd>Find all @div@ elements on the page.</dd>
                <dt><code>//td[@class='comments']</code></dt>
                <dd>Finds all @td@ elements which only have one class called @comments@.</dd>
                <dt><code>//td[contains(@class,'comments')]</code></dt>
                <dd>Find all @td@ elements whose classes contain the word @comments@.</dd>
                <dt>@//*@</dt>
                <dd>Find all elements on the page.</dd>
                <dt>@//*[contains('h1,h2,h3,h4,h5,h6',name)]@</dt>
                <dd>A hack for finding any header elements on the page.</dd>
                <dt>@a@</dt>
                <dd>Find the @a@ link tags within an element.</dd>
                <dt><code>a[starts-with(@href,'http://boingboing.net/')]</code></dt>
                <dd>Find all @a@ link tags within an element whose @href@ attribute starts with @http://boingboing.net/@.</dd>
                </dl>
            })
        end
    end

    def dial_loginform
        form :action => R(DialLogin), :method => 'post' do
            self << red(<<-END)
                h1. Login

                Wonderful!  Now you have your own *Hoodwink.d* satellite office, a branch of 
                the underground mumbler's club.
            END
            errors_for @user
            fieldset.login do
                div.required do
                    label 'Login:', :for => 'login'
                    input.login! :type => 'text'
                end
                div.required do
                    label 'Password:', :for => 'password'
                    input.password! :type => 'password'
                end
                input.loggo! :type => 'submit', :value => "Login"
            end
        end
    end

    def dial_welcome
        script :type => "text/javascript", :src => "/js/perfecttime.js"
        self << red(<<-END)
            h1. Welcome, #{@user.login}

            You joined winkerland on <notextile>#{js_time @user.created_at, 'Day'}</notextile>.

            Hoodwink.d is a travelling commentary overlay.  When you visit blogs and websites which have
            been dialed into Hoodwink.d, you'll see the commentary of your fellow winkers.  You are
            currently logged into a sattelite office, a subsect of winkers.  For information about
            the central Hoodwink.d conduits, hit the "hoodwink.d information 
            booth":http://hoodwinkd.hobix.com.

            h1. Setting up

            Currently, the best way to use Hoodwink'd is through Greasemonkey.  Here's how:

            # Install "Firefox":http://mozilla.org.
            # Install the latest "Greasemonkey":http://greasemonkey.mozdev.org.
            # Install the Hoodwink'd user script by:
            ** Clicking on *user.js* above.
            ** In Firefox, go to the *Tools* menu, then *Install This User Script...*.
            # Surf to "Boing Boing":http://boingboing.net and see if the winks are showing up at the bottom of each post.
        END
    end

    def dial_saved_profile
        self << red(<<-END)
            h1. Your Profile is Saved

            Thankyou, #{@user.login}.  Your changes have been saved.
        END
    end

    def dial_profile
        h1 "Your Profile"
        form :action => R(DialProfile), :method => 'post' do
            errors_for @user
            fieldset.login do
                div.required do
                    n = 'profile[password]'
                    label 'Password:', :for => n
                    input :id => n, :name => n, :type => 'password'
                end
                div.required do
                    n = 'profile[password_confirmation]'
                    label 'Password again:', :for => n
                    input :id => n, :name => n, :type => 'password'
                end
                div.required do
                    n = 'profile[email]'
                    label 'Email:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.email
                end
                div.optional do
                    h3 "Theme Settings"
                    p "To take effect, you will need to re-install your user script upon altering these."
                    n = 'profile[theme_url]'
                    label 'Theme URL:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.theme_url
                    small { red %{The web address to a folder containing the theme templates.
                       See "here":http://wasteland.hobix.com/The%20Now/Hoodwink.d%201.6%20is%20Here
                       for howto make a theme.} }
                end
                div.optional do
                    n = 'profile[theme_css]'
                    label 'Theme CSS:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.theme_css
                    small { red %{If you'd like to override just the CSS for the above theme or the default hoodwink.d theme.} }
                end
                div.optional do
                    n = 'profile[nameplate]'
                    label 'Nameplate:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.nameplate
                    small { red %{Rather than an avatar, a background for your name in the wink box.} }
                end
                div.optional do
                    n = 'profile[namehue]'
                    label 'Name hue:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.namehue
                    small { red %{A hex coloring for your name.} }
                end
                input.submit_new! :type => 'submit', :value => "Save"
            end
        end
    end

    def dial_regform
        form :action => R(DialRegister), :method => 'post' do
            self << red(<<-END)
                h1. Register

                If you lack an account, sign up for a new account below.
            END
            errors_for @user
            fieldset.login do
                div.required do
                    n = 'register[login]'
                    label 'Login:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.login
                end
                div.required do
                    n = 'register[password]'
                    label 'Password:', :for => n
                    input :id => n, :name => n, :type => 'password', :value => @user.password
                end
                div.required do
                    n = 'register[password_confirmation]'
                    label 'Password again:', :for => n
                    input :id => n, :name => n, :type => 'password'
                end
                div.required do
                    n = 'register[email]'
                    label 'Email:', :for => n
                    input :id => n, :name => n, :type => 'text', :value => @user.email
                end
                input.rego! :type => 'submit', :value => "Register"
            end
        end
    end

    def dial_siteform
        form :method => 'post' do
            # input :name => 'site[id]', :type => 'hidden', :value => @site.id
            fieldset.unruled do
                h2 "Site Host: #{@site.domain}"
                errors_for @layer
            # end
            # fieldset do
            #     legend "Borrow Site Settings?"
            #     div.optional do
            #         label 'Mimicks:', :for => 'master_site'
            #         select :name => 'site[linked_site]', :onChange => 'toggleLayers(this.form, this.options[this.selectedIndex].value)' do
            #             option '-- none --', :value => '0'
            #             @master_sites.each do |s|
            #                 option s.id, :value => s.domain
            #             end
            #         end
            #         small { red "_Borrow another site's configuration?_" }
            #     end
            #     div.optional do
            #         label 'Alias?', :for => 'alias'
            #         input :type => 'checkbox', :name => 'alias', :value => '1' 
            #         small { red "_Aliases are domains pointing to a blog already wink'd._" }
            #     end
            # end
            # fieldset do
            #    legend "Site Layers"
            #    red "Please note: these settings _will not be saved_ if you are using the \
            #         mimickry dropdown above."
            #     div.settingTabs! do
            #         h3 "Select:"
            #         ul.site_layers! do
            #             @site.layers.each_with_index do |l, i|
            #                 li.off :id => "site_setting_#{i}" do
            #                     a l.name, :href => "javascript:editLayer(#{i});"
            #                 end
            #             end
            #             li :id => "site_setting_add" do
            #                 a "+", :href => "javascript:addLayer();"
            #             end
            #         end
            #     end
            #     red %{You may add several wink layers for each blog.  Winks for each of these will 
            #           act independantly.  Typically, you'll want the *Root* layer to handle the site's 
            #           home page.  Wink layers for the same blog may coexist.}
                div.optional do
                    label 'Full Post URL Regexp:', :for => 'layer[fullpost_url_match]'
                    input :type => 'text', :name => 'layer[fullpost_url_match]', :value => @layer.fullpost_url_match
                    small { red "Describe the regexp for the a post's permanent URL.  Regexp is not partial,
                                 beginning and end markers are implied.
                                 Example: @/\d+/\d+/\d+/[\w-]+\.html@." }
                end
                div.optional do
                    label 'Full Post Query Variables:', :for => 'layer[fullpost_qvars]'
                    input :type => 'text', :name => 'layer[fullpost_qvars]', :value => @layer.fullpost_qvars
                    small { red "List any query string variables (names separated by commas) which 
                                 are essential in forming a permalink.
                                 Example: @id, site@." }
                end
                div.optional do
                    label 'Full Post XPath:', :for => 'layer[fullpost_xpath]'
                    input :type => 'text', :name => 'layer[fullpost_xpath]', :value => @layer.fullpost_xpath
                    small { red "Paths to element into which the hoodwinks will be injected.  
                                 Often this will just be the element containing the post itself.  
                                 *Hoodwinks will be injected into the end of the element.*
                                 Example: <code>//div[@class='entry']</code>" }
                end
                div.optional do
                    label 'Inline CSS:', :for => 'layer[css]'
                    textarea @layer.css, :name => 'layer[css]'
                    small { red %{Per-site CSS.  If the site has ads, see if you can ripoff some CSS from
                                "Greasemonkeyed":http://greasemonkeyed.com/.  *No HTML in here!*  (And keep
                                the CSS short, it gets transferred on every request.)} }
                end
            end
            input.submit_new! :type => 'submit', :value => 'save'
        end
    end
end
