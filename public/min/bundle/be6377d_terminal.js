(function(){$(function(){var a;return a=io(),$(document).keypress(function(b){var c,d;if(b.which===13){d=$("#terminal"),c=$("#result");if(d.is(":focus"))return a.emit("terminal",d.val()),d.val("")}}),a.on("terminal",function(a){return result.append("<li>"+message+"</li>")})})}).call(this)