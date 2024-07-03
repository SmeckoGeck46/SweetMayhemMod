package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = [];
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float){
		super();
		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfastMayhem' + TitleState.soundExt, true, true);
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);
		if (!OptionsHandler.options.skipModifierMenu) { menuItems = ['Resume', 'Restart Song', 'Change Options', 'Change Modifiers', 'Edit Chart', 'Exit to menu', 'nut button']; }
		else { menuItems = ['Resume', 'Restart Song', 'Change Options', 'Edit Chart', 'Exit to menu', 'nut button']; }
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length){
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float){
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_MENU;
		var downP = controls.DOWN_MENU;
		var accepted = controls.ACCEPT;

		if (upP) { changeSelection(-1); }
		if (downP) { changeSelection(1); }

		if (accepted){
			var daSelected:String = menuItems[curSelected];
			switch (daSelected){
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					if (PlayState.isStoryMode) { LoadingState.loadAndSwitchState(new StoryMenuState()); }
					else { LoadingState.loadAndSwitchState(new FreeplayState()); }
				case "Change Modifiers":
					LoadingState.loadAndSwitchState(new ModifierState());
				case "Change Options":
					LoadingState.loadAndSwitchState(new SaveDataState());
				case 'Edit Chart': //dunno if this is gonna work or not (spoiler alert: it does)
					LoadingState.loadAndSwitchState(new ChartingState());
				case 'nut button': //nut button
					FlxG.sound.play('assets/sounds/freshIntro' + TitleState.soundExt);
			}
		}

		if (FlxG.keys.justPressed.EIGHT) { FlxG.sound.play('assets/sounds/eight' + TitleState.soundExt); } // EIGHT
	}

	override function destroy(){
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members){
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0){ item.alpha = 1; }
		}
	}
}