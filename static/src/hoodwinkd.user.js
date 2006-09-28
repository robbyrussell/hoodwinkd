//
//                                     .c( specially generated for <%= @user.login %> )o.
//              ,__--- -,-_..
//            ./             \\
//           .(  hoodwink'd  (|\
//            *) is all ready ))
//           .\   to go...   //
//             ^-.______.  ._/
//                       \<
//                        \;  , ,
//                          ( *=* )
//                         /)    /)
//                         ~ ^  ^
//                         
//                      
//                                 /(
//                              _.( \\
//                           ,''      `".
//                         ,' ..firefox.. ';
//                        .  Tools > Install ''.
//                       :  This User Script..  .
//                       `
//
//
//     .,.,,.,,,`,.,..,,,``,,..,,.,,,.,,,.,,.,.,`.,.,.,.,,, ,,
//
//       this script is designed for greasemonkey 0.5 and up
//
//
//
//
//
//
//
//
//

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//



//
//

//
//

//
//
//
//
//
//

//




//
//







//

//
//
//
//





//
//
//
//
//
//
//
//
//

//
//
//
//
//
//
// Andrey Semyonovich spat into a cup of water. The water immediately 
// turned black. Andrey Semyonovich screwed up his eyes and looked attentively 
// into the cup. The water was very black. Andrey Semyonovich's heart 
// began to throb.  At that moment Andrey Semyonovich's dog woke up. Andrey 
// Semyonovich went over to the window and began ruminating. 
//
//

//
//
//
//

//
//

// Suddenly something big and dark shot past Andrey Semyonovich's face 
// and flew out of the window. This was Andrey Semyonovich's dog flying out 
// and it zoomed like a crow on to the roof of the building opposite. 
// Andrey Semyonovich sat down on his haunches and began to howl. 

// Into the room ran Comrade Popugayev. 

//

// _What's up with you? Are you ill?_ -- asked Comrade Popugayev. 

// Andrey Semyonovich quietened down and rubbed his eyes with his hands. 

// Comrade Popugayev look a look into the cup which was standing on the table. 
// _What's this you've poured into here?_ -- he asked Andrey Semyonovich. 

// _I don't know_ -- said Andrey Semyonovich. 

// Popugayev instantly disappeared. The dog flew in through the window 
// again, lay down in its former place and went to sleep. 

// Andrey Semyonovich went over to the table and took a drink from the 
// cup of blackened water. And Andrey Semyonovich's soul turned lucent.

//
//
//
//                       - Daniil Kharms, 1934
//

//

//
//

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//     .,.,,.,,,`,.,..,,,``,,..,,.,,,.,,,.,,.,.,`.,.,.,.,,, ,,
//
//
//
// ==UserScript==
// @name          Hoodwink'd!! (on http:<%= self.URL %>)
// @namespace     http:<%= self.URL %>
// @description   Caulks the corners of blogs with discreet comment'ry.
// @include       http://*
// @version       1.9

// ==/UserScript ==

// CHANGELOG:
// - 1.9: live preview, nameplates, user.onLoad.
// - 1.8.2c: provide indexOf method for less than Firefox 1.5
// - 1.8.2b: minor fix, remove escaping from stripURL.
// - 1.8.2: greedy qvar operator
// - 1.8.1: sniff out the structure, the parentage, why not?
// - 1.8: simplified site setup, eliminating most of the xpaths.
// - 1.7: allow debugging template in a theme.
// - 1.6: wink html is now provided by external templates.
// - 1.5: allow multiple settings for each blog.
// - 1.4: summary button now situates itself right next to the permalink regardless of parentage.
//        query string variables are honored.  preview fixes.  allow comments on dial.
// - 1.3: preview button.
// - 1.2: per-site css injecting, eliminated http headers (prototype conflict),
//        the insertBefore is conflicting with some Type js, no fix for the index yet.
// - 1.1: duplicate icons on the homepage fixed

// JSON

