package {
  import flash.events.*;
  import flash.display.*;
  import flash.text.*;
  import flash.utils.*;
  import flash.geom.*;
  
  public class LogScreen extends Sprite {

    [Embed(source='./tnk_BSD.otf',embedAsCFF='false',fontName='myFont',mimeType='application/x-font')] private static const MYFONT:Class;

    

    public static const FINISHED:String = 'finished';
    private static const FINISHED_LOOP:String = 'finished_loop';
    

    private static const SIZE:Number = 38;

    private var tf_:TextField;
    private var i_:int;
    private var bd_:BitmapData,bd_tmp_:BitmapData;
    private var bmp_:Bitmap;
    private var container_:Sprite;
    private var lines_:ILines;

    public function LogScreen() {
      i_ = 0;
      addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
      addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
    }
    public function removed_from_stage(evt:Event):void {
      removeChild(bmp_);
      bd_.dispose();
      bd_tmp_.dispose();
    }
    public function added_to_stage(evt:Event):void {
      bd_ = new BitmapData(stage.stageWidth,stage.stageHeight,false,0x0000ff);
      bd_tmp_ = new BitmapData(stage.stageWidth,stage.stageHeight,false,0x0000ff);
      bmp_ = addChild(new Bitmap(bd_)) as Bitmap;

      container_ = new Sprite();
      addChild(container_);

      var fmt:TextFormat = new TextFormat();
      fmt.font = "myFont";
      fmt.size = SIZE;
      tf_ = new TextField();
      tf_.antiAliasType = AntiAliasType.NORMAL;
      tf_.autoSize = TextFieldAutoSize.LEFT;

      tf_.wordWrap = true;
      tf_.multiline = true;
      tf_.width = stage.stageWidth;

      tf_.selectable = false;
      tf_.embedFonts = true;
      tf_.defaultTextFormat = fmt;
      tf_.textColor = 0xffffff;
      tf_.text = ' ';
      tf_.x = 1.5;
      tf_.y = 0.5;
      container_.addChild(tf_);
      //
    }
    public function start():void {
      reset();
      stage.frameRate = 6;
      stage.quality = StageQuality.HIGH;
      addEventListener(FINISHED_LOOP, loop_finished);
      lines_ = new WelcomeLines();
      addEventListener(Event.ENTER_FRAME, loop);
    }
    private function loop_finished(evt:Event):void {
      removeEventListener(Event.ENTER_FRAME, loop);
      if(lines_ is WelcomeLines) {
        idle(6,function():void {
            stage.frameRate = 120;
            lines_ = new Logger();
            reset(0xffffff,0x000000);
            addEventListener(Event.ENTER_FRAME, loop);
          });
      } else {
        idle(4, function():void {
            dispatchEvent(new Event(FINISHED));
          });
      }
    }
    private function reset(fgcolor:uint=0xffffff,bgcolor:uint=0x0000ff):void {
      i_ = 0;
      tf_.y = 0.5;
      tf_.text = ' ';
      tf_.textColor=fgcolor;
      bd_.fillRect(new Rectangle(0,0,stage.stageWidth,stage.stageHeight),bgcolor);
      bd_tmp_.fillRect(new Rectangle(0,0,stage.stageWidth,stage.stageHeight),bgcolor);
    }
    private function loop(evt:Event):void {
      bd_.lock();

      if(i_>=lines_.length) {
        dispatchEvent(new Event(FINISHED_LOOP));
        return;
      }
      tf_.text = lines_.get(i_);
      tf_.visible = false;
      while(tf_.y+tf_.numLines*SIZE > stage.stageHeight) {
        tf_.y -= SIZE;
        bd_tmp_.draw(this,new Matrix(1,0,0,1,0,-SIZE));
        bd_.copyPixels(bd_tmp_,new Rectangle(0,0,stage.stageWidth,stage.stageHeight),new Point(0,0));
      }
      tf_.visible = true;
      // burn tf_
      bd_.draw(container_);
      //
      tf_.y += tf_.numLines*SIZE;
      tf_.text = '';
      i_++;

      bd_.unlock();
    }
    private function idle(sec:uint,onComplete:Function):void {
      var s:Timer = new Timer(sec*1000,1);
      s.addEventListener(TimerEvent.TIMER,onComplete);
      s.start();
    }

  }
}
