function handleEvent(obj, event, func) {
    try {
        obj.addEventListener(event, func, false);
    } catch (e) {
        if (typeof eval("obj.on"+event) == "function") {
            var existing = obj['on'+event];
            obj['on'+event] = function () { existing(); func(); };
        } else {
            obj['on'+event] = func;                        
        }
    }
}   

function PerfectTime() {
    /* 
        Original implimentation by Why The Lucky Stiff
        <http://whytheluckystiff.net/>, described at:
        
        http://redhanded.hobix.com/inspect/showingPerfectTime.html
        
        Modified to fit in a single, unobtrusive javascript
        class by Mike West <http://mikewest.org/>
        
        I'm not sure what the original license chosen for this
        code was.  I'm assuming it's liberal enough, and this 
        class is released under the same license, whatever that
        turns out to be.
    */
        
    var self = this;
    
    self.defaultFormat = '<nobr>%d %b %Y</nobr> at <nobr>%H:%M</nobr>';
    
    self.format = (arguments[0])?arguments[0]:self.defaultFormat;
    
    self.strftime_funks = {
        zeropad: 
                function( n ){ return n>9 ? n : '0'+n; },
        a:      function(t) { return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()] },
        A:      function(t) { return ['Sunday','Monday','Tuedsay','Wednesday','Thursday','Friday','Saturday'][t.getDay()] },
        b:      function(t) { return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'][t.getMonth()] },
        B:      function(t) { return ['January','February','March','April','May','June', 'July','August', 'September','October','November','December'][t.getMonth()] },
        c:      function(t) { return t.toString() },
        d:      function(t) { return this.zeropad(t.getDate()) },
        H:      function(t) { return this.zeropad(t.getHours()) },
        I:      function(t) { return this.zeropad((t.getHours() + 12) % 12) },
        m:      function(t) { return this.zeropad(t.getMonth()+1) }, // month-1
        M:      function(t) { return this.zeropad(t.getMinutes()) },
        p:      function(t) { return this.H(t) < 12 ? 'AM' : 'PM'; },
        S:      function(t) { return this.zeropad(t.getSeconds()) },
        w:      function(t) { return t.getDay() }, // 0..6 == sun..sat
        y:      function(t) { return this.zeropad(this.Y(t) % 100); },
        Y:      function(t) { return t.getFullYear() },
        '%':    function(t) { return '%' }
    }
    self.strftime = function (theDate) {
        var fmt = self.format;
        for (var s in self.strftime_funks) {
            if (s.length == 1) {
                fmt = fmt.replace('%' + s, self.strftime_funks[s](theDate));
            }
        }
        return fmt;
    }
    
    
    self.instantiate = function () {
        var spans = document.getElementsByTagName('span');
        for (i=0, numSpans=spans.length; i < numSpans; i++) {
            if (spans[i].className == 'PerfectTime') {
                self.format = self.defaultFormat;
                self.processSpan(spans[i]);
            }
            else if (spans[i].className == 'PerfectTimeDay') {
                self.format = '<nobr>%B, %d %Y</nobr>';
                self.processSpan(spans[i]);
            }
        }
    }
    
    self.processSpan = function (theSpan) {
        var GMT = parseInt(theSpan.getAttribute('gmt_time')) * 1000;
        var newDate = new Date(GMT);
        theSpan.innerHTML = self.strftime(newDate);
    }
    
    handleEvent(window, 'load', self.instantiate);
}

var timeThing = new PerfectTime();

if (typeof(TrimPath) != 'undefined') {
    TrimPath.parseTemplate_etc.modifierDef.strftime = function (t, fmt) {
        return new Date(t).strftime(fmt);
    }
}
