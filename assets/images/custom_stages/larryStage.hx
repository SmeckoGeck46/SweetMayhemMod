function start(song) {
	//set up the character placements and stuff so there
	scaleChar('gf', 0.8);
	getHaxeActor("gf").x -= 65;
	getHaxeActor("gf").y -= 65;
	getHaxeActor("dad").x += 50;
	getHaxeActor("dad").y -= 20;
	getHaxeActor("bf").x += 150;
	getHaxeActor("bf").y -= 20;
	//camera adjustments
	getHaxeActor("bf").followCamX -= 169;
	getHaxeActor("bf").followCamY += 50;
	getHaxeActor("dad").followCamX += 42;
	setDefaultZoom(0.65);
	//camera startup for this engine, taken from the Winter Horrorland cutscene lol
	currentPlayState.camFollow.x = 800;
	currentPlayState.camFollow.y = 420;
	FlxG.camera.focusOn(currentPlayState.camFollow.getPosition());

	var sky_chef_peepee_BEPIS = new FlxSprite(-600,-300).loadGraphic(hscriptPath + 'gradientSky.png');
	sky_chef_peepee_BEPIS.setGraphicSize(Std.int(sky_chef_peepee_BEPIS.width * 1.3));
	sky_chef_peepee_BEPIS.scrollFactor.set(0.3, 0.3);
	sky_chef_peepee_BEPIS.antialiasing = true;
	addSprite(sky_chef_peepee_BEPIS, BEHIND_ALL);

	var hills_behind = new FlxSprite(-600,-600).loadGraphic(hscriptPath + 'HillBack.png');
	hills_behind.scrollFactor.set(0.5, 0.3);
	hills_behind.antialiasing = true;
	addSprite(hills_behind, BEHIND_ALL);

	var hillHouse_ploobs = new FlxSprite(-600,-600).loadGraphic(hscriptPath + 'HillFront.png');
	hillHouse_ploobs.scrollFactor.set(0.6, 0.3);
	hillHouse_ploobs.antialiasing = true;
	addSprite(hillHouse_ploobs, BEHIND_ALL);

	var platformOnStrings = new FlxSprite(-650,-520).loadGraphic(hscriptPath + 'PlatformBase.png');
	platformOnStrings.setGraphicSize(Std.int(platformOnStrings.width * 1.1));
	platformOnStrings.scrollFactor.set(1,1);
	platformOnStrings.antialiasing = true;
	platformOnStrings.updateHitbox();
	addSprite(platformOnStrings, BEHIND_ALL);

	//char swap offsets [0 = bf.x, 1 = bf.y, 2 = gf.x, 3 = gf.y, 4 = dad.x, 5 = dad.y];
	swapOffsets[0] += 200;
	swapOffsets[1] -= 20;
	swapOffsets[2] -= 65;
	swapOffsets[3] -= 65;
	swapOffsets[4] += 50;
	swapOffsets[5] -= 65;
}

function playerOneSing() { //code that healths the bar
	if(currentPlayState.demoMode) { currentPlayState.health += 0.02; }//healths the bar in demo mode only
}
