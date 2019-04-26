/** Module edo365board
 ** Copyright (c) 2019 Benjamin Benno Falkner <benno.falkner@gmail.com>
 ** 
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 ** 
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 ** 
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE.
 **/

// Module definition
var edo365board = (function (){
    // private
    var Pages = { pos: 0, html: [] };
    var Sleep = 5000;
    var USleep = 30000;
  
    function update() {
      window.setInterval(function(){
          var xhttp;
          xhttp=new XMLHttpRequest();
          xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
              Pages.html = JSON.parse(this.responseText);
            }
          };
          xhttp.open("GET","/listing.json", true);
          xhttp.send();
      },USleep);
    };
  
    function play() {
      window.setInterval(function(){
        var target = document.querySelector("#content");
        var cur = Pages.html[Pages.pos];
        if(cur == undefined) {
          Pages.pos = 0;
          cur = Pages.html[Pages.pos];
          if(cur == undefined) {
            target.innerHTML = "<div class=\"loader\"></div>";
            return
          }
        }
        loadhtml(cur,target);
        Pages.pos++;
      },Sleep);
    };
  
    function loadhtml(src, target) {
      var target_ = target;
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          target_.innerHTML = this.responseText;
        }
      };
      xhttp.open("GET","/public/"+src, true);
      xhttp.send();
    }
  
    function set_logo(src) {
      document.querySelector("#headline").innerHTML = "<img src=\"/style/"+src+"\">"
    } 
  
  
    return { // public
      pages: Pages,
      start: function (Config){
        Sleep = Config.sleep * 1000 || 5000;
        USleep = Config.update  * 1000 || 30000;
        if (Config.logo) set_logo(Config.logo);
        play();
        update();
      }
    }
})();
  
  