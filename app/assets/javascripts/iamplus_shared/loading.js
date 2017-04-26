if(typeof(IAM)=='undefined') IAM = {}
IAM.loading = {
  data:{
    data:0,
    interval:{}
  },
  start:function(params,callback){
    var theme   = 'dark';
    var elem    = 'body';
    var interval  = 1000;
    var duration  = 3200;
    var id      = 'loader_'+$('.iam-loading').length;
    var type        = 'bar';
    var logo        = 'https://iamplus-shared-assets.s3.amazonaws.com/imgs/puls-76x76.png';
    if(typeof(params)=='undefined') params = {}
    if(typeof(params.elem)=='undefined') params.elem = elem;
    if(typeof(params.type)=='undefined') params.type = type;
    if(typeof(params.opaque)=='undefined'){
      params.opaque = '';
    }else{
      params.opaque = 'opaque';
    }
    if(typeof(params.theme)=='undefined') params.theme = theme;
    if(typeof(params.interval)=='undefined') params.interval = interval;
    if(typeof(params.data)=='undefined'){
      params.data = 0;
      IAM.loading.data.interval[id]=setInterval(function(){
        params.data=params.data+1;
        IAM.loading.update({id:id,data:params.data});
        if(params.data==100){
          window.clearInterval(IAM.loading.data.interval[id])
          if($.isFunction(callback)){
            IAM.loading.complete({id:id},callback);
          }else{
            IAM.loading.complete({id:id});
          }
        }
      },params.interval);
      if(typeof(params.duration)=='undefined') params.duration = duration;
      if(params.duration!=false){
        setTimeout(function(){
              IAM.loading.complete({id:id},callback);
          },params.duration);
      }
    }
    var markup = '<div class="iam-loading" rel="'+id+'" elem="'+params.elem+'" theme="'+params.theme+'" '+params.opaque+'><div bar><div progress></div></div></div>';
    if(params.type == 'logo'){
      markup = '<div class="iam-loading" rel="'+id+'" elem="'+params.elem+'" theme="'+params.theme+'" '+params.opaque+'><img src="'+logo+'"/></div>'
    }
    if($(params.elem+' > .iam-loading').length!=0) IAM.loading.stop(id);
    $(params.elem).append(markup).addClass('no-scroll');
        console.log(params.elem);
        if(params.elem=='body' || params.elem=='html') $('.iam-loading[rel="'+id+'"]').addClass('position-fixed');
        $('.iam-loading[rel="'+id+'"]').fadeIn('fast',function(){
            IAM.loading.update(params.data);
        });
  },
  complete:function(params,callback){
    window.clearInterval(IAM.loading.data.interval[params.id]);
    IAM.loading.update({id:params.id,data:100},function(){
      if($.isFunction(callback)){
        IAM.loading.stop({id:params.id},callback);
      }else{
        IAM.loading.stop({id:params.id});
      }
    });
  },
  update:function(params,callback){
    if($('.iam-loading[rel="'+params.id+'"]').find('[progress]').length){ // BAR
      $('.iam-loading[rel="'+params.id+'"]').find('[progress]').css({width:params.data+'%'});
    }else{
      if($('.iam-loading[rel="'+params.id+'"]').find('img').is(':visible')){
        $('.iam-loading[rel="'+params.id+'"]').find('img').fadeOut(250);
      }else{
        $('.iam-loading[rel="'+params.id+'"]').find('img').fadeIn(250);
      }
    }
    if($.isFunction(callback)) callback(params.id);
  },
  stop:function(params,callback){
    var elem = $('.iam-loading[rel="'+params.id+'"]').attr('elem');
    $(elem).removeClass('no-scroll');
    $('.iam-loading[rel="'+params.id+'"]').fadeOut(250,function(){
      $(this).remove();
      if($.isFunction(callback)) callback(params.id);
      return false;
    });
  }
}
