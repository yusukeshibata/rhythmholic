package {
  import flash.events.*;
  import flash.display.*;
  import flash.ui.*;
  import flash.utils.*;
  import flash.net.*;

  public class FTime extends Sprite {

    private static const RESERVEDKEYWORDNUM:int = 9;
    private static const KEYWORDFILE:String = './keyword.txt';

    private var keywords_:Array;
    private var objs_:Array,tmp_:Array;

    private var words_:Array;
    private var sentences_:Array;

    public function FTime() {
      objs_ = new Array();
      tmp_ = null;
      words_ = new Array();
      sentences_ = new Array();
      //
      addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
      addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
    }
    public function removed_from_stage(evt:Event):void {
    }
    public function added_to_stage(evt:Event):void {
      Logger.log('Stage detected.');
      if(this == root) {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.frameRate = 120;
      stage.quality = StageQuality.LOW;
      stage.displayState = StageDisplayState.FULL_SCREEN;
      Mouse.hide();
      }

      FontData.init();
      
      // load keywords
      var ldr:URLLoader = new URLLoader();
      ldr.addEventListener(Event.COMPLETE,kf_loaded);
      ldr.load(new URLRequest(KEYWORDFILE));
    }
    private function kf_loaded(evt:Event):void {
      var ldr:URLLoader = evt.currentTarget as URLLoader;
      var text:String = ldr.data;
      keywords_ = text.split(/\n\n/);
      //
      _init();
    }
    private function _init():void {
      stage.addEventListener(KeyboardEvent.KEY_DOWN,onkeydown);
      stage.addEventListener(KeyboardEvent.KEY_UP,onkeyup);
      addEventListener(Event.ENTER_FRAME, enterframe);
    }
    private function enterframe(evt:Event):void {
      if(!visible) return;
      for(var i:uint=0;i<objs_.length;i++) {
        var obj:Object = objs_[i];
        if(obj.done)
          if(!n(obj)) {
            objs_.splice(i,1);
            i--;
          }

      }
    }

    private function onkeyup(evt:KeyboardEvent):void {
      if(!visible) return;
      if(tmp_ == null) return;
      for(var i:int=0;i<tmp_.length;i++) {
        tmp_[i].lock = false;
      }
      tmp_ = null;
    }
    private function sentence(v:String):Boolean {
      var words:Array = v.split(' ');
      return words.length > 1;
    }
    private function pop_word():String {
      trace(words_.length);
      if(words_.length == 0) {
        for(var i:int=0;i<keywords_.length;i++) {
          if(i<RESERVEDKEYWORDNUM) continue;
          if(sentence(keywords_[i])) continue;
          words_.push(keywords_[i]);
        }
      }
      var index:int = Math.floor(Math.random()*words_.length);
      var ret:Array = words_.splice(index,1);
      return ret[0];
    }
    private function pop_sentence():String {
      if(sentences_.length == 0) {
        for(var i:int=0;i<keywords_.length;i++) {
          if(i<RESERVEDKEYWORDNUM) continue;
          if(sentence(keywords_[i]) == false) continue;
          sentences_.push(keywords_[i]);
        }
      }
      var index:int = Math.floor(Math.random()*sentences_.length);
      var ret:Array = sentences_.splice(index,1);
      return ret[0];
    }
    private function onkeydown(evt:KeyboardEvent):void {
      if(!visible) return;
      if(tmp_ != null) return;
      var code:int = evt.keyCode;
      if(code == Keyboard.SHIFT ||
         !(code == Keyboard.SPACE ||
           48 < code && code < 48+RESERVEDKEYWORDNUM+1 ||
           code == 66
           )
         ) return;
      var k:String;
      if(48 < code && code < 48+RESERVEDKEYWORDNUM+1) {
        var index:int = code-49;
        if(index >= keywords_.length) index = keywords_.length-1;
        k = keywords_[index];
      } else if(code == 66) {
        k = pop_word();
      } else  {
        k = pop_sentence();
      }
      var x:int =0, y:int = 0;
      tmp_ = new Array();
      var w:Number=0,h:Number=0;
      for(var i:int=0;i<k.length;i++) {
        var c:String = k.charAt(i);
        if(c == '\n') {
          y += 80;
          x = 0;
          continue;
        }
        if(c == ' ') {
          x += 65;
          continue;
        }
        var obj:Object = new Object();
        obj.i = 0;
        obj.c = c;
        obj.x = x;
        obj.y = y;
        obj.scale = 1;
        tmp_.push(obj);
        objs_.push(obj);
        w = Math.max(w,x+85);
        h = Math.max(h,y+85);
        x += 65;
      }
      if(!evt.shiftKey) {
        var scale:Number = Math.min(stage.stageWidth/w,stage.stageHeight/h);
        //var scale:Number = 1;
        var dx:Number = (stage.stageWidth-scale*w)/2;
        var dy:Number = (stage.stageHeight-scale*h)/2;
        for(i=0;i<tmp_.length;i++) {
          obj = tmp_[i];
          obj.scale = scale;
          obj.x *= scale;
          obj.y *= scale;
          obj.x += dx;
          obj.y += dy;
        }
      }
      for(i=0;i<tmp_.length;i++) {
        n(tmp_[i]);
        tmp_[i].lock = true;
      }
    }
    private function n(obj:Object):Boolean {
      if(obj.lock) return true;
      obj.done = false;
      obj.i=FontData.retrieve_next(obj.c,obj.i,{
        onComplete:function(bmp:Bitmap):void {
            if(obj.bmp) {
              removeChild(obj.bmp);
              FontData.dispose(obj.bmp);
            }
            obj.bmp = addChild(bmp);
            obj.bmp.x = obj.x;
            obj.bmp.y = obj.y;
            obj.bmp.scaleX = obj.bmp.scaleY = obj.scale;
            obj.done = true;
          }});
      if(obj.i == -1) {
        if(obj.bmp) {
          removeChild(obj.bmp);
          FontData.dispose(obj.bmp);
        }
      }
      return obj.i != -1;
    }

    

  }

}
import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.errors.EOFError;
import flash.utils.*;
import com.adobe.serialization.json.JSON;

