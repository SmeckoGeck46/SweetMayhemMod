# Friday Night Brickin' with General Mayhem

DISCLAIMER: IF YOU'RE LOOKING FOR THE CHROMATIC SCALES, DECENTSAMPLER INSTRUMENTS, AND UTAU VOICEBANKS, CHECK THE ARTS FOLDER.

This is the repository for Friday Night Brickin' with General Mayhem, a mod for FNF.

The mod uses Disappointing+, a fork of the Modding+ engine.

Additional technical features included in this mod:
- Camera zooms in while focusing on the player during the Game Over screen
- The Gitaroo screen is easily customizable
  - The Gitaroo screen has a 100% of showing up in a debug build for the sake of testing and editing
- Support for separated vocal tracks and combined vocal tracks (taken from FPS Plus)
- Zooming in and out in the Charting Menu + other Charting Menu optimization (taken from Psych Engine)
- Hscript files can work as .hx, .hscript, or .hxs
- New modchart options:
  - bfSpeed: changes the player's dancing speed
  - dadSpeed: changes the opponent's dancing speed
  - hideEverything: hides all of the UI without hiding the pause screen (doing `camHUD.visible = false;` hides the UI but also hides the pause screen, making it a road block for users)
  - goSpammy: turns on ghost-tapping in the middle of the song; perfect for custscenes in the middle of a song

- Play the Original Game: https://ninja-muffin24.itch.io/funkin

## Credits for the Original Game

- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [KawaiSprite](https://twitter.com/kawaisprite) - Musician

## Disappointing+ Credits

- [Roblox Disappointment](https://github.com/AFunkinDisappointment) - Owner/Programmer

## Modding+ Credits

- [BulbyVR](https://github.com/TheDrawingCoder-Gamer) - Owner/Programmer
- [DJ Popsicle](https://gamebanana.com/members/1780306) - Co-Owner/Additional Programmer
- [Matheus L/Mlops](https://gamebanana.com/members/1767306), [AndreDoodles](https://gamebanana.com/members/1764840), riko, Raf, ElBartSinsoJaJa, and [plum](https://www.youtube.com/channel/UCXbiI4MJD9Y3FpjW61lG8ZQ) - Artist & Animation
- [ThePinkPhantom/JuliettePink](https://gamebanana.com/members/1892442) - Portrait Artist
- [Alex Director](https://gamebanana.com/members/1701629) - Icon Fixer
- [Drippy](https://github.com/TrafficKid) - GitHub Wikipedia
- [GwebDev](https://github.com/GrowtopiaFli) - Edited WebM code
- [Axy](https://github.com/timeless13GH) - Poggers help
## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND PLAY THE GAME NORMALLY, GO TO GAMEBANANA TO DOWNLOAD THE GAME FOR PC!!

https://gamebanana.com/gamefiles/14264

IF YOU WANT TO COMPILE THE GAME YOURSELF, OR PLAY ON MAC OR LINUX, CONTINUE READING!!!

IF YOU MAKE A MOD AND DISTRIBUTE A MODIFIED / RECOMIPLED VERSION, YOU MUST OPEN SOURCE YOUR MOD AS WELL

### Installing shit

First you need to install Haxe and HaxeFlixel. Make sure you download the latest version of Haxe and Haxeflixel.
Here's a link to the [HaxeFlixel website.](https://haxeflixel.com/documentation/getting-started/)

Other installations you'd need is the additional libraries, a fully updated list will be in `Project.xml` in the project root, but here are the one's I'm using as of writing.

```
hscript
flixel-ui
tjson
json2object
uniontypes
hxcpp-debug-server
```

So for each of those type `haxelib install [library]` so shit like `haxelib install hscript`

You'll also need to install hscript-ex. Do this with

```
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
```


### Compiling game


To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run 'lime test linux -debug' and then run the executible file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
* C++ Profiling tools
* C++ CMake tools for windows
* C++ ATL for v142 build tools (x86 & x64)
* C++ MFC for v142 build tools (x86 & x64)
* C++/CLI support for v142 build tools (14.21)
* C++ Modules for v142 build tools (x64/x86)
* Clang Compiler for Windows
* Windows 10 SDK (10.0.17134.0)
* Windows 10 SDK (10.0.16299.0)
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v140 - VS 2015 C++ build tools (v14.00)

This will install about 22GB of crap, but once that is done you can open up a command line in the project's directory and run `lime test windows -debug` for debug testing or `lime test windows` for main release testing. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\debug\windows\bin for debug builds or export\release\windows\bin for release builds. If you don't want to run the game automatically after compiling, use `lime build windows` instead.
As for Mac, `lime test macos` and `lime build macos` should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.
### Additional guides

- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
