module Hoodwinkd::Views
    def preview
        %{<html>
          <head>
            <title>Preview: #{ @domain }</title>
            <style type='text/css'>@import '/css/hoodwinkd.css';</style>
          </head>
          <body>
          <div id='hoodwinkFullposts'>
          <a name='hoodwinks'></a>
          <div class='hoodwinkHeader'>
          <div class='hoodwinkTotal'><p>Previewing your comment.</p>
          <p><a href='javascript:self.close();'>Click here</a> to close.</a></p></div>
          <div class='hoodwinkIcon'><img src='http://hoodwink.d/i/hoodwink-fullpost-icon.png' /></div>
          <h2 class='hoodwinkTitle'>hoodwink'd</h2></div><div class='hoodwinkContents'>
              <div class='hoodwinkPost'>
              <div class='hoodwinkAttrib'>
              <h3 class='hoodwinkAuthor'>#{ @user }</h3>
              <h4 class='hoodwinkTime'>said on #{ Time.now.strftime( "<nobr>%d %b %Y</nobr> at <nobr>%I:%M:%S %p</nobr>" ) }</h4></div> 
              <div class='hoodwinkContour'><div class='hoodwinkContent'>#{ html }</div></div></div>
          </div>
          </div>
          </body>
          </html>}
    end
end
