package {
  
  public class Logger implements ILines {

    private static var log_:Vector.<String> = new Vector.<String>();

    public static function log(str:String):void {
      log_.push(str);
    }
    public function get length():int {
      return log_.length;
    }
    public function get(i:int):String {
      return log_[i];
    }
  }
}
