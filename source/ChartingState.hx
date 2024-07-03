package;

import openfl.net.FileFilter;
import Section.SwagSection;
import Song.SwagSong;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import tjson.TJSON;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end

using StringTools;

enum abstract NoteTypes(Int) from Int to Int {
	@:op(A == B) static function _(_, _):Bool;

	var Normal;
	var Lift;
	var Mine;
	var Death;
}
class ChartingState extends MusicBeatState {
	//var _file:FileReference;
	var _load:FileReference;

	public var playClaps:Bool = false;
	var claps:Array<EdtNote> = [];

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var welcomeOld:FlxText;
	var modeTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var noteTypeText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;
	var zoomFactor:Int = 1;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<EdtNote>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var prevGrid:FlxSprite;
	var nextGrid:FlxSprite;
	var showPrevNext:Bool = true;
	var gridBG:FlxSprite;
	var gridBlackLine:FlxSprite;
	var gridBeatLines:Array<FlxSprite> = [];

	public static var _song:SwagSong;
	var noteType:Int = Normal;
	var typingShit:FlxInputText;
	var player1TextField:FlxInputText;
	var player2TextField:FlxInputText;
	var gfTextField:FlxInputText;
	var cutsceneTextField:FlxInputText;
	var uiTextField:FlxInputText;
	var stageTextField:FlxInputText;
	var stageID:FlxUINumericStepper;
	var isAltNoteCheck:FlxUICheckBox;
	
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	var vocalsOther:FlxSound;
	private var vocalType:Int = 1; //noVocalTrack = 0, combinedVocalTrack = 1, splitVocalTrack = 2

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var useLiftNote:Bool = false;
	var sideChoosen = 0;

	//taken from Psych Engine because I thought it was cool and very useful
	public static var quantization:Int = 16;
	public static var curQuant = 3;
	public var quantizations:Array<Int> = [4,8,12,16,20,24,32,48,64,96,128,192,256,512];

	override function create() {
		curSection = lastSection;

		PlayState.startingPosition = 0;
		//taken from Psych Engine because I thought it was cool lol
		var bg_lol:FlxSprite = new FlxSprite().loadGraphic("assets/images/menuDesat.png");
		bg_lol.antialiasing = true;
		bg_lol.scrollFactor.set();
		bg_lol.color = 0x2B1526; //FlxSprite supports either 0xRRGGBB or 0xAARRGGBB, but the AA gets ignored
		add(bg_lol);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);
		
		prevGrid = gridBG.clone();
		prevGrid.alpha = 0.5;
		prevGrid.y = gridBG.y - prevGrid.height;
		add(prevGrid);

		nextGrid = prevGrid.clone();
		nextGrid.alpha = 0.5;
		nextGrid.y = gridBG.y + nextGrid.height;
		add(nextGrid);


