package {
  import flash.events.*;
  import flash.display.*;
  import flash.ui.*;
  import com.flashdynamix.utils.SWFProfiler;
  
  public class RhythmHolic extends Sprite {

    private var ftime_:FTime;
    private var color_:ColorHolic;
    private var init_:int;
    private var logscreen_:LogScreen;

    public function RhythmHolic() {
      init_ = 0;
      addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
      addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
    }
    public function removed_from_stage(evt:Event):void {
    }

    public function added_to_stage(evt:Event):void {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.frameRate = 60;
      stage.quality = StageQuality.LOW;
      stage.displayState = StageDisplayState.FULL_SCREEN;
      Mouse.hide();

      ftime_ = new FTime();
      color_ = new ColorHolic();
      addChild(ftime_);
      addChild(color_);
      //
      ftime_.visible = false;
      color_.visible = false;

      var g:Graphics = graphics;
      g.lineStyle(1,0xffffff);
      g.moveTo(0,100);
      g.lineTo(stage.stageWidth,100);

      stage.addEventListener(KeyboardEvent.KEY_DOWN,onkeydown);

      //
      SWFProfiler.init(stage, this);
    }
    private function start():void {
      // initialization finished
      stage.frameRate = 60;
      stage.quality = StageQuality.LOW; 
      //
      ftime_.visible = true;
      color_.visible = false;
      stage.addEventListener(KeyboardEvent.KEY_DOWN,onkeydown);
      init_ = 2;
    }
    private function onkeydown(evt:KeyboardEvent):void {
      var code:int = evt.keyCode;
      if(code == Keyboard.ENTER && evt.shiftKey) {
        ftime_.visible = !ftime_.visible;
        color_.visible = !color_.visible;
      } else if(init_ == 0 && code == Keyboard.SPACE && evt.shiftKey) { 
        graphics.clear();
        //
        logscreen_ = new LogScreen(); 
        addChild(logscreen_);
        init_ = 1;
      } else if(init_ == 1 && code == Keyboard.ENTER) {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN,onkeydown);
        // show log....
        logscreen_.addEventListener(LogScreen.FINISHED,function():void {
            removeChild(logscreen_);
            //
            start();
          });
        logscreen_.start();
      }
    }
  }
}