class FontData {
    
  [Embed(source='./font.dat',mimeType="application/octet-stream")]private static const FONTDAT:Class;
  [Embed(source='./font.js',mimeType="application/octet-stream")]private static const FONTJS:Class;

  private static var dic_:Object;
  private static var dat_:ByteArray;
  private static var info_:Object;
  private static var callbackdic_:Dictionary;

  public static function init():void {
    Logger.log('Initializing font data...');
    Logger.log('Creating callback dictionary...');
    callbackdic_ = new Dictionary();
    Logger.log('Done.');
    dic_ = new Object();
    Logger.log('Loading global font data...');
    dat_ = ByteArray(new FONTDAT());
    Logger.log('Done.');
    Logger.log('Loading font mapping data...');
    var infostr:String = String(new FONTJS());
    Logger.log('Retrieving font mapping data...');
    info_ = JSON.decode(infostr);
    Logger.log('OK. Completing decoding font mapping data...');
    while(true) {
      try {
        // md5hash string
        var md5hash:String = dat_.readMultiByte(32, 'us-ascii');
        Logger.log('Reading MD5 Hash... ['+md5hash+']');
        // length
        var len:uint = dat_.readUnsignedInt();
        Logger.log('Reading Font Data length... : '+ len+'bytes');
        dic_[md5hash] = { position:dat_.position,length:len };
        dat_.position += len;
      } catch(e:EOFError) {
        Logger.log('Reading done.[caught EOF position]');
        break;
      }
    } 
    Logger.log('FontData initilization finished.');
  }
  public static function retrieve_next2(c:String,i:int,callback:Object):int {
    var ids:Array = info_[c];
    if(!ids) return -1;
    var id:String = ids[i];
    if(!id) return -1;
    var id_next:String = id;
    var index_ret:int = i;
    for(var index:int=i+1;id == id_next;index++) {
      id_next = info_[c][index];
      index_ret = index;
    }
    if(!id_next) return -1;
    _retrieve(id_next,callback);
    return index_ret;
  }
  public static function retrieve_next(c:String,i:int,callback:Object):int {
    var ids:Array = info_[c];
    if(!ids) return -1;
    var id:String = ids[i];
    if(!id) return -1;
    _retrieve(id, callback);
    return i+1;
  }
  private static function _retrieve(id:String, callback:Object):void {
    var d:Object = dic_[id];
    dat_.position = d.position;
    var len:uint = d.length;
    var buf:ByteArray = new ByteArray();
    dat_.readBytes(buf,0,len);
    var ldr:Loader = new Loader();
    callbackdic_[ldr] = callback;
    ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, _loaded);
    ldr.loadBytes(buf);
  }
  private static function _loaded(evt:Event):void {
    var ldr:Loader = Loader(evt.target.loader);
    ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, _loaded);
    var bmp:Bitmap = Bitmap(ldr.content);
    var callback:Object = callbackdic_[ldr];
    if(callback && callback.onComplete) {
      callback.onComplete(bmp);
      delete callbackdic_[ldr];
    }
  }
  public static function dispose(bmp:Bitmap):void {
    bmp.bitmapData.dispose();
  }
}
