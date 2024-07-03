package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import tjson.TJSON;

class GitarooPause extends MusicBeatState {
	private static var PONY_AS_FIRETRUCK:Bool = false;
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;
	var replaySelect:Bool = false;
	//jsons for everything
	var MAH_BOI_FRIEND = CoolUtil.parseJson(FNFAssets.getJson("assets/images/pauseAlt/bfLol_stuff"));
	var bgStuff = CoolUtil.parseJson(FNFAssets.getJson("assets/images/pauseAlt/pauseBG_stuff"));
	var button_stuff = CoolUtil.parseJson(FNFAssets.getJson("assets/images/pauseAlt/pauseUI_stuff"));
	//json variables
	var shouldScale:Array<Bool> = [];
	var curScale:Array<Float> = [];
	var shouldCenterX:Array<Bool> = [];
	//background stuff
	var bg_X:Array<Float> = [];
	var bg_Y:Array<Float> = [];
	var useMusic:Array<Bool> = [];
	var keepMusicGoing:Array<Bool> = [];
	var musicName:Array<String> = [];
	//bf stuff
	var bfAnim:Array<String> = [];
	var bfFrames:Array<Float> = [];
	var bfX:Array<Float> = [];
	var bfY:Array<Float> = [];
	//cancel button stuff
	var cancel_name:Array<String> = [];
	var cancel_unselected:Array<String> = [];
	var cancel_selected:Array<String> = [];
	var cancel_X:Array<Float> = [];
	var cancel_Y:Array<Float> = [];
	//replay button stuff
	var replay_name:Array<String> = [];
	var replay_unselected:Array<String> = [];
	var replay_selected:Array<String> = [];
	var replay_X:Array<Float> = [];
	var replay_Y:Array<Float> = [];
	
	public function new():Void { super(); }

	override function create() {
		if (FlxG.sound.music != null) { FlxG.sound.music.stop(); }
		if (bgStuff.useMusic) {
			var obamna_SODA = FNFAssets.getSound('assets/music/' + bgStuff.musicName + TitleState.soundExt);
			FlxG.sound.playMusic(obamna_SODA);
		}
		//complicated addition for the music to still play after exiting
		if (bgStuff.keepMusicGoing) { PONY_AS_FIRETRUCK = true; }
		else { PONY_AS_FIRETRUCK = false; }

		var bg:FlxSprite = new FlxSprite(bgStuff.bg_X, bgStuff.bg_Y).loadGraphic('assets/images/pauseAlt/pauseBG.png');
		add(bg);
		if (bgStuff.shouldScale) { bgStuff.setGraphicSize(Std.int(bgStuff.width * bgStuff.curScale)); }

		var bf:FlxSprite = new FlxSprite(MAH_BOI_FRIEND.bfX, MAH_BOI_FRIEND.bfY);
		bf.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/bfLol.png', 'assets/images/pauseAlt/bfLol.xml');
		bf.animation.addByPrefix('lol', MAH_BOI_FRIEND.bfAnim, MAH_BOI_FRIEND.bfFrames);
		bf.animation.play('lol');
		add(bf);
		if (MAH_BOI_FRIEND.shouldCenterX) { bf.screenCenter(X); }
		if (MAH_BOI_FRIEND.shouldScale) { bf.setGraphicSize(Std.int(bf.width * MAH_BOI_FRIEND.curScale)); }

		replayButton = new FlxSprite(button_stuff.replay_X, button_stuff.replay_Y);
		replayButton.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/pauseUI.png', 'assets/images/pauseAlt/pauseUI.xml');
		replayButton.animation.addByPrefix('selected', button_stuff.replay_unselected, 0, false);
		replayButton.animation.appendByPrefix('selected', button_stuff.replay_selected);
		replayButton.animation.play('selected');
		add(replayButton);
		
		cancelButton = new FlxSprite(button_stuff.cancel_X, button_stuff.cancel_Y);
		cancelButton.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/pauseUI.png', 'assets/images/pauseAlt/pauseUI.xml');
		cancelButton.animation.addByPrefix('selected', button_stuff.cancel_unselected, 0, false);
		cancelButton.animation.appendByPrefix('selected', button_stuff.cancel_selected);
		cancelButton.animation.play('selected');
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.LEFT_MENU || controls.RIGHT_MENU) { changeThing(); }

		if (controls.ACCEPT) {
			if (PONY_AS_FIRETRUCK != true) //allows the music to still plays mwa ha ha ha ha
				FlxG.sound.music.stop();
			if (replaySelect) {
				LoadingState.loadAndSwitchState(new PlayState());
			} else {
				if (PlayState.isStoryMode) { //took this from GameOverState for easier navigation
					LoadingState.loadAndSwitchState(new StoryMenuState());
				} else {
					LoadingState.loadAndSwitchState(new FreeplayState());
				}
			}
		}

		super.update(elapsed);
	}

	function changeThing():Void {
		replaySelect = !replaySelect;

		if (replaySelect) {
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		} else {
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
