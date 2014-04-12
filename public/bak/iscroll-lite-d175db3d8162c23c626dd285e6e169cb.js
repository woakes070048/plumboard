/*!
 * iScroll Lite base on iScroll v4.1.6 ~ Copyright (c) 2011 Matteo Spinelli, http://cubiq.org
 * Released under MIT license, http://cubiq.org/license
 */
(function(){var a=Math,b=function(a){return a>>0},c=/webkit/i.test(navigator.appVersion)?"webkit":/firefox/i.test(navigator.userAgent)?"Moz":"opera"in window?"O":"",d=/android/gi.test(navigator.appVersion),e=/iphone|ipad/gi.test(navigator.appVersion),f=/playbook/gi.test(navigator.appVersion),g=/hp-tablet/gi.test(navigator.appVersion),h="WebKitCSSMatrix"in window&&"m11"in new WebKitCSSMatrix,i="ontouchstart"in window&&!g,j=c+"Transform"in document.documentElement.style,k=e||f,l=function(){return window.requestAnimationFrame||window.webkitRequestAnimationFrame||window.mozRequestAnimationFrame||window.oRequestAnimationFrame||window.msRequestAnimationFrame||function(a){return setTimeout(a,17)}}(),m=function(){return window.cancelRequestAnimationFrame||window.webkitCancelAnimationFrame||window.webkitCancelRequestAnimationFrame||window.mozCancelRequestAnimationFrame||window.oCancelRequestAnimationFrame||window.msCancelRequestAnimationFrame||clearTimeout}(),n="onorientationchange"in window?"orientationchange":"resize",o=i?"touchstart":"mousedown",p=i?"touchmove":"mousemove",q=i?"touchend":"mouseup",r=i?"touchcancel":"mouseup",s="translate"+(h?"3d(":"("),t=h?",0)":")",u=function(a,b){var d=this,e=document,f;d.wrapper=typeof a=="object"?a:e.getElementById(a),d.wrapper.style.overflow="hidden",d.scroller=d.wrapper.children[0],d.options={hScroll:!0,vScroll:!0,x:0,y:0,bounce:!0,bounceLock:!1,momentum:!0,lockDirection:!0,useTransform:!0,useTransition:!1,onRefresh:null,onBeforeScrollStart:function(a){a.preventDefault()},onScrollStart:null,onBeforeScrollMove:null,onScrollMove:null,onBeforeScrollEnd:null,onScrollEnd:null,onTouchEnd:null,onDestroy:null};for(f in b)d.options[f]=b[f];d.x=d.options.x,d.y=d.options.y,d.options.useTransform=j?d.options.useTransform:!1,d.options.hScrollbar=d.options.hScroll&&d.options.hScrollbar,d.options.vScrollbar=d.options.vScroll&&d.options.vScrollbar,d.options.useTransition=k&&d.options.useTransition,d.scroller.style[c+"TransitionProperty"]=d.options.useTransform?"-"+c.toLowerCase()+"-transform":"top left",d.scroller.style[c+"TransitionDuration"]="0",d.scroller.style[c+"TransformOrigin"]="0 0",d.options.useTransition&&(d.scroller.style[c+"TransitionTimingFunction"]="cubic-bezier(0.33,0.66,0.66,1)"),d.options.useTransform?d.scroller.style[c+"Transform"]=s+d.x+"px,"+d.y+"px"+t:d.scroller.style.cssText+=";position:absolute;top:"+d.y+"px;left:"+d.x+"px",d.refresh(),d._bind(n,window),d._bind(o),i||d._bind("mouseout",d.wrapper)};u.prototype={enabled:!0,x:0,y:0,steps:[],scale:1,handleEvent:function(a){var b=this;switch(a.type){case o:if(!i&&a.button!==0)return;b._start(a);break;case p:b._move(a);break;case q:case r:b._end(a);break;case n:b._resize();break;case"mouseout":b._mouseout(a);break;case"webkitTransitionEnd":b._transitionEnd(a)}},_resize:function(){this.refresh()},_pos:function(a,d){a=this.hScroll?a:0,d=this.vScroll?d:0,this.options.useTransform?this.scroller.style[c+"Transform"]=s+a+"px,"+d+"px"+t+" scale("+this.scale+")":(a=b(a),d=b(d),this.scroller.style.left=a+"px",this.scroller.style.top=d+"px"),this.x=a,this.y=d},_start:function(a){var b=this,d=i?a.touches[0]:a,e,f,g;if(!b.enabled)return;b.options.onBeforeScrollStart&&b.options.onBeforeScrollStart.call(b,a),b.options.useTransition&&b._transitionTime(0),b.moved=!1,b.animating=!1,b.zoomed=!1,b.distX=0,b.distY=0,b.absDistX=0,b.absDistY=0,b.dirX=0,b.dirY=0;if(b.options.momentum){b.options.useTransform?(e=getComputedStyle(b.scroller,null)[c+"Transform"].replace(/[^0-9-.,]/g,"").split(","),f=e[4]*1,g=e[5]*1):(f=getComputedStyle(b.scroller,null).left.replace(/[^0-9-]/g,"")*1,g=getComputedStyle(b.scroller,null).top.replace(/[^0-9-]/g,"")*1);if(f!=b.x||g!=b.y)b.options.useTransition?b._unbind("webkitTransitionEnd"):m(b.aniTime),b.steps=[],b._pos(f,g)}b.startX=b.x,b.startY=b.y,b.pointX=d.pageX,b.pointY=d.pageY,b.startTime=a.timeStamp||Date.now(),b.options.onScrollStart&&b.options.onScrollStart.call(b,a),b._bind(p),b._bind(q),b._bind(r)},_move:function(b){var c=this,d=i?b.touches[0]:b,e=d.pageX-c.pointX,f=d.pageY-c.pointY,g=c.x+e,h=c.y+f,j=b.timeStamp||Date.now();c.options.onBeforeScrollMove&&c.options.onBeforeScrollMove.call(c,b),c.pointX=d.pageX,c.pointY=d.pageY;if(g>0||g<c.maxScrollX)g=c.options.bounce?c.x+e/2:g>=0||c.maxScrollX>=0?0:c.maxScrollX;if(h>0||h<c.maxScrollY)h=c.options.bounce?c.y+f/2:h>=0||c.maxScrollY>=0?0:c.maxScrollY;c.distX+=e,c.distY+=f,c.absDistX=a.abs(c.distX),c.absDistY=a.abs(c.distY);if(c.absDistX<6&&c.absDistY<6)return;c.options.lockDirection&&(c.absDistX>c.absDistY+5?(h=c.y,f=0):c.absDistY>c.absDistX+5&&(g=c.x,e=0)),c.moved=!0,c._pos(g,h),c.dirX=e>0?-1:e<0?1:0,c.dirY=f>0?-1:f<0?1:0,j-c.startTime>300&&(c.startTime=j,c.startX=c.x,c.startY=c.y),c.options.onScrollMove&&c.options.onScrollMove.call(c,b)},_end:function(c){if(i&&c.touches.length!=0)return;var d=this,e=i?c.changedTouches[0]:c,f,g,h={dist:0,time:0},j={dist:0,time:0},k=(c.timeStamp||Date.now())-d.startTime,l=d.x,m=d.y,n;d._unbind(p),d._unbind(q),d._unbind(r),d.options.onBeforeScrollEnd&&d.options.onBeforeScrollEnd.call(d,c);if(!d.moved){if(i){f=e.target;while(f.nodeType!=1)f=f.parentNode;f.tagName!="SELECT"&&f.tagName!="INPUT"&&f.tagName!="TEXTAREA"&&(g=document.createEvent("MouseEvents"),g.initMouseEvent("click",!0,!0,c.view,1,e.screenX,e.screenY,e.clientX,e.clientY,c.ctrlKey,c.altKey,c.shiftKey,c.metaKey,0,null),g._fake=!0,f.dispatchEvent(g))}d._resetPos(200),d.options.onTouchEnd&&d.options.onTouchEnd.call(d,c);return}if(k<300&&d.options.momentum){h=l?d._momentum(l-d.startX,k,-d.x,d.scrollerW-d.wrapperW+d.x,d.options.bounce?d.wrapperW:0):h,j=m?d._momentum(m-d.startY,k,-d.y,d.maxScrollY<0?d.scrollerH-d.wrapperH+d.y:0,d.options.bounce?d.wrapperH:0):j,l=d.x+h.dist,m=d.y+j.dist;if(d.x>0&&l>0||d.x<d.maxScrollX&&l<d.maxScrollX)h={dist:0,time:0};if(d.y>0&&m>0||d.y<d.maxScrollY&&m<d.maxScrollY)j={dist:0,time:0}}if(h.dist||j.dist){n=a.max(a.max(h.time,j.time),10),d.scrollTo(b(l),b(m),n),d.options.onTouchEnd&&d.options.onTouchEnd.call(d,c);return}d._resetPos(200),d.options.onTouchEnd&&d.options.onTouchEnd.call(d,c)},_resetPos:function(a){var b=this,c=b.x>=0?0:b.x<b.maxScrollX?b.maxScrollX:b.x,d=b.y>=0||b.maxScrollY>0?0:b.y<b.maxScrollY?b.maxScrollY:b.y;if(c==b.x&&d==b.y){b.moved&&(b.options.onScrollEnd&&b.options.onScrollEnd.call(b),b.moved=!1);return}b.scrollTo(c,d,a||0)},_mouseout:function(a){var b=a.relatedTarget;if(!b){this._end(a);return}while(b=b.parentNode)if(b==this.wrapper)return;this._end(a)},_transitionEnd:function(a){var b=this;if(a.target!=b.scroller)return;b._unbind("webkitTransitionEnd"),b._startAni()},_startAni:function(){var b=this,c=b.x,d=b.y,e=Date.now(),f,g,h;if(b.animating)return;if(!b.steps.length){b._resetPos(400);return}f=b.steps.shift(),f.x==c&&f.y==d&&(f.time=0),b.animating=!0,b.moved=!0;if(b.options.useTransition){b._transitionTime(f.time),b._pos(f.x,f.y),b.animating=!1,f.time?b._bind("webkitTransitionEnd"):b._resetPos(0);return}h=function(){var i=Date.now(),j,k;if(i>=e+f.time){b._pos(f.x,f.y),b.animating=!1,b.options.onAnimationEnd&&b.options.onAnimationEnd.call(b),b._startAni();return}i=(i-e)/f.time-1,g=a.sqrt(1-i*i),j=(f.x-c)*g+c,k=(f.y-d)*g+d,b._pos(j,k),b.animating&&(b.aniTime=l(h))},h()},_transitionTime:function(a){this.scroller.style[c+"TransitionDuration"]=a+"ms"},_momentum:function(c,d,e,f,g){var h=6e-4,i=a.abs(c)/d,j=i*i/(2*h),k=0,l=0;return c>0&&j>e?(l=g/(6/(j/i*h)),e+=l,i=i*e/j,j=e):c<0&&j>f&&(l=g/(6/(j/i*h)),f+=l,i=i*f/j,j=f),j*=c<0?-1:1,k=i/h,{dist:j,time:b(k)}},_offset:function(a){var b=-a.offsetLeft,c=-a.offsetTop;while(a=a.offsetParent)b-=a.offsetLeft,c-=a.offsetTop;return{left:b,top:c}},_bind:function(a,b,c){(b||this.scroller).addEventListener(a,this,!!c)},_unbind:function(a,b,c){(b||this.scroller).removeEventListener(a,this,!!c)},destroy:function(){var a=this;a.scroller.style[c+"Transform"]="",a._unbind(n,window),a._unbind(o),a._unbind(p),a._unbind(q),a._unbind(r),a._unbind("mouseout",a.wrapper),a.options.useTransition&&a._unbind("webkitTransitionEnd"),a.options.onDestroy&&a.options.onDestroy.call(a)},refresh:function(){var a=this,b;a.wrapperW=a.wrapper.clientWidth,a.wrapperH=a.wrapper.clientHeight,a.scrollerW=a.scroller.offsetWidth,a.scrollerH=a.scroller.offsetHeight,a.maxScrollX=a.wrapperW-a.scrollerW,a.maxScrollY=a.wrapperH-a.scrollerH,a.dirX=0,a.dirY=0,a.hScroll=a.options.hScroll&&a.maxScrollX<0,a.vScroll=a.options.vScroll&&(!a.options.bounceLock&&!a.hScroll||a.scrollerH>a.wrapperH),b=a._offset(a.wrapper),a.wrapperOffsetLeft=-b.left,a.wrapperOffsetTop=-b.top,a.scroller.style[c+"TransitionDuration"]="0",a._resetPos(200)},scrollTo:function(a,b,c,d){var e=this,f=a,g,h;e.stop(),f.length||(f=[{x:a,y:b,time:c,relative:d}]);for(g=0,h=f.length;g<h;g++)f[g].relative&&(f[g].x=e.x-f[g].x,f[g].y=e.y-f[g].y),e.steps.push({x:f[g].x,y:f[g].y,time:f[g].time||0});e._startAni()},scrollToElement:function(b,c){var d=this,e;b=b.nodeType?b:d.scroller.querySelector(b);if(!b)return;e=d._offset(b),e.left+=d.wrapperOffsetLeft,e.top+=d.wrapperOffsetTop,e.left=e.left>0?0:e.left<d.maxScrollX?d.maxScrollX:e.left,e.top=e.top>0?0:e.top<d.maxScrollY?d.maxScrollY:e.top,c=c===undefined?a.max(a.abs(e.left)*2,a.abs(e.top)*2):c,d.scrollTo(e.left,e.top,c)},disable:function(){this.stop(),this._resetPos(0),this.enabled=!1,this._unbind(p),this._unbind(q),this._unbind(r)},enable:function(){this.enabled=!0},stop:function(){m(this.aniTime),this.steps=[],this.moved=!1,this.animating=!1}},typeof exports!="undefined"?exports.iScroll=u:window.iScroll=u})();