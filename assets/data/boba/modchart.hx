function ui_fade_stuff() { //fade away function, referenced this from Friday Hijinks
	new FlxTimer().start(0.01, function(tmr) {
		currentPlayState.healthBar.alpha -= 0.025;
		currentPlayState.healthBarBG.alpha -= 0.025;
		currentPlayState.iconP1.alpha -= 0.025;
		currentPlayState.iconP2.alpha -= 0.025;
		if (currentPlayState.useSongBar) {
			currentPlayState.songPosBG.alpha -= 0.025;
			currentPlayState.songPosBar.alpha -= 0.025;
			currentPlayState.songName.alpha -= 0.025;
		}
		for (strum in enemyStrums) { strum.alpha -= 0.025; }
    	for (strum in playerStrums) { strum.alpha -= 0.025; }

		if (currentPlayState.healthBar.alpha > 0) {
			tmr.reset(0.01);
		} else {
			currentPlayState.healthBar.alpha = 0;
			currentPlayState.healthBarBG.alpha = 0;
			currentPlayState.iconP1.alpha = 0;
			currentPlayState.iconP2.alpha = 0;
			if (currentPlayState.useSongBar) {
				currentPlayState.songPosBG.alpha = 0;
				currentPlayState.songPosBar.alpha = 0;
				currentPlayState.songName.alpha = 0;
			}
			for (strum in enemyStrums) {
				strum.alpha = 0;
			}
			for (strum in playerStrums) {
				strum.alpha = 0;
			}
}});}

function start(song) { //preload pipis
	trace("Pipis.");
	currentPlayState.camPoseSwap = false;
	currentPlayState.gfSpeed = 2;
}

function beatHit(beat) { //hscript property stuff
	switch (beat) {
		case 64, 288: //speed up GF
			currentPlayState.gfSpeed = 1;
		case 224: //slow down GF
			currentPlayState.gfSpeed = 2;
		case 210, 217, 219: //reverse the camera position rules
			currentPlayState.camPoseSwap = true;
		case 214, 218, 222: //restore the camera position rules
			currentPlayState.camPoseSwap = false;
		case 359: //character animation for the end
			ui_fade_stuff();
			setDefaultZoomOld(0.69);
			dad.followCamX += 30;
			dad.followCamY += 40;
			boyfriend.followCamX -= 150;
			boyfriend.followCamY += 10;
			FlxG.sound.play(FNFAssets.getSound('assets/sounds/Boba_Cutscene' + TitleState.soundExt));
			dad.playAnim('hair_JUST_GO_FOR_IT');
			boyfriend.playAnim('hair_JUST_GO_FOR_IT');
			gf.playAnim('hair_padildo');
			currentPlayState.goSpammy = true; //ghost tapping turned on just for the cutscene
			new FlxTimer().start(0.6, function(tmr) { currentPlayState.camZooming = false; });
	}
}
//the only reason this .hx file works as a modchart is because of source code editing lololololol