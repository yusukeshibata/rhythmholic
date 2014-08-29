package {
  import flash.events.*;
  import flash.display.*;
  import flash.media.*;
  import flash.geom.*;
  import flash.ui.*;
  import flash.utils.ByteArray;
  import flash.media.Microphone;
  
  public class ColorHolic extends Sprite {

    private static const DEFAULT_POWER:int = 10;

    private static const BUF_WIDTH:int = 320;
    private static const BUF_HEIGHT:int = 240;

    private var sound_:Sound;
    private var power_:Number;
    private var row_:int,col_:int;
    private var crash_:Number;
    private var rot90_:Boolean;
    private var mic_:Microphone;

    public function ColorHolic() {
      power_ = DEFAULT_POWER;
      crash_ = 0;
      row_ = col_ = 1;
      rot90_ = false;
      
      //
      addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
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
    
    private var bmp_:Bitmap;

    public function added_to_stage(evt:Event):void {
      if(this == root) {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.frameRate = 30;
      stage.quality = StageQuality.LOW;
      stage.displayState = StageDisplayState.FULL_SCREEN;
      Mouse.hide();
      }

      //
      mic_ = Microphone.getMicrophone();
      mic_.setSilenceLevel(0);
      mic_.gain = 100;
      mic_.rate = 44;
      mic_.setLoopBack(false);
      mic_.addEventListener(SampleDataEvent.SAMPLE_DATA, onMicSampleData);
      //
      bdViewBuf_ = new BitmapData(BUF_WIDTH,BUF_HEIGHT);
      bdView_ = new BitmapData(stage.stageWidth,stage.stageHeight);
      bmp_ = addChild(new Bitmap(bdView_)) as Bitmap;
      //
      bdViewLeft_ = new BitmapData(BUF_WIDTH/2,BUF_HEIGHT);
      bdViewRight_ = new BitmapData(BUF_WIDTH/2,BUF_HEIGHT);

      addEventListener(Event.ENTER_FRAME, loop);
      stage.addEventListener(KeyboardEvent.KEY_DOWN,onkeydown);
      stage.addEventListener(Event.RESIZE, resize);
    }
    private function resize(evt:Event):void {
      removeChild(bmp_);
      bdView_.dispose();
      bdView_ = new BitmapData(stage.stageWidth,stage.stageHeight);
      bmp_ = addChild(new Bitmap(bdView_)) as Bitmap;
    }
    private function onkeydown(evt:KeyboardEvent):void {
      if(!visible) return;
      var code:int = evt.keyCode;
      if(49 <= code && code <= 57 ) { // 1-9
        evt.shiftKey ? row_ = code-48 : col_ = code-48;
      } else if(code == Keyboard.DOWN) {
        if(evt.shiftKey) {
          crash_ -= 0.03;
          if(crash_ < -1 ) crash_ = -1;
        } else {
          power_ -= 10;
          if(power_ < 10) power_ = 10;
        }
      } else if(code == Keyboard.UP) {
        if(evt.shiftKey) {
          crash_ += 0.03;
          if(crash_ > 1) crash_ = 1;
        } else {
          power_ += 10;
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

    private var buf_:ByteArray;
    public function onMicSampleData(evt:SampleDataEvent):void {
      buf_ = evt.data;
    }
    private function loop(evt:Event):void {
      if(!visible) return;
      if(!buf_) return;

      var f:Number,fv:Number;
      var thick_right:Number = 0;
      var thick_left:Number = 0;

/*       var fft:ByteArray = new ByteArray(); */
/*       SoundMixer.computeSpectrum(fft,false); */
/*       for(f=1.0;f<=256.0;f+=1) { */
/*         fv = fft.readFloat(); */
/*         thick_left += Math.pow(fv/f,3); */
/*       } */
/*       // */
/*       for(f=1.0;f<=256.0;f+=1) { */
/*         fv = fft.readFloat(); */
/*         thick_right += Math.pow(fv/f,3); */
/*       } */
      f = 1.0;
      while(buf_.bytesAvailable && f <= 256.0) {
        f += 1.0;
        thick_left += Math.pow(buf_.readFloat()/f,1);
        thick_right += Math.pow(buf_.readFloat()/f,1);
      }
      //
      thick_left *= power_;
      thick_right *= power_;

      var s:Shape = new Shape();
      var g:Graphics = s.graphics;

      //
      g.clear();
      g.beginFill(0x000000);
      g.drawRect(0,0,BUF_WIDTH/2,BUF_HEIGHT);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)+(BUF_HEIGHT-thick_left)/2,BUF_WIDTH/2,thick_left);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)+(BUF_HEIGHT-thick_left)/2,BUF_WIDTH/2,thick_left);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_left*(Math.random()-0.5),thick_left*(Math.random()-0.5)+(BUF_HEIGHT-thick_left)/2,BUF_WIDTH/2,thick_left);
      g.endFill();
      bdViewLeft_.draw(s);
      //
      g.clear();
      g.beginFill(0x000000);
      g.drawRect(0,0,BUF_WIDTH/2,BUF_HEIGHT);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)+(BUF_HEIGHT-thick_right)/2,BUF_WIDTH/2,thick_right);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)+(BUF_HEIGHT-thick_right)/2,BUF_WIDTH/2,thick_right);
      g.endFill();
      g.beginFill(0xffffff,0.7);
      g.drawRect(thick_right*(Math.random()-0.5),thick_right*(Math.random()-0.5)+(BUF_HEIGHT-thick_right)/2,BUF_WIDTH/2,thick_right);
      g.endFill();
      bdViewRight_.draw(s);
      //
      bdViewBuf_.lock();
      bdViewBuf_.copyPixels(bdViewLeft_,bdViewLeft_.rect,new Point(0,0));
      bdViewBuf_.copyPixels(bdViewRight_,bdViewRight_.rect,new Point(BUF_WIDTH/2,0));
      bdViewBuf_.unlock();
      
      bdView_.lock();
      var mat:Matrix = new Matrix();
      mat.scale(1/col_*stage.stageWidth/BUF_WIDTH,1/row_*stage.stageHeight/BUF_HEIGHT);
      for(var x:int=0;x<col_;x++) {
        var mat2:Matrix = mat.clone();
        for(var y:int=0;y<row_;y++) {
          bdView_.draw(bdViewBuf_,mat2);
          mat2.translate(0,stage.stageHeight/row_);
        }
        mat.translate(stage.stageWidth/col_,0);
      }

      if(rot90_) {
        var bdTmp2:BitmapData = bdView_.clone();
        var mat90:Matrix = new Matrix();
        mat90.translate(0,-stage.stageHeight);
        mat90.rotate(Math.PI/2);
        mat90.scale(stage.stageWidth/stage.stageHeight,stage.stageHeight/stage.stageWidth);
        bdTmp2.draw(bdView_, mat90);
        bdView_.copyPixels(bdTmp2,bdTmp2.rect,new Point(0,0));
        bdTmp2.dispose();
      }

      var mat_ax:Matrix = new Matrix();
      var r:Number = (Math.random()-0.5)*crash_;
      if(r != 0) mat_ax.rotate(r);
      mat_ax.translate(stage.stageWidth*Math.random()*crash_,-stage.stageHeight*Math.random()*crash_);
      bdView_.draw(bdView_,mat_ax);
      bdView_.unlock();


    }
  }
}
