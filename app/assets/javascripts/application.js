// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap

(function(c,a){window.mixpanel=a;var b,d,h,e;b=c.createElement("script");
    b.type="text/javascript";b.async=!0;b.src=("https:"===c.location.protocol?"https:":"http:")+
        '//cdn.mxpnl.com/libs/mixpanel-2.2.min.js';d=c.getElementsByTagName("script")[0];
    d.parentNode.insertBefore(b,d);a._i=[];a.init=function(b,c,f){function d(a,b){
        var c=b.split(".");2==c.length&&(a=a[c[0]],b=c[1]);a[b]=function(){a.push([b].concat(
            Array.prototype.slice.call(arguments,0)))}}var g=a;"undefined"!==typeof f?g=a[f]=[]:
        f="mixpanel";g.people=g.people||[];h=['disable','track','track_pageview','track_links',
        'track_forms','register','register_once','unregister','identify','alias','name_tag',
        'set_config','people.set','people.increment','people.track_charge','people.append'];
        for(e=0;e<h.length;e++)d(g,h[e]);a._i.push([b,c,f])};a.__SV=1.2;})(document,window.mixpanel||[]);
mixpanel.init("5656aa59294f5d08d6b14d85c2029828");

//ajax loading animation
function showLoading() {
    //$("div.container").show();
    $("#loading").show(); // If image gif
}

function hideLoading() {
    //$("div.container").hide();
    $("#loading").hide();  // If image gif
}

$(document).ready(function() {

    $(".link-section").click(function() {
        $(location).attr('href', $(this).attr("data-href"));
    });

    setTimeout("$(\".alert\").fadeOut(\"slow\")",5000);
});

