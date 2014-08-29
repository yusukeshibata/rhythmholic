package {

  import flash.system.*;
  
  public class WelcomeLines implements ILines {

    private static const WELCOMELINES:Array = 
      [
       '/** RHYTHMHOLIC */',
       ' ',
       'Semitransparent Design & Keiichiro Shibuya',
       '@ WOMB',
       ': Fri, 30 Jul 2010 25:00- JST',
       ' ',
       ' ',

       'Copyright (c) 2010- Semitransparent Design. All rights reserved.',
       ' ',

       // system profile
       'System total memory: ' + System.totalMemory + 'bytes',
       'System Capabilities: ',
       
       '  avHardwareDisable   : '+Capabilities.avHardwareDisable,
       '  hasAccessibility    : '+Capabilities.hasAccessibility,
       '  hasAudio            : '+Capabilities.hasAudio,
       '  hasAudioEncoder     : '+Capabilities.hasAudioEncoder,
       '  hasEmbeddedVideo    : '+Capabilities.hasEmbeddedVideo,
       '  hasIME              : '+Capabilities.hasIME,
       '  hasMP3              : '+Capabilities.hasMP3,
       '  hasPrinting         : '+Capabilities.hasPrinting,
       '  hasScreenBroadcast  : '+Capabilities.hasScreenBroadcast,
       '  hasScreenPlayback   : '+Capabilities.hasScreenPlayback,
       '  hasStreamingAudio   : '+Capabilities.hasStreamingAudio,
       '  hasStreamingVideo   : '+Capabilities.hasStreamingVideo,
       '  hasTLS              : '+Capabilities.hasTLS,
       '  hasVideoEncoder     : '+Capabilities.hasVideoEncoder,
       '  isDebugger          : '+Capabilities.isDebugger,
       '  language            : '+Capabilities.language,
       '  localFileReadDisable: '+Capabilities.localFileReadDisable,
       '  manufacturer        : '+Capabilities.manufacturer,
       '  os                  : '+Capabilities.os,
       '  pxielAspectRatio    : '+Capabilities.pixelAspectRatio,
       '  playerType          : '+Capabilities.playerType,
       '  screenColor         : '+Capabilities.screenColor,
       '  screenDPI           : '+Capabilities.screenDPI,
       '  screenResolutionX   : '+Capabilities.screenResolutionX,
       '  screenResolutionY   : '+Capabilities.screenResolutionY,
       '  version             : '+Capabilities.version,


       ' ',
       '/** ***********************',
       'Using font data from tFont/fTime EXHIBITION IN YCAM 2009',
       '43494 files @Sep 25 2009',
       'by Semitransparent Design.',
       '************************* */',
       ' ',
       'Font initialization starting...',
       ];

    public function get length():int {
      return WELCOMELINES.length;
    }
    public function get(i:int):String {
      return WELCOMELINES[i];
    }
  }
}