Array.prototype.______array='______array';var JSON={org:'http://www.JSON.org',copyright:'(c)2005 JSON.org',license:'http://www.crockford.com/JSON/license.html',stringify:function(arg){var c,i,l,s='',v;switch(typeof arg){case'object':if(arg){if(arg.______array=='______array'){for(i=0;i<arg.length;++i){v=this.stringify(arg[i]);if(s){s+=',';}
s+=v;}
return'['+s+']';}else if(typeof arg.toString!='undefined'){for(i in arg){v=arg[i];if(typeof v!='undefined'&&typeof v!='function'){v=this.stringify(v);if(s){s+=',';}
s+=this.stringify(i)+':'+v;}}
return'{'+s+'}';}}
return'null';case'number':return isFinite(arg)?String(arg):'null';case'string':l=arg.length;s='"';for(i=0;i<l;i+=1){c=arg.charAt(i);if(c>=' '){if(c=='\\'||c=='"'){s+='\\';}
s+=c;}else{switch(c){case'\b':s+='\\b';break;case'\f':s+='\\f';break;case'\n':s+='\\n';break;case'\r':s+='\\r';break;case'\t':s+='\\t';break;default:c=c.charCodeAt();s+='\\u00'+Math.floor(c/16).toString(16)+
(c%16).toString(16);}}}
return s+'"';case'boolean':return String(arg);default:return'null';}},parse:function(text){var at=0;var ch=' ';function error(m){throw{name:'JSONError',message:m,at:at-1,text:text};}
function next(){ch=text.charAt(at);at+=1;return ch;}
function white(){while(ch){if(ch<=' '){next();}else if(ch=='/'){switch(next()){case'/':while(next()&&ch!='\n'&&ch!='\r'){}
break;case'*':next();for(;;){if(ch){if(ch=='*'){if(next()=='/'){next();break;}}else{next();}}else{error("Unterminated comment");}}
break;default:error("Syntax error");}}else{break;}}}
function string(){var i,s='',t,u;if(ch=='"'){outer:while(next()){if(ch=='"'){next();return s;}else if(ch=='\\'){switch(next()){case'b':s+='\b';break;case'f':s+='\f';break;case'n':s+='\n';break;case'r':s+='\r';break;case't':s+='\t';break;case'u':u=0;for(i=0;i<4;i+=1){t=parseInt(next(),16);if(!isFinite(t)){break outer;}
u=u*16+t;}
s+=String.fromCharCode(u);break;default:s+=ch;}}else{s+=ch;}}}
error("Bad string");}
function array(){var a=[];if(ch=='['){next();white();if(ch==']'){next();return a;}
while(ch){a.push(value());white();if(ch==']'){next();return a;}else if(ch!=','){break;}
next();white();}}
error("Bad array");}
function object(){var k,o={};if(ch=='{'){next();white();if(ch=='}'){next();return o;}
while(ch){k=string();white();if(ch!=':'){break;}
next();o[k]=value();white();if(ch=='}'){next();return o;}else if(ch!=','){break;}
next();white();}}
error("Bad object");}
function number(){var n='',v;if(ch=='-'){n='-';next();}
while(ch>='0'&&ch<='9'){n+=ch;next();}
if(ch=='.'){n+='.';while(next()&&ch>='0'&&ch<='9'){n+=ch;}}
if(ch=='e'||ch=='E'){n+='e';next();if(ch=='-'||ch=='+'){n+=ch;next();}
while(ch>='0'&&ch<='9'){n+=ch;next();}}
v=+n;if(!isFinite(v)){}else{return v;}}
function word(){switch(ch){case't':if(next()=='r'&&next()=='u'&&next()=='e'){next();return true;}
break;case'f':if(next()=='a'&&next()=='l'&&next()=='s'&&next()=='e'){next();return false;}
break;case'n':if(next()=='u'&&next()=='l'&&next()=='l'){next();return null;}
break;}
error("Syntax error");}
function value(){white();switch(ch){case'{':return object();case'[':return array();case'"':return string();case'-':return number();default:return ch>='0'&&ch<='9'?number():word();}}
return value();}};
function dump(obj){str='';for (var i in obj) { str += i + ": " + obj[i] + "\n"; }alert(str);}

