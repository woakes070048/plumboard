// checks ticket order form quantity fields to ensure selections are made prior to submission 
function StripeCard(){return Stripe.setPublishableKey($('meta[name="stripe-key"]').attr("content")),$("#payForm").attr("disabled",!0),Stripe.createToken({number:$("#card_number").val(),cvc:$("#card_code").val(),expMonth:$("#card_month").val(),expYear:$("#card_year").val()},stripeResponseHandler),!1}function printIt(a){win=window.open(),self.focus(),win.document.write(a),win.print(),win.close()}function set_token(a){$("#pay_token").val(a.id),$("#payment_form").trigger("submit.rails")}function stripeResponseHandler(a,b){var c=$("#card_error");return a==200?(toggleLoading(),c.hide(300),set_token(b)):b.error.message=="An unexpected error has occurred. We have been notified of the problem."?(payForm.attr("disabled",!1),set_token(b)):(c.show(300).text(b.error.message),payForm.attr("disabled",!1),$("html, body").animate({scrollTop:0},100)),!1}var formError,formTxtForm,pmtForm,payForm,api_type;$(document).on("click","#payForm",function(){var a=$('meta[name="credit-card-api"]').attr("content");if($("#card_number").length>0)return a=="stripe"&&StripeCard(),a=="balanced"&&BalancedCard(),!1;var b=parseFloat($("#amt").val());return b==0&&$("#payment_form").trigger("submit.rails"),!0}),$(document).on("click",".promo-cd",function(){$(".promo-code").show()}),$(document).ready(function(){if($("#pmtForm").length==0||$("#buyTxtForm").length==0)payForm=$("#payForm")}),$(document).on("click","#discount_btn",function(){var a=$("#promo_code").val();if(a.length>0){var b="/discount.js?promo_code="+a;process_url(b)}return!1}),$(document).on("click","#print-btn",function(){return printIt($("#printable").html()),!1});var win=null;