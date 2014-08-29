package {
  import flash.events.*;
  import flash.display.*;
  import flash.media.*;
  import flash.geom.*;
  import flash.ui.*;
  import flash.utils.ByteArray;
  import jp.halinc.display.BaseSprite;
  
  public class Wave extends BaseSprite {

    private static const DEFAULT_POWER:int = 500;

    private static const BUF_WIDTH:int = 320;
    private static const BUF_HEIGHT:int = 240;

    [Embed(source='./sample2.mp3')]
      private static const SoundSample:Class;

    private var sound_:Sound;
    private var power_:Number;
    private var row_:int,col_:int;
    private var crash_:Number;
    private var rot90_:Boolean;

    public function Wave() {
      power_ = DEFAULT_POWER;
      crash_ = 0;
      row_ = col_ = 1;
      rot90_ = false;
      
      //
      addEventListener(BaseSprite.STAGE_DETECTED, stage_detected);
      addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
    }
    public function removed_from_stage(evt:Event):void {
      SoundMixer.stopAll();
      removeEventListener(Event.ENTER_FRAME, loop);
    }

    private var bdView_:BitmapData;
    private var bdViewBuf_:BitmapData;
    private var bdViewLeft_:BitmapData;
    private var bdViewRight_:BitmapData;

    

    public function stage_detected(evt:Event):void {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.frameRate = 30;
      stage.quality = StageQuality.LOW;
      stage.displayState = StageDisplayState.FULL_SCREEN;
      Mouse.hide();

      //
      bdViewBuf_ = new BitmapData(BUF_WIDTH,BUF_HEIGHT,false,0x000000);
      bdView_ = new BitmapData(sw,sh,false,0x000000);
      var bmp:Bitmap = addChild(new Bitmap(bdView_)) as Bitmap;
      //
      bdViewLeft_ = new BitmapData(BUF_WIDTH/2,BUF_HEIGHT,false,0x000000);
      bdViewRight_ = new BitmapData(BUF_WIDTH/2,BUF_HEIGHT,false,0x000000);

      sound_ = new SoundSample();
      sound_.play();
      addEventListener(Event.ENTER_FRAME, loop);
      stage.addEventListener(KeyboardEvent.KEY_DOWN,onkeydown);
    }
    private function onkeydown(evt:KeyboardEvent):void {
      var code:int = evt.keyCode;
      if(49 <= code && code <= 57 ) { // 1-9
        evt.shiftKey ? row_ = code-48 : col_ = code-48;
      } else if(code == Keyboard.DOWN) {
        if(evt.shiftKey) {
          crash_ -= 0.03;
          if(crash_ < -1 ) crash_ = -1;
        } else {
          power_ -= 150;
          if(power_ < 10) power_ = 10;
        }
      } else if(code == Keyboard.UP) {
        if(evt.shiftKey) {
          crash_ += 0.03;
          if(crash_ > 1) crash_ = 1;
        } else {
          power_ += 150;
        }
      } else if(code == Keyboard.RIGHT) {
        if(evt.shiftKey) {
          crash_ = 0;
        } else {
          power_ = DEFAULT_POWER;
        }
      } else if(code == Keyboard.BACKSPACE) {
        rot90_ = !rot90_;
      }
    }
    public function loop(evt:Event):void {
      var f:Number,fv:Number;
      var fft:ByteArray = new ByteArray();
      SoundMixer.computeSpectrum(fft,false);
      //
      var thick_left:Number = 0;
      for(f=1.0;f<256.0;f+=1) {
        fv = fft.readFloat();
        thick_left += Math.pow(fv/f,3);
      }
      thick_left *= power_;
      //
      var thick_right:Number = 0;
      for(f=1.0;f<256.0;f+=1) {
        fv = fft.readFloat();
        thick_right += Math.pow(fv/f,3);
      }
      thick_right *= power_;

      var bdTmp:BitmapData = bdViewLeft_.clone();
      var s:Shape = new Shape();
      var g:Graphics = s.graphics;

      //
      g.clear();
      g.beginFill(0x000000);
      g.drawRect(0,0,BUF_WIDTH/2,BUF_HEIGHT);
      g.endFill();
      g.beginFill(0xffffff);
      g.drawRect(0,(BUF_HEIGHT-thick_left)/2,BUF_WIDTH/2,thick_left);
      g.endFill();
      bdTmp.draw(s);
      bdViewLeft_.lock();
      bdViewLeft_.copyChannel(bdTmp, bdViewLeft_.rect, new Point(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)),
                              BitmapDataChannel.RED, BitmapDataChannel.RED);
      bdViewLeft_.copyChannel(bdTmp, bdViewLeft_.rect, new Point(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)),
                              BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
      bdViewLeft_.copyChannel(bdTmp, bdViewLeft_.rect, new Point(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)),
                              BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
      bdViewLeft_.unlock();
      //
      g.clear();
      g.beginFill(0x000000);
      g.drawRect(0,0,BUF_WIDTH/2,BUF_HEIGHT);
      g.endFill();
      g.beginFill(0xffffff);
      g.drawRect(0,(BUF_HEIGHT-thick_right)/2,BUF_WIDTH/2,thick_right);
      g.endFill();
      bdTmp.draw(s);
      bdViewRight_.lock();
      bdViewRight_.copyChannel(bdTmp, bdViewRight_.rect, new Point(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)),
                              BitmapDataChannel.RED, BitmapDataChannel.RED);
      bdViewRight_.copyChannel(bdTmp, bdViewRight_.rect, new Point(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)),
                              BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
      bdViewRight_.copyChannel(bdTmp, bdViewRight_.rect, new Point(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)),
                              BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
      bdViewRight_.unlock();
      //
      bdViewBuf_.lock();
      bdViewBuf_.copyPixels(bdViewLeft_,bdViewLeft_.rect,new Point(0,0));
      bdViewBuf_.copyPixels(bdViewRight_,bdViewRight_.rect,new Point(BUF_WIDTH/2,0));
      bdViewBuf_.unlock();
      //
      bdTmp.dispose();
      
      bdView_.lock();
      var mat:Matrix = new Matrix();
      mat.scale(1/col_*sw/BUF_WIDTH,1/row_*sh/BUF_HEIGHT);
      for(var x:int=0;x<col_;x++) {
        var mat2:Matrix = mat.clone();
        for(var y:int=0;y<row_;y++) {
          bdView_.draw(bdViewBuf_,mat2);
          mat2.translate(0,sh/row_);
        }
        mat.translate(sw/col_,0);
      }

      if(rot90_) {
        var bdTmp2:BitmapData = bdView_.clone();
        var mat90:Matrix = new Matrix();
        mat90.translate(0,-sh);
        mat90.rotate(Math.PI/2);
        mat90.scale(sw/sh,sh/sw);
        bdTmp2.draw(bdView_, mat90);
        bdView_.copyPixels(bdTmp2,bdTmp2.rect,new Point(0,0));
        bdTmp2.dispose();
      }

      var mat_ax:Matrix = new Matrix();
      var r:Number = (Math.random()-0.5)*crash_;
      if(r != 0) mat_ax.rotate(r);
      mat_ax.translate(sw*Math.random()*crash_,-sh*Math.random()*crash_);
      bdView_.draw(bdView_,mat_ax);
      bdView_.unlock();


    }
  }
}