		leftIcon = new HealthIcon('bf-lego'); //BF side
		rightIcon = new HealthIcon('mayhemMasked'); //Dad side
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(gridBG.x + gridBG.width / 4 - leftIcon.width / 2, -100);
		rightIcon.setPosition(gridBG.x + 3*gridBG.width / 4 - rightIcon.width / 2, -100);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2 - 1, -gridBG.height).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		for (i in 1...11) {
			var beatLine = new FlxSprite(gridBG.x, prevGrid.y + gridBG.height / 4 * i - 1).makeGraphic(Std.int(gridBG.width), 2, FlxColor.BLACK);
			switch(i) {
				case 3 | 7:
					// section line
				default:
					beatLine.alpha = 0.5;
			}
			add(beatLine);
			gridBeatLines.push(beatLine);
		}

		curRenderedNotes = new FlxTypedGroup<EdtNote>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else {
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				isHey: false,
				speed: 1,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				isCheer: false,
				preferredNoteAmount: 4,
				forceJudgements: false,
				convertMineToNuke: false,
				mania: 0,
				stageID: 0
			};
		}

		FlxG.mouse.visible = true;
		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		welcomeOld = new FlxText(50, 50, 0, "Welcome to\nthe Charting Menu", 20);
		welcomeOld.setFormat("assets/fonts/CooperHewitt-Bold.otf", 22, 0x19f5ff, LEFT, FlxTextBorderStyle.OUTLINE, 0xff000000);
		welcomeOld.scrollFactor.set();
		add(welcomeOld);

		bpmTxt = new FlxText(700, 50, 0, "", 16);
		bpmTxt.setFormat("assets/fonts/CooperHewitt-Bold.otf", 22, 0x19f5ff, LEFT, FlxTextBorderStyle.OUTLINE, 0xff000000);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);
		
		modeTxt = new FlxText(700, 500, 0, "Left Mouse Click: Add/Delete Note\nRight Mouse Click: Select Note\nJ: More step snaps\nK: Fewer step snaps\nZ: Zoom grid in\nX: Zoom grid out", 20);
		modeTxt.setFormat("assets/fonts/CooperHewitt-Bold.otf", 22, 0x19f5ff, LEFT, FlxTextBorderStyle.OUTLINE, 0xff000000);
		modeTxt.scrollFactor.set();
		add(modeTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Char", label: 'Char'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width * (3 / 4);
		UI_box.y = 20;
		add(UI_box);
		noteTypeText = new FlxText(FlxG.width / 2, FlxG.height, 0, "<(I) Normal Note (O)>", 16);
		noteTypeText.y -= noteTypeText.height;
		noteTypeText.setFormat("assets/fonts/CooperHewitt-Bold.otf", 22, 0x19f5ff, LEFT, FlxTextBorderStyle.OUTLINE, 0xff000000);
		noteTypeText.scrollFactor.set();
		add(noteTypeText);
		addSongUI();
		addSectionUI();
		addNoteUI();
		addCharsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		changeSection(curSection);

		super.create();
	}

	function addSongUI():Void {
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function() {
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function() {
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function() {
			saveLevel();
		});
		
		var loadButton:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Load", function() { // stole this from Mic'd Up lol
				load();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function() {
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function() {
			loadJson(_song.song.toLowerCase());
		});
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		/*var stepperNotes:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 1, 4, 1, 9, 0);
		stepperNotes.value = _song.preferredNoteAmount;
		stepperNotes.name = 'song_notes';*/

		var hitsounds = new FlxUICheckBox(10, 300, null, null, "Play Hit Sounds", 100); //stole this because charting is a pain without it lol
		hitsounds.checked = false;
		hitsounds.callback = function() {
			playClaps = hitsounds.checked;
		};

		var isHeyCheck = new FlxUICheckBox(10, 150, null, null, "Is Hey", 100);
		var isCheerCheck = new FlxUICheckBox(100, 150, null, null, "Is Cheer", 100);
		var isMoodyCheck = new FlxUICheckBox(10, 170, null, null, "Is Moody", 100);
		var isSpookyCheck = new FlxUICheckBox(100, 170,null,null,"Is Spooky", 100);
		isHeyCheck.name = "isHey";
		isCheerCheck.name = "isCheer";
		isMoodyCheck.name = "isMoody";
		isSpookyCheck.name = 'isSpooky';
		isHeyCheck.checked = _song.isHey;
		isCheerCheck.checked = _song.isCheer;
		isMoodyCheck.checked = _song.isMoody;
		isSpookyCheck.checked = _song.isSpooky;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(isMoodyCheck);
		tab_group_song.add(isSpookyCheck);
		tab_group_song.add(isHeyCheck);
		tab_group_song.add(isCheerCheck);
		tab_group_song.add(saveButton);
		tab_group_song.add(loadButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		//tab_group_song.add(stepperNotes);
		tab_group_song.add(hitsounds);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	function addCharsUI():Void {
		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(120, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(120, 120, 70, _song.stage, 8);
		stageID = new FlxUINumericStepper(120, 160, 1, _song.stageID, 0, 999, 0);
		cutsceneTextField = new FlxUIInputText(120, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);

		var playerText = new FlxText(player1TextField.x + 70, player1TextField.y, 0, "Player", 8, false);
		var enemyText = new FlxText(player2TextField.x + 70, player2TextField.y, 0, "Opponent", 8, false);
		var gfText = new FlxText(gfTextField.x + 70, gfTextField.y, 0, "GF", 8, false);
		var stageText = new FlxText(stageTextField.x + 70, stageTextField.y, 0, "Stage", 8, false);
		var cutsceneText = new FlxText(cutsceneTextField.x + 70, uiTextField.y, 0, "Cutscene", 8, false);
		var uiText = new FlxText(uiTextField.x + 70, uiTextField.y, 0, "UI", 8, false);
		var stageIDText = new FlxText(stageID.x + 70, stageID.y, 0, "Stage ID", 8, false);

		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";

		tab_group_char.add(playerText);
		tab_group_char.add(enemyText);
		tab_group_char.add(gfText);
		tab_group_char.add(stageText);
		tab_group_char.add(cutsceneText);
		tab_group_char.add(uiText);
		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(stageID);
		tab_group_char.add(stageIDText);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);

		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();
	}

	var stepperLength:FlxUINumericStepper;
	var stepperAltAnim:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var sectionText = new FlxText(160, 10, 0, "Section Number", 8, false);

		var stepperSection:FlxUINumericStepper = new FlxUINumericStepper(160, 30, 1, 0, -999, 999, 0);
		var sectionButton:FlxButton = new FlxButton(160, 50, "Go to", function() {
			if (Std.int(stepperSection.value) >= 0)
				changeSection(Std.int(stepperSection.value));
		});
		var copyLastButton:FlxButton = new FlxButton(160, 70, "Copy last section", function() {
			if (Std.int(stepperSection.value) != 0)
				copySection(Std.int(stepperSection.value));
		});
		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();

		var clearSectionButton:FlxButton = new FlxButton(10, 100, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 120, "Swap section", function() {
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				var note = _song.notes[curSection].sectionNotes[i];
				var baseNote = (note[1] + _song.preferredNoteAmount) % (_song.preferredNoteAmount * 2);
				var specialValue = note[1] - ((baseNote + _song.preferredNoteAmount) % (_song.preferredNoteAmount * 2)); //lol
				if (specialValue < 0)
					specialValue = 0;
				note[1] = baseNote + specialValue;
				updateGrid();
			}
		});

		// sonic.exe triple trouble 4k converter because lol
		// imagine not having 5k lol
		/*var funnyButton:FlxButton = new FlxButton(10, 300, "Triple Trouble", function() {
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				var note = _song.notes[curSection].sectionNotes[i];
				switch(note[1]) {
					case 2|7:
						note[1] = -1; // these are the ring notes
					case 3|4|5|6:
						note[1] -= 1;
					case 8|9:
						note[1] -= 2;
				}
				switch(note[3]) {
					case 2: //static
						note[1] += 48;
					case 3: //phantom
						note[1] += 40;
				}
				note[3] = 0;
				note[4] = 0;
				updateGrid();
			}
		});*/

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 150, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		stepperAltAnim = new FlxUINumericStepper(10, 170, 1, Conductor.bpm, 0, 999, 0);
		stepperAltAnim.value = 0;
		stepperAltAnim.name = 'alt_anim_number';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		var showSections = new FlxUICheckBox(10, 250, null, null, "Show prev/next section", 100);
		showSections.checked = true;
		showSections.callback = function() {
			showPrevNext = showSections.checked;
			updateGrid();
		};

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(stepperAltAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(sectionText);
		tab_group_section.add(stepperSection);
		tab_group_section.add(sectionButton);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		//tab_group_section.add(funnyButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperAltNote:FlxUINumericStepper;
	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		var lengthTxt = new FlxText(10, 10, 0, 'Note Length', 8, false);
		stepperSusLength = new FlxUINumericStepper(10, 30, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		isAltNoteCheck = new FlxUICheckBox(10, 70, null, null, "Alt Anim Note", 100);
		isAltNoteCheck.name = "isAltNote";
		stepperAltNote = new FlxUINumericStepper(10, 90, 1, 0, 0, 999, 0);
		stepperAltNote.value = 0;
		stepperAltNote.name = 'alt_anim_note';

		var noteTypeButton:FlxButton = new FlxButton(10, 130, "Change Type", function() {
			curSelectedNote[1] %= _song.preferredNoteAmount * 2; // this looks so strange but it works
			switch (noteType) {
				case Mine: 
					curSelectedNote[1] += _song.preferredNoteAmount * 2;
				case Lift: 
					curSelectedNote[1] += _song.preferredNoteAmount * 4;
				case Death: 
					curSelectedNote[1] += _song.preferredNoteAmount * 6;
				case 4:
					// drained
				case key: 
					curSelectedNote[1] += _song.preferredNoteAmount * 2 * key;
			}
			updateGrid();
		});
		

		tab_group_note.add(lengthTxt);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(isAltNoteCheck);
		tab_group_note.add(stepperAltNote);
		tab_group_note.add(noteTypeButton);
		UI_box.addGroup(tab_group_note);
	}

	function changeKeyType(change:Int) {
		noteType += change;
		noteType = cast FlxMath.wrap(noteType, 0, 99);
		noteTypeText.text = '<(I) ';
		switch (noteType) {
			case Normal:
				noteTypeText.text += "Normal Note";
			case Lift:
				noteTypeText.text += "Lift Note";
			case Mine:
				noteTypeText.text += "Mine Note";
			case Death:
				noteTypeText.text += "Death Note";
			case 4: // drain
				noteTypeText.text += "Drain Note";
			default:
				var noteChecked = false;
				if (FileSystem.exists('assets/data/${_song.song.toLowerCase()}/noteInfo.json')) {
					var noteJson = CoolUtil.parseJson(FNFAssets.getText('assets/data/${_song.song.toLowerCase()}/noteInfo.json'));
					if ((noteType - 4) - 1 < noteJson.length) {
						var thingie = noteJson[(noteType - 4) - 1];
						if (thingie.noteName != null) {
							noteTypeText.text += thingie.noteName + ' (${noteType - 4})';
							noteChecked = true;
						}
					} 
				}
				if (!noteChecked)
					noteTypeText.text += 'Custom Note ${noteType - 4}';
				// made it better lol
		}
		noteTypeText.text += ' (O)>';
	}

	function loadSong(daSong:String):Void {
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}
		#if sys
		if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Inst" + TitleState.soundExt)) {
			FlxG.sound.playMusic(Sound.fromFile("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Inst" + TitleState.soundExt), 0.6);
		} else if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/Inst' + TitleState.soundExt)) {
			FlxG.sound.playMusic(Sound.fromFile("assets/songs/" + _song.song.toLowerCase() + '/Inst' + TitleState.soundExt), 0.6);
		} else {
			FlxG.sound.playMusic(Sound.fromFile("assets/music/" + daSong + "_Inst" + TitleState.soundExt), 0.6);
		}
		//FlxG.sound.playMusic(Sound.fromFile("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Inst" + TitleState.soundExt), 0.6);
		#else
		FlxG.sound.playMusic('assets/songs/' + _song.song.toLowerCase() + '/' + daSong + "_Inst" + TitleState.soundExt, 0.6);
		#end
		if (_song.needsVoices) {
			#if sys
			var vocalSound = ""; //main vocal track
			var vocalSound_other = ""; //used for opponent and player vocal tracks
			if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices" + TitleState.soundExt)) {
				vocalSound = "assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices" + TitleState.soundExt;
				vocalType = 1;
			} else if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices-Opponent" + TitleState.soundExt) && FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices-Player" + TitleState.soundExt)) {
				vocalType = 2;
				vocalSound = "assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices-Player" + TitleState.soundExt;
				vocalSound_other = "assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices-Opponent" + TitleState.soundExt;
			} else if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/Voices' + TitleState.soundExt)) {
				vocalSound = "assets/songs/" + _song.song.toLowerCase() + '/Voices' + TitleState.soundExt;
				vocalType = 1;
			} else if (FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/Voices-Player' + TitleState.soundExt) && FNFAssets.exists("assets/songs/" + _song.song.toLowerCase() + '/Voices-Opponent' + TitleState.soundExt)) {
				vocalSound = "assets/songs/" + _song.song.toLowerCase() + '/Voices-Player' + TitleState.soundExt;
				vocalSound_other = "assets/songs/" + _song.song.toLowerCase() + '/Voices-Opponent' + TitleState.soundExt;
				vocalType = 2;
			} else if (FNFAssets.exists("assets/music/" + daSong + '_Voices-Player' + TitleState.soundExt) && FNFAssets.exists("assets/music/" + daSong + '_Voices-Opponent' + TitleState.soundExt)) {
				vocalSound = "assets/music/" + daSong + "_Voices-Player" + TitleState.soundExt;
				vocalSound_other = "assets/music/" + daSong + "_Voices-Opponent" + TitleState.soundExt;
				vocalType = 2;
			} else {
				vocalSound = "assets/music/" + daSong + "_Voices" + TitleState.soundExt;
				vocalType = 1;
			}
			vocals = new FlxSound().loadEmbedded(vocalSound);
			if (vocalType == 2) vocalsOther = new FlxSound().loadEmbedded(vocalSound_other);
			#else
			vocals = new FlxSound().loadEmbedded("assets/songs/" + _song.song.toLowerCase() + '/' + daSong + "_Voices" + TitleState.soundExt);
			vocalType = 1;
			#end
			FlxG.sound.list.add(vocals);
			if (vocalType == 2) { FlxG.sound.list.add(vocalsOther); }

		} else { vocalType = 0; }

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
			if(vocalType == 2) { vocalsOther.pause();}
		}

		FlxG.sound.music.onComplete = function() {
			if (_song.needsVoices) {
				vocals.pause();
				vocals.time = 0;
				if(vocalType == 2) {
				vocalsOther.pause();
				vocalsOther.time = 0;
			}}

			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void {
		while (bullshitUI.members.length > 0)
			bullshitUI.remove(bullshitUI.members[0], true);

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);
		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "Is Moody":
					_song.isMoody = check.checked;
				case "Is Spooky":
					_song.isSpooky = check.checked;
				case "Is Hey":
					_song.isHey = check.checked;
				case 'Alt Anim Note':
					if (curSelectedNote != null)
						curSelectedNote[3] = check.checked ? 1 : 0;
					updateNoteUI();
				case 'Is Cheer':
					_song.isCheer = check.checked;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch(wname) {
				case 'section_length':
					_song.notes[curSection].lengthInSteps = Std.int(nums.value);
					updateGrid();
				case 'song_speed':
					_song.speed = nums.value;
				case 'song_bpm':
					tempBpm = nums.value;
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(nums.value);
				case 'song_notes':
					_song.preferredNoteAmount = Std.int(nums.value);
					updateGrid();
					updateHeads();
				case 'note_susLength':
					curSelectedNote[2] = nums.value;
					updateGrid();
				case 'section_bpm':
					_song.notes[curSection].bpm = nums.value;
					updateGrid();
				case 'alt_anim_number':
					_song.notes[curSection].altAnimNum = Std.int(nums.value);
				case 'alt_anim_note':
					if (curSelectedNote != null)
						curSelectedNote[3] = nums.value;
					updateNoteUI();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
	function lengthBpmBullshit():Float
	{
		if (_song.notes[curSection].changeBPM)
			return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
		else
			return _song.notes[curSection].lengthInSteps;
	}*/

	function sectionStartTime(?offset:Int = 0):Float {
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection) {
			if (_song.notes[i].changeBPM) {
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	/*function checkForBads() { // like spell check but for charts
		_song.notes.forEach(function(note:EdtNote) {
			_song.notes.forEach(function(checknote:EdtNote) {
				if (note[0] == checknote[0] && note[1] == checknote[1])
					_song.notes[curSection].sectionNotes.remove();
			});
		});
	}*/

	override function update(elapsed:Float) {
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		_song.player1 = player1TextField.text;
		_song.player2 = player2TextField.text;
		_song.gf = gfTextField.text;
		_song.stage = stageTextField.text;
		_song.stageID = Std.parseInt(Std.string(stageID.value)); // what
		_song.cutsceneType = cutsceneTextField.text;
		_song.uiType = uiTextField.text;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (playClaps) {
			curRenderedNotes.forEach(function(note:EdtNote) {
				if (FlxG.sound.music.playing) {
					FlxG.overlap(strumLine, note, function(_, _) {
						if(!claps.contains(note)) {
							claps.push(note);
							FlxG.sound.play('assets/sounds/hitSound.ogg');
						}
					});
				}
			});
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1)) {
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null) {
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		if (FlxG.keys.justPressed.M) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:EdtNote) {
					if (FlxG.mouse.overlaps(note)) {
						trace(note.strumTime);
						trace(note.noteData);
						trace(note.sustainLength);
					}
				});
			}
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);
		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:EdtNote) {
					if (FlxG.mouse.overlaps(note)) {
						deleteNote(note);
					}
				});
			} else {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps * zoomFactor)) {
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.justPressedRight) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:EdtNote) {
					if (FlxG.mouse.overlaps(note)) {
						selectNote(note);
					}
				});
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps * zoomFactor)) {
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else {
				var gridmult = GRID_SIZE / (quantization / 16); //taken from psych engine lol
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridmult) * gridmult;
			}
		} else {
			dummyArrow.visible = false;
		}

		if (FlxG.keys.justPressed.ENTER) {
			lastSection = curSection;

			if (FlxG.keys.pressed.SHIFT) {
				PlayState.startingPosition = Conductor.songPosition;
			}

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if (_song.needsVoices) {
				vocals.stop();
				if(vocalType == 2) vocalsOther.stop();
			}

			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (!typingShit.hasFocus && !player1TextField.hasFocus && !player2TextField.hasFocus && !gfTextField.hasFocus && !stageTextField.hasFocus && !cutsceneTextField.hasFocus && !uiTextField.hasFocus) {
			if (FlxG.keys.justPressed.E) {
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q) {
				changeNoteSustain(-Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.TAB) {
				if (FlxG.keys.pressed.SHIFT) {
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				} else {
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}
			var shiftThing:Int = 1;
			if (FlxG.keys.justPressed.SPACE) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
						if(vocalType == 2) vocalsOther.pause();
					}
					claps.splice(0, claps.length);
				} else {
					if (_song.needsVoices) {
						vocals.play();
						if(vocalType == 2) vocalsOther.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0){
				FlxG.sound.music.pause();
				if (_song.needsVoices) {
					vocals.pause();
					if(vocalType == 2) vocalsOther.pause();
				}


				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				if (_song.needsVoices) {
					vocals.time = FlxG.sound.music.time;
					vocalsOther.time = FlxG.sound.music.time;
				}

			}
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) { changeSection(curSection + shiftThing); }
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) { changeSection(curSection - shiftThing); }
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.SHIFT){
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S){
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
						if(vocalType == 2) vocalsOther.pause();
					}


					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W){
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
						if(vocalType == 2) vocalsOther.time = FlxG.sound.music.time;
					}

				}
			} else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
						if(vocalType == 2) vocalsOther.pause();
					}

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W){
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
						if(vocalType == 2) vocalsOther.time = FlxG.sound.music.time;
					}
				}
			}

			if (FlxG.keys.justPressed.Z) {
				zoomFactor += 1;
				if (zoomFactor >= 4)
					zoomFactor = 3;
				updateGrid();
			}
			if (FlxG.keys.justPressed.X) {
				zoomFactor -= 1;
				if (zoomFactor <= 0)
					zoomFactor = 1;
				updateGrid();
			}

			//quantizations stuff taken from psych engine lol
			if(FlxG.keys.justPressed.K){
				curQuant++;
				if(curQuant>quantizations.length-1)
					curQuant = 0;

				quantization = quantizations[curQuant];
			}
			if(FlxG.keys.justPressed.J){
				curQuant--;
				if(curQuant<0)
					curQuant = quantizations.length-1;

				quantization = quantizations[curQuant];
			}

			if (FlxG.keys.justPressed.I)
				changeKeyType(-1);
			else if (FlxG.keys.justPressed.O)
				changeKeyType(1);
		}

		_song.bpm = tempBpm;

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: " + curSection
			+ '\nBeat: ' + Std.string(curBeat) 
			+ '\nStep: ' + Std.string(curStep)
			+ "\nBeat Snap: " + quantization + "th";
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}
	function toggleNoteAnim():Void {
		if (curSelectedNote != null) {
			if (curSelectedNote[3] != null) {
				curSelectedNote[3] = curSelectedNote[3] == 1 ? 0 : 1;

			} else {
				curSelectedNote[3] = 1;
			}
		}
		updateNoteUI();
	}
	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
			if(vocalType == 2) vocalsOther.pause();
		}

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		}
		if (_song.needsVoices) {
			vocals.time = FlxG.sound.music.time;
			if(vocalType == 2) vocalsOther.time = FlxG.sound.music.time;
		}

		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		trace('changing section' + sec);

		if (_song.notes[sec] != null) {
			curSection = sec;

			if (updateMusic) {
				FlxG.sound.music.pause();
				if (_song.needsVoices) {
					vocals.pause();
					if(vocalType == 2) vocalsOther.pause();
				}


				/*var daNum:Int = 0;
				var daLength:Float = 0;
				while (daNum <= sec)
				{
					daLength += lengthBpmBullshit();
					daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if (_song.needsVoices) {
					vocals.time = FlxG.sound.music.time;
					if(vocalType == 2) vocalsOther.time = FlxG.sound.music.time;
				}

				updateCurStep();
			}

			var pleasehelpme:Null<Int> = null; // I funking LOVE doing weird work arounds for ABSOLUTELY no reason (my favorite is currentKey and currrentKey in PlayState :)
			if (_song.notes[curSection].lengthInSteps == pleasehelpme)
				_song.notes[curSection].lengthInSteps = 16;

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes) {
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void {
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		// note that 0 implies regular anim and 1 implies default alt 
		if (sec.altAnimNum == null) {
			sec.altAnimNum == if (sec.altAnim) 1 else 0;
		}
		stepperAltAnim.value = sec.altAnimNum;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads(transition:Bool = false, ?direction:Int):Void {
		var positionBefore = transition == true ? direction * gridBG.height : 0;
		if (!showPrevNext)
			positionBefore = 0;
		if (check_mustHitSection.checked) {
			leftIcon.setPosition(gridBG.x + gridBG.width / 4 - leftIcon.width / 2, -100 + positionBefore);
			rightIcon.setPosition(gridBG.x + 3*gridBG.width / 4 - rightIcon.width / 2, -100 + positionBefore);
		} else {
			rightIcon.setPosition(gridBG.x + gridBG.width / 4 - rightIcon.width / 2, -100 + positionBefore);
			leftIcon.setPosition(gridBG.x + 3*gridBG.width / 4 - leftIcon.width / 2, -100 + positionBefore);
		}
		if (transition && showPrevNext) {
			FlxTween.tween(rightIcon, {y: -100}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(leftIcon, {y: -100}, 0.5, {ease: FlxEase.circOut});
		}
	}

	function updateNoteUI():Void {
		if (curSelectedNote != null) {
			stepperSusLength.value = curSelectedNote[2];
			// null is falsy
			isAltNoteCheck.checked = cast curSelectedNote[3];
			stepperAltNote.value = curSelectedNote[3] != null ? curSelectedNote[3] : 0;
		}
	}

	function updateGrid():Void {
		while (curRenderedNotes.members.length > 0)
			curRenderedNotes.remove(curRenderedNotes.members[0], true);

		while (curRenderedSustains.members.length > 0)
			curRenderedSustains.remove(curRenderedSustains.members[0], true);

		remove(gridBG);
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * _song.preferredNoteAmount * 2, GRID_SIZE * zoomFactor * 16);
		gridBG.x = GRID_SIZE * 4 - gridBG.width / 2;
		add(gridBG);

		remove(prevGrid);
		prevGrid = gridBG.clone();
		prevGrid.alpha = 0.5;
		prevGrid.setPosition(gridBG.x, gridBG.y - prevGrid.height);
		if (curSection - 1 < 0 || !showPrevNext)
			prevGrid.visible = false;
		add(prevGrid);

		remove(nextGrid);
		nextGrid = prevGrid.clone();
		nextGrid.alpha = 0.5;
		nextGrid.setPosition(gridBG.x, gridBG.y + nextGrid.height);
		if (_song.notes[curSection + 1] == null || !showPrevNext)
			nextGrid.visible = false;
		add(nextGrid);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2 - 1, -gridBG.height).makeGraphic(2, Std.int(gridBG.height*3), FlxColor.BLACK);
		add(gridBlackLine);

		for (i in 0...gridBeatLines.length) {
			remove(gridBeatLines[i]);
			var newline = new FlxSprite(gridBG.x, prevGrid.y + gridBG.height / 4 * (i+1) - 1).makeGraphic(Std.int(gridBG.width), 2, FlxColor.BLACK);
			switch(i) {
				case 3 | 7:
					// section line
				default:
					newline.alpha = 0.5;
			}
			gridBeatLines[i] = newline;
			add(gridBeatLines[i]);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0) {
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			//get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		var yummyPng = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png');
		var yummyXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		for (i in sectionInfo) {
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daLift = i[4];
			
			var note:EdtNote = new EdtNote(daStrumTime, daNoteInfo, daLift);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = gridBG.x + Math.floor((daNoteInfo % (_song.preferredNoteAmount * 2)) * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}

		if (_song.notes[curSection + 1] != null && showPrevNext) {
			var nextSecInfo:Array<Dynamic> = _song.notes[curSection+1].sectionNotes;
			for (i in nextSecInfo) {
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daLift = i[4];
			
				var note:EdtNote = new EdtNote(daStrumTime, daNoteInfo, daLift);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				var sideSwap = _song.notes[curSection+1].mustHitSection != _song.notes[curSection].mustHitSection ? _song.preferredNoteAmount : 0;
				note.x = gridBG.x + Math.floor(((daNoteInfo + sideSwap) % (_song.preferredNoteAmount * 2)) * GRID_SIZE);
		 		note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection+1].lengthInSteps))) + gridBG.height;
				note.alpha = 0.5;

				curRenderedNotes.add(note);

				if (daSus > 0) {
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
					sustainVis.alpha = 0.5;
					curRenderedSustains.add(sustainVis);
				}
			}
		}

		if (curSection - 1 >= 0 && showPrevNext) {
			var prevSecInfo:Array<Dynamic> = _song.notes[curSection-1].sectionNotes;
			for (i in prevSecInfo) {
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daLift = i[4];
			
				var note:EdtNote = new EdtNote(daStrumTime, daNoteInfo, daLift);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				var sideSwap = _song.notes[curSection-1].mustHitSection != _song.notes[curSection].mustHitSection ? _song.preferredNoteAmount : 0;
				note.x = gridBG.x + Math.floor(((daNoteInfo + sideSwap) % (_song.preferredNoteAmount * 2)) * GRID_SIZE);
		 		note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection-1].lengthInSteps))) - gridBG.height;
				note.alpha = 0.5;

				curRenderedNotes.add(note);

				if (daSus > 0) {
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
					sustainVis.alpha = 0.5;
					curRenderedSustains.add(sustainVis);
				}
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void {
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			altAnimNum: 0
		};

		_song.notes.push(sec);
	}

	function selectNote(note:EdtNote):Void {
		var swagNum:Int = 0;
		
		for (i in _song.notes[curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] % (_song.preferredNoteAmount*2) == note.noteData % (_song.preferredNoteAmount*2)) {
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}
			swagNum += 1;
		}

		if (UI_box.selected_tab != 1)
			UI_box.selected_tab = 1;

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:EdtNote):Void {
		for (i in _song.notes[curSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] % (_song.preferredNoteAmount*2) == note.noteData % (_song.preferredNoteAmount*2)) {
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void {
		_song.notes[curSection].sectionNotes = [];
		updateGrid();
	}

	function clearSong():Void {
		for (daSection in 0..._song.notes.length) { _song.notes[daSection].sectionNotes = []; }
		updateGrid();
	}

	private function addNote():Void {
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
		var noteSus = 0;
		switch (noteType) {
			case Mine: 
				noteData += _song.preferredNoteAmount * 2;
			case Lift: 
				noteData += _song.preferredNoteAmount * 4;
			case Death: 
				noteData += _song.preferredNoteAmount * 6;
			case key: 
				noteData += _song.preferredNoteAmount * 2 * key;
		}
		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, false, useLiftNote]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.SHIFT)
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + _song.preferredNoteAmount * 2) % (_song.preferredNoteAmount * 2), noteSus, false, useLiftNote]);

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
	function calculateSectionLengths(?sec:SwagSection):Int{
		var daLength:Int = 0;

		for (i in _song.notes)
		{
			var swagLength = i.lengthInSteps;

			if (i.typeOfSection == Section.COPYCAT)
				swagLength * 2;

			daLength += swagLength;

			if (sec != null && sec == i)
			{
				trace('swag loop??');
				break;
			}
		}

		return daLength;
	}*/

	private var daSpacing:Float = 0.3;

	function loadLevel():Void { trace(_song.notes); }

	function getNotes():Array<Dynamic> {
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
			noteData.push(i.sectionNotes);

		return noteData;
	}

	function loadJson(song:String):Void {
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void {
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void {
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel() {
		var json = { "song": _song };

		var data:String = CoolUtil.stringifyJson(json);

		if ((data != null) && (data.length > 0)){
			/*
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			*/ 
			FNFAssets.askToSave(_song.song.toLowerCase() + '.json', data);
		}
	}
	/*
	function onSaveComplete(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}
	*/
	/**
	 * Called when the save file dialog is cancelled.
	 */
	 /*
	function onSaveCancel(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
	*/
	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	 /*
	function onSaveError(_):Void{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}*/
	
	// stole this from Mic'd Up, sorry not sorry
	private function load() {
		_load = new FileReference();
		_load.addEventListener(Event.SELECT, selectFile);
	
		var Filter = new FileFilter("JSON Files", "*.json");
		_load.browse([Filter]);
	}
	
	function selectFile(_):Void {
		_load.addEventListener(Event.COMPLETE, onLoadComplete);
		_load.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_load.load();
	}
	
	function onLoadError(_):Void {
		_load.removeEventListener(Event.COMPLETE, onLoadComplete);
		_load.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_load = null;
		FlxG.log.error("Problem loading Level data");
	}
	
	function onLoadComplete(_):Void {
		_load.removeEventListener(Event.COMPLETE, onLoadComplete);
		_load.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
	
		if ((_load.data != null) && (_load.data.length > 0)) {
			var songName:String = _load.name;
			songName = songName.substring(0, songName.length - 5);
	
			var cut:String = songName;
			if (songName.contains('-easy') || songName.contains('-hard'))
				cut = cut.substring(0, cut.length - 5);
			else if (songName.contains('-normal'))
				cut = cut.substring(0, cut.length - 7);
	
			trace(songName);
			trace(cut);
	
			PlayState.SONG = Song.loadFromJson(songName.toLowerCase(), cut.toLowerCase());
			FlxG.resetState();
			changeSection(0, true);
	
			FlxG.log.notice("Successfully loaded LEVEL DATA.");
		}
	}
}