/**
 * TrimPath Template. Release 1.0.38.
 * Copyright (C) 2004, 2005 Metaha.
 * 
 * TrimPath Template is licensed under the GNU General Public License
 * and the Apache License, Version 2.0, as follows:
 *
 * This program is free software; you can redistribute it and/or 
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed WITHOUT ANY WARRANTY; without even the 
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
var TrimPath;

// TODO: Debugging mode vs stop-on-error mode - runtime flag.
// TODO: Handle || (or) characters and backslashes.
// TODO: Add more modifiers.

(function() {               // Using a closure to keep global namespace clean.
    if (TrimPath == null)
        TrimPath = new Object();
    if (TrimPath.evalEx == null)
        TrimPath.evalEx = function(src) { return eval(src); };

    var UNDEFINED;
    if (Array.prototype.pop == null)  // IE 5.x fix from Igor Poteryaev.
        Array.prototype.pop = function() {
            if (this.length === 0) {return UNDEFINED;}
            return this[--this.length];
        };
    if (Array.prototype.push == null) // IE 5.x fix from Igor Poteryaev.
        Array.prototype.push = function() {
            for (var i = 0; i < arguments.length; ++i) {this[this.length] = arguments[i];}
            return this.length;
        };

    TrimPath.parseTemplate = function(tmplContent, optTmplName, optEtc) {
        if (optEtc == null)
            optEtc = TrimPath.parseTemplate_etc;
        var funcSrc = parse(tmplContent, optTmplName, optEtc);
        var func = TrimPath.evalEx(funcSrc, optTmplName, 1);
        if (func != null)
            return new optEtc.Template(optTmplName, tmplContent, funcSrc, func, optEtc);
        return null;
    }
    
    try {
        String.prototype.process = function(context, optFlags) {
            var template = TrimPath.parseTemplate(this, null);
            if (template != null)
                return template.process(context, optFlags);
            return this;
        }
    } catch (e) { // Swallow exception, such as when String.prototype is sealed.
    }
    
    TrimPath.parseTemplate_etc = {};            // Exposed for extensibility.
    TrimPath.parseTemplate_etc.statementTag = "forelse|for|if|elseif|else|var|macro";
    TrimPath.parseTemplate_etc.statementDef = { // Lookup table for statement tags.
        "if"     : { delta:  1, prefix: "if (", suffix: ") {", paramMin: 1 },
        "else"   : { delta:  0, prefix: "} else {" },
        "elseif" : { delta:  0, prefix: "} else if (", suffix: ") {", paramDefault: "true" },
        "/if"    : { delta: -1, prefix: "}" },
        "for"    : { delta:  1, paramMin: 3, 
                     prefixFunc : function(stmtParts, state, tmplName, etc) {
                        if (stmtParts[2] != "in")
                            throw new etc.ParseError(tmplName, state.line, "bad for loop statement: " + stmtParts.join(' '));
                        var iterVar = stmtParts[1];
                        var listVar = "__LIST__" + iterVar;
                        return [ "var ", listVar, " = ", stmtParts[3], ";",
                             // Fix from Ross Shaull for hash looping, make sure that we have an array of loop lengths to treat like a stack.
                             "var __LENGTH_STACK__;",
                             "if (typeof(__LENGTH_STACK__) == 'undefined' || !__LENGTH_STACK__.length) __LENGTH_STACK__ = new Array();", 
                             "__LENGTH_STACK__[__LENGTH_STACK__.length] = 0;", // Push a new for-loop onto the stack of loop lengths.
                             "if ((", listVar, ") != null) { ",
                             "var ", iterVar, "_ct = 0;",       // iterVar_ct variable, added by B. Bittman     
                             "for (var ", iterVar, "_index in ", listVar, ") { ",
                             iterVar, "_ct++;",
                             "if (typeof(", listVar, "[", iterVar, "_index]) == 'function') {continue;}", // IE 5.x fix from Igor Poteryaev.
                             "__LENGTH_STACK__[__LENGTH_STACK__.length - 1]++;",
                             "var ", iterVar, " = ", listVar, "[", iterVar, "_index];" ].join("");
                     } },
        "forelse" : { delta:  0, prefix: "} } if (__LENGTH_STACK__[__LENGTH_STACK__.length - 1] == 0) { if (", suffix: ") {", paramDefault: "true" },
        "/for"    : { delta: -1, prefix: "} }; delete __LENGTH_STACK__[__LENGTH_STACK__.length - 1];" }, // Remove the just-finished for-loop from the stack of loop lengths.
        "var"     : { delta:  0, prefix: "var ", suffix: ";" },
        "macro"   : { delta:  1, 
                      prefixFunc : function(stmtParts, state, tmplName, etc) {
                          var macroName = stmtParts[1].split('(')[0];
                          return [ "var ", macroName, " = function", 
                                   stmtParts.slice(1).join(' ').substring(macroName.length),
                                   "{ var _OUT_arr = []; var _OUT = { write: function(m) { if (m) _OUT_arr.push(m); } }; " ].join('');
                     } }, 
        "/macro"  : { delta: -1, prefix: " return _OUT_arr.join(''); };" }
    }
    TrimPath.parseTemplate_etc.modifierDef = {
        "eat"        : function(v)    { return ""; },
        "escape"     : function(s)    { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); },
        "capitalize" : function(s)    { return String(s).toUpperCase(); },
        "default"    : function(s, d) { return s != null ? s : d; }
    }
    TrimPath.parseTemplate_etc.modifierDef.h = TrimPath.parseTemplate_etc.modifierDef.escape;

    TrimPath.parseTemplate_etc.Template = function(tmplName, tmplContent, funcSrc, func, etc) {
        this.process = function(context, flags) {
            if (context == null)
                context = {};
            if (context._MODIFIERS == null)
                context._MODIFIERS = {};
            if (context.defined == null)
                context.defined = function(str) { return (context[str] != undefined); };
            for (var k in etc.modifierDef) {
                if (context._MODIFIERS[k] == null)
                    context._MODIFIERS[k] = etc.modifierDef[k];
            }
            if (flags == null)
                flags = {};
            var resultArr = [];
            var resultOut = { write: function(m) { resultArr.push(m); } };
            try {
                func(resultOut, context, flags);
            } catch (e) {
                if (flags.throwExceptions == true)
                    throw e;
                var result = new String(resultArr.join("") + "[ERROR: " + e.toString() + (e.message ? '; ' + e.message : '') + "]");
                result["exception"] = e;
                return result;
            }
            return resultArr.join("");
        }
        this.name       = tmplName;
        this.source     = tmplContent; 
        this.sourceFunc = funcSrc;
        this.toString   = function() { return "TrimPath.Template [" + tmplName + "]"; }
    }
    TrimPath.parseTemplate_etc.ParseError = function(name, line, message) {
        this.name    = name;
        this.line    = line;
        this.message = message;
    }
    TrimPath.parseTemplate_etc.ParseError.prototype.toString = function() { 
        return ("TrimPath template ParseError in " + this.name + ": line " + this.line + ", " + this.message);
    }
    
    var parse = function(body, tmplName, etc) {
        body = cleanWhiteSpace(body);
        var funcText = [ "var TrimPath_Template_TEMP = function(_OUT, _CONTEXT, _FLAGS) { with (_CONTEXT) {" ];
        var state    = { stack: [], line: 1 };                              // TODO: Fix line number counting.
        var endStmtPrev = -1;
        while (endStmtPrev + 1 < body.length) {
            var begStmt = endStmtPrev;
            // Scan until we find some statement markup.
            begStmt = body.indexOf("{", begStmt + 1);
            while (begStmt >= 0) {
                var endStmt = body.indexOf('}', begStmt + 1);
                var stmt = body.substring(begStmt, endStmt);
                var blockrx = stmt.match(/^\{(cdata|minify|eval)/); // From B. Bittman, minify/eval/cdata implementation.
                if (blockrx) {
                    var blockType = blockrx[1]; 
                    var blockMarkerBeg = begStmt + blockType.length + 1;
                    var blockMarkerEnd = body.indexOf('}', blockMarkerBeg);
                    if (blockMarkerEnd >= 0) {
                        var blockMarker;
                        if( blockMarkerEnd - blockMarkerBeg <= 0 ) {
                            blockMarker = "{/" + blockType + "}";
                        } else {
                            blockMarker = body.substring(blockMarkerBeg + 1, blockMarkerEnd);
                        }                        
                        
                        var blockEnd = body.indexOf(blockMarker, blockMarkerEnd + 1);
                        if (blockEnd >= 0) {                            
                            emitSectionText(body.substring(endStmtPrev + 1, begStmt), funcText);
                            
                            var blockText = body.substring(blockMarkerEnd + 1, blockEnd);
                            if (blockType == 'cdata') {
                                emitText(blockText, funcText);
                            } else if (blockType == 'minify') {
                                emitText(scrubWhiteSpace(blockText), funcText);
                            } else if (blockType == 'eval') {
                                if (blockText != null && blockText.length > 0) // From B. Bittman, eval should not execute until process().
                                    funcText.push('_OUT.write( (function() { ' + blockText + ' })() );');
                            }
                            begStmt = endStmtPrev = blockEnd + blockMarker.length - 1;
                        }
                    }                        
                } else if (body.charAt(begStmt - 1) != '$' &&               // Not an expression or backslashed,
                           body.charAt(begStmt - 1) != '\\') {              // so check if it is a statement tag.
                    var offset = (body.charAt(begStmt + 1) == '/' ? 2 : 1); // Close tags offset of 2 skips '/'.
                                                                            // 10 is larger than maximum statement tag length.
                    if (body.substring(begStmt + offset, begStmt + 10 + offset).search(TrimPath.parseTemplate_etc.statementTag) == 0) 
                        break;                                              // Found a match.
                }
                begStmt = body.indexOf("{", begStmt + 1);
            }
            if (begStmt < 0)                              // In "a{for}c", begStmt will be 1.
                break;
            var endStmt = body.indexOf("}", begStmt + 1); // In "a{for}c", endStmt will be 5.
            if (endStmt < 0)
                break;
            emitSectionText(body.substring(endStmtPrev + 1, begStmt), funcText);
            emitStatement(body.substring(begStmt, endStmt + 1), state, funcText, tmplName, etc);
            endStmtPrev = endStmt;
        }
        emitSectionText(body.substring(endStmtPrev + 1), funcText);
        if (state.stack.length != 0)
            throw new etc.ParseError(tmplName, state.line, "unclosed, unmatched statement(s): " + state.stack.join(","));
        funcText.push("}}; TrimPath_Template_TEMP");
        return funcText.join("");
    }
    
    var emitStatement = function(stmtStr, state, funcText, tmplName, etc) {
        var parts = stmtStr.slice(1, -1).split(' ');
        var stmt = etc.statementDef[parts[0]]; // Here, parts[0] == for/if/else/...
        if (stmt == null) {                    // Not a real statement.
            emitSectionText(stmtStr, funcText);
            return;
        }
        if (stmt.delta < 0) {
            if (state.stack.length <= 0)
                throw new etc.ParseError(tmplName, state.line, "close tag does not match any previous statement: " + stmtStr);
            state.stack.pop();
        } 
        if (stmt.delta > 0)
            state.stack.push(stmtStr);

        if (stmt.paramMin != null &&
            stmt.paramMin >= parts.length)
            throw new etc.ParseError(tmplName, state.line, "statement needs more parameters: " + stmtStr);
        if (stmt.prefixFunc != null)
            funcText.push(stmt.prefixFunc(parts, state, tmplName, etc));
        else 
            funcText.push(stmt.prefix);
        if (stmt.suffix != null) {
            if (parts.length <= 1) {
                if (stmt.paramDefault != null)
                    funcText.push(stmt.paramDefault);
            } else {
                for (var i = 1; i < parts.length; i++) {
                    if (i > 1)
                        funcText.push(' ');
                    funcText.push(parts[i]);
                }
            }
            funcText.push(stmt.suffix);
        }
    }

    var emitSectionText = function(text, funcText) {
        if (text.length <= 0)
            return;
        var nlPrefix = 0;               // Index to first non-newline in prefix.
        var nlSuffix = text.length - 1; // Index to first non-space/tab in suffix.
        while (nlPrefix < text.length && (text.charAt(nlPrefix) == '\n'))
            nlPrefix++;
        while (nlSuffix >= 0 && (text.charAt(nlSuffix) == ' ' || text.charAt(nlSuffix) == '\t'))
            nlSuffix--;
        if (nlSuffix < nlPrefix)
            nlSuffix = nlPrefix;
        if (nlPrefix > 0) {
            funcText.push('if (_FLAGS.keepWhitespace == true) _OUT.write("');
            var s = text.substring(0, nlPrefix).replace('\n', '\\n'); // A macro IE fix from BJessen.
            if (s.charAt(s.length - 1) == '\n')
            	s = s.substring(0, s.length - 1);
            funcText.push(s);
            funcText.push('");');
        }
        var lines = text.substring(nlPrefix, nlSuffix + 1).split('\n');
        for (var i = 0; i < lines.length; i++) {
            emitSectionTextLine(lines[i], funcText);
            if (i < lines.length - 1)
                funcText.push('_OUT.write("\\n");\n');
        }
        if (nlSuffix + 1 < text.length) {
            funcText.push('if (_FLAGS.keepWhitespace == true) _OUT.write("');
            var s = text.substring(nlSuffix + 1).replace('\n', '\\n');
            if (s.charAt(s.length - 1) == '\n')
            	s = s.substring(0, s.length - 1);
            funcText.push(s);
            funcText.push('");');
        }
    }
    
    var emitSectionTextLine = function(line, funcText) {
        var endMarkPrev = '}';
        var endExprPrev = -1;
        while (endExprPrev + endMarkPrev.length < line.length) {
            var begMark = "${", endMark = "}";
            var begExpr = line.indexOf(begMark, endExprPrev + endMarkPrev.length); // In "a${b}c", begExpr == 1
            if (begExpr < 0)
                break;
            if (line.charAt(begExpr + 2) == '%') {
                begMark = "${%";
                endMark = "%}";
            }
            var endExpr = line.indexOf(endMark, begExpr + begMark.length);         // In "a${b}c", endExpr == 4;
            if (endExpr < 0)
                break;
            emitText(line.substring(endExprPrev + endMarkPrev.length, begExpr), funcText);                
            // Example: exprs == 'firstName|default:"John Doe"|capitalize'.split('|')
            var exprArr = line.substring(begExpr + begMark.length, endExpr).replace(/\|\|/g, "#@@#").split('|');
            for (var k in exprArr) {
                if (exprArr[k].replace) // IE 5.x fix from Igor Poteryaev.
                    exprArr[k] = exprArr[k].replace(/#@@#/g, '||');
            }
            funcText.push('_OUT.write(');
            emitExpression(exprArr, exprArr.length - 1, funcText); 
            funcText.push(');');
            endExprPrev = endExpr;
            endMarkPrev = endMark;
        }
        emitText(line.substring(endExprPrev + endMarkPrev.length), funcText); 
    }
    
    var emitText = function(text, funcText) {
        if (text == null ||
            text.length <= 0)
            return;
        text = text.replace(/\\/g, '\\\\');
        text = text.replace(/\n/g, '\\n');
        text = text.replace(/"/g,  '\\"');
        funcText.push('_OUT.write("');
        funcText.push(text);
        funcText.push('");');
    }
    
    var emitExpression = function(exprArr, index, funcText) {
        // Ex: foo|a:x|b:y1,y2|c:z1,z2 is emitted as c(b(a(foo,x),y1,y2),z1,z2)
        var expr = exprArr[index]; // Ex: exprArr == [firstName,capitalize,default:"John Doe"]
        if (index <= 0) {          // Ex: expr    == 'default:"John Doe"'
            funcText.push(expr);
            return;
        }
        var parts = expr.split(':');
        funcText.push('_MODIFIERS["');
        funcText.push(parts[0]); // The parts[0] is a modifier function name, like capitalize.
        funcText.push('"](');
        emitExpression(exprArr, index - 1, funcText);
        if (parts.length > 1) {
            funcText.push(',');
            funcText.push(parts[1]);
        }
        funcText.push(')');
    }

    var cleanWhiteSpace = function(result) {
        result = result.replace(/\t/g,   "    ");
        result = result.replace(/\r\n/g, "\n");
        result = result.replace(/\r/g,   "\n");
        result = result.replace(/^(\s*\S*(\s+\S+)*)\s*$/, '$1'); // Right trim by Igor Poteryaev.
        return result;
    }

    var scrubWhiteSpace = function(result) {
        result = result.replace(/^\s+/g,   "");
        result = result.replace(/\s+$/g,   "");
        result = result.replace(/\s+/g,   " ");
        result = result.replace(/^(\s*\S*(\s+\S+)*)\s*$/, '$1'); // Right trim by Igor Poteryaev.
        return result;
    }

    // The DOM helper functions depend on DOM/DHTML, so they only work in a browser.
    // However, these are not considered core to the engine.
    //
    TrimPath.parseDOMTemplate = function(elementId, optDocument, optEtc) {
        if (optDocument == null)
            optDocument = document;
        var element = optDocument.getElementById(elementId);
        var content = element.value;     // Like textarea.value.
        if (content == null)
            content = element.innerHTML; // Like textarea.innerHTML.
        content = content.replace(/&lt;/g, "<").replace(/&gt;/g, ">");
        return TrimPath.parseTemplate(content, elementId, optEtc);
    }

    TrimPath.processDOMTemplate = function(elementId, context, optFlags, optDocument, optEtc) {
        return TrimPath.parseDOMTemplate(elementId, optDocument, optEtc).process(context, optFlags);
    }
}) ();

// Hoodwink'd!!
(function() {

    if (Array.prototype.indexOf == null) // < Firefox 1.5 fix.
        Array.prototype.indexOf = function(v) {
            for (var i = 0; i < this.length; ++i) {
                if (this[i] == v) return i;
            }
            return -1;
        };

    var HoodWink = {

        login: "<%= @user.login %>", key: "<%= @user.security_token %>",
        css: '<%= @user.theme_css %>', version: 1.9,
        theme: '<%= @user.theme_url %>',
        server: 'http:<%= self.URL %>',
        nameplate: "<%= @user.nameplate %>",
        namehue: "<%= @user.namehue %>",

        // load site information
        d: function ( win ) {
            if ( win.document.contentType.indexOf('html') < 0 ) return;
            var loc = win.location;
            this.domain = loc.host.replace( /^www\./, '' );
            this.location = loc;
            if ( this.theme == '' ) this.theme = 'http:<%= URL(Static, "themes", "1") %>';
            if ( this.css == '' ) this.css = this.theme + '/hoodwinkd.css';
            if ( this.domain == "<%= @env.HTTP_HOST %>" && this.location.pathname.match( /^\/[^\/\.]+\.[^\/\.]+/ ) ) return;
            this.search = loc.search;
            this.loadSupport();
            this.configyure(['winksum', 'winksall', 'debug']);
        },
        start: function ( site_settings ) {
            this.sites = [];
            this.injectCSS( "@import url(" + this.css + ");" );
            for (var i=0; i<site_settings.length; i++)
            {
                site = site_settings[i];
                site['summary_eles'] = 0; site['fullpost_eles'] = 0;
                site['summary_links'] = 0; site['fullpost_links'] = 0;
                site['hoodlink'] = this.stripURL( site, this.location );
                site['archive_re'] = new RegExp( "^(" + site['fullpost_url_match'] + ")$" );
                site['permalinks'] = this.permascan( site );
                site['is_fullpost'] = ( !site['is_summary'] && site['hoodlink'].match( site['archive_re'] ) );
                if ( site['permalinks'] )
                    this.jget( this.domain + "/winksum", 'index_html', site );
                if ( site['is_fullpost'] )
                    this.jget( this.domain + "/wink" + site['hoodlink'], 'archive_html', site );
                this.sites.push(site);
            }
            this.injectDebug();
        },

        // Okay... this is the deal... this routine here is supposed to figure out the preferred
        // position for permalinks.  Magic bad AI.
        //  1. Find DIVs, SPANs or anything with 'entry' or 'permalink' or 'post' classes.
        //  2. Find DIVs, SPAN or anything in a pattern.
        //  3. If a permalink is found out of pattern, hit it with a secondary class.
        permascan: function( site ) {
            var links = document.getElementsByTagName('a');
            var permalinks = [];
            var permacount = {};
            var parentct = {};
            var nodeTypes = {};
            var finalist = ['', 0];

            var len = 2000;
            if (links.length < len) len = links.length;

            for (var i=0; i<len; i++)
            {
                var permalink = links[i];
                try {
                    if ( permalink.host.replace( /^www\./, '' ) != this.domain ) continue;
                    var baselink = this.stripURL( site, permalink );
                } catch (e) { continue; }

                if ( baselink == site['hoodlink'] || !baselink.match( site['archive_re'] ) ) continue;
                permacount[baselink] = (permacount[baselink] || 0) + 1;
                parentct[permalink.parentNode] = (parentct[permalink.parentNode] || 0) + 1;

                var cls = [''];
                if (permalink.parentNode.className)
                    cls = permalink.parentNode.className.split(/\s+/);
                var nT = [];
                for (var j = 0; j < cls.length; j++)
                {
                    var s = cls[j];
                    var nodeType = [permalink.parentNode.nodeName, s];
                    var rank = 1 + ['post', 'entry', 'permalink'].indexOf(s.match(/(permalink|entry|post)/));
                    rank += (7-["DIV", "SPAN", "P", "H1", "H2", "H3"].indexOf(nodeType[0]));
                    rank += (permalink.parentNode.clientWidth / 100) - 2;
                    rank -= (permacount[baselink] * 4) + 8;
                    rank -= (parentct[permalink.parentNode] * 4) + 8;
                    nodeType = nodeType[0]+"."+nodeType[1];
                    if ( !nodeTypes[nodeType] ) nodeTypes[nodeType] = 0;
                    nodeTypes[nodeType] += rank;

                    nT.push(nodeType);
                    if ( nodeTypes[nodeType] > finalist[1] )
                        finalist = [nodeType, nodeTypes[nodeType]];
                }
                permalinks.push([baselink, permalink, nT]);
            }

            var permalinkd = {};
            for (var i=0; i<permalinks.length; i++)
            {
                var l = permalinks[i];
                for (var j=0; j<l[2].length; j++)
                {
                    if (!permalinkd[l[0]] || nodeTypes[l[2][j]] > nodeTypes[permalinkd[l[0]][1]])
                        permalinkd[l[0]] = [l[1], l[2][j], finalist[0] == l[2][j]];
                }
            }

            // var str = [];
            // for (var k in permalinkd)
            // {
            //     try { str.push( k + ": " + permalinkd[k][1] ); } catch (e) {}
            // }
            // alert(str);
            return permalinkd;
        },

        // index page shows wink summary
        index_html: function ( summaries, site ) {
            this.injectCSS( site['css'] );
            site['summary_eles'] = 'N/A';
            var tmpl = TrimPath.parseTemplate(GM_getValue('template:winksum'));
            var i = 0;
            for (var baselink in site['permalinks'])
            {
                var permalink = site['permalinks'][baselink][0];
                var winksum = document.getElementById( 'hoodwinkSummary' + i );
                if ( !winksum ) {
                    var winkcount = summaries[baselink] ? summaries[baselink] : {'count': 0};
                    winksum = this.make_node(tmpl, {
                        divId: i, permalink: permalink, 
                        primary: site['permalinks'][baselink][2], 
                        wink: winkcount, user: this
                    });
                }
                permalink.parentNode.insertBefore(winksum, permalink.nextSibling);
                i++;
            }
            site['summary_links']++;
        },
    
        // full winks list on individual pages
        archive_html: function ( winks, site ) {
            var posted = null;
            var permabrother = null;
            var tmpl = TrimPath.parseTemplate(GM_getValue('template:winksall'));
            this.injectCSS( site['css'] );
            this.injectScript( 'http:<%= URL(Static, "js", "rijndael.js") %>' );
            posts = this.xp( site['fullpost_xpath'], document );
            site['fullpost_eles'] = posts.snapshotLength;
            for (var i=0; i<posts.snapshotLength; i++)
            {
                var post = posts.snapshotItem(i);
                var links = post.getElementsByTagName('a');
                for (var j = 0; j < links.length; j++) {
                    var permalink = links[j];
                    try { permalink.pathname } catch (e) { continue; }
                    var baselink = this.stripURL( site, permalink );
                    if ( baselink.match( site['archive_re'] ) ) {
                        posted = post;
                        permabrother = permalink.nextSibling;
                        break;
                    }
                }
            }
            if ( !permabrother ) posted = posts.snapshotItem(0);

            if ( posted ) {
                var data = {winks: [], hoodlink: site['hoodlink'], user: this};
                var winksum = document.getElementById( 'hoodwinkFullposts' );
                for ( var j = 0; j < winks.length; j++ ) {
                    if ( typeof(winks[j]) == 'undefined' ) continue;
                    winks[j]['created_time'] = new Date(winks[j]['created_time'] * 1000)
                    data['winks'].push(winks[j]);
                }
                winksall = this.make_node(tmpl, data);
                if ( winksum )
                    winksum.innerHTML = winksall.innerHTML;
                else
                    posted.innerHTML += "<div id='hoodwinkFullposts'>" + winksall.innerHTML + "</div>";
                if (data.user.onLoad) {
                    data.user.onLoad(this.domain, site['hoodlink'], this.login, this.key, function(a,b,c) { data.user.preview(a,b,c); });
                }
                site['fullpost_links']++;
            }
        },

        jget: function ( url, callback, params ) {
            var self = this;
            GM_xmlhttpRequest({
                method: 'GET', url: "http:<%= self.URL %>" + url,
                // headers: {'Content-type': 'application/x-json'},  // tickles GM+prototype conflict
                // data: ( obj == null ? null : JSON.stringify( obj ) ),
                onload: function(e) { eval('var obj = ' + e.responseText); self[callback](obj, params); }
            });
        },
        makeSearch: function( qvarList, fullSearch ) {
            var qs = '';
            if ( qvarList.length >= 1 && qvarList[0] == '*' ) {
                return fullSearch;
            }
            var qvars = this.parseSearch( fullSearch );
            for ( var i = 0; i < qvarList.length; i++ ) {
                var k = qvarList[i];
                var v = qvars[k];
                if ( v ) {
                    qs += ( qs == '' ? '?' : '&' );
                    qs += k + "=" + v;
                }
            }
            return qs;
        },
        parseSearch: function (s) {
            var sArgs = s.slice(1).split('&');
            var r = ''; var qvars = {}
            for (var i = 0; i < sArgs.length; i++) {
                var k = sArgs[i].slice(0,sArgs[i].indexOf('='));
                qvars[k] = sArgs[i].slice(sArgs[i].indexOf('=')+1);
            }
            return qvars;
        },
        stripURL: function(site, link) {
            var url = link.pathname.replace( /([^\/])\/+$/, '$1' ).replace( /\/+/, '/' );
            if ( site['fullpost_qvars'] )
                url += this.makeSearch( site['fullpost_qvars'], link.search );
            return url;
        },
        // optional debug layer, if the theme has one
        injectDebug: function()
        {
            var tmpl = GM_getValue("template:debug");
            if ( tmpl == '' ) return;

            tmpl = TrimPath.parseTemplate(tmpl);
            body = document.getElementsByTagName("body")[0];
            debug = this.make_node(tmpl, this);
            body.appendChild(debug);
        },
        injectCSS: function(css)
        {
            var head = document.getElementsByTagName("head")[0];
            var style = document.createElement("style");
            style.setAttribute("type", 'text/css');
            style.innerHTML = css;
            head.appendChild(style);
        },
        injectScript: function(src)
        {
            var head = document.getElementsByTagName("head")[0];
            var script = document.createElement("script");
            script.setAttribute("language", "javascript");
            script.setAttribute("src", src);
            head.appendChild(script);
        },

        // XPath convenience funks
        xp: function ( xpath, ele ) {
            return document.evaluate( xpath, ele, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
        },
        xpop: function ( xpath, ele ) {
            return this.xp( xpath, ele ).snapshotItem( 0 );
        },

        // Preview
        preview: function( event, target, txt ) {
            GM_xmlhttpRequest({
                method: 'GET',
                url: this.server + "test.com/preview?u=" + this.login + "&amp;c=" + encodeURIComponent(txt),
                onload: function(req) {
                  if (req.readyState == 4) { // only if req is "loaded"
                    if (req.status == 200) { // only if "OK"
                      target.innerHTML = req.responseText;
                    } else {
                      target.innerHTML="hoodwink_ahah error:\n"+req.statusText;
                    }
                  }
                }
            });
        },

        // Load templates
        make_node: function ( tpl, data ) {
            var ele = document.createElement('div');
            ele.innerHTML = tpl.process(data);
            return ele.firstChild;
        },

        loadSupport: function () {
            GM_xmlhttpRequest({
                method: 'GET', url: 'http:<%= URL(Static, "js", "support.js") %>',
                onload: function(e) { 
                    eval( e.responseText );
                }
            });
        },

        configyure: function (templates) {
            var loaded = GM_getValue("loaded");
            if ( typeof(loaded) != 'undefined' && loaded == this.theme + ";" + (new Date()).getHours() ) {
                this.jget( this.domain + "/setup?v=2", 'start' );
                return;
            }
            var hw = this;
            var t = templates.pop();
            var url = this.theme + "/template-" + t + ".html";
            GM_xmlhttpRequest({
                method: 'GET', url: url + "?" + (new Date()).getMilliseconds(),
                onload: function(e) { 
                    var tmpl = e.responseText;
                    if ( e.status != 200 ) {
                        /* debug is an optional template */
                        if ( t == 'debug' ) tmpl = '';
                        else                return;
                    }
                    GM_setValue("template:" + t, tmpl);
                    if ( templates.length == 0 ) {
                        hw.jget( hw.domain + "/setup?v=2", 'start' );
                        GM_setValue( "loaded", hw.theme + ";" + (new Date()).getHours() );
                    } else {
                        hw.configyure(templates);
                    }
                }
            });
        }
    }

    HoodWink.d( window );

})();
