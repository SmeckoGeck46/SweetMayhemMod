package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
#if typebuild
import plugins.ExamplePlugin;
import plugins.ExamplePlugin.ExampleCharPlugin;
#end
class Main extends Sprite{
	#if sys
	public static var cwd:String;
	#end
	public function new(){
		#if typebuild
			// bring back polandball
			ExamplePlugin;
			ExampleCharPlugin;
		#end
		super();
		#if sys
		cwd = Sys.getCwd();
		#end
		addChild(new FlxGame(0, 0, TitleState, OptionsHandler.options.fpsCap, OptionsHandler.options.fpsCap, true, false));
		//haha this text at the top left corner only shows up in debug mode
		#if debug
		addChild(new FPS(10, 3, 0xFFFFFF));
		addChild(new MemoryCounter(10, 3, 0xFFFFFF));
		#end
	}
}
