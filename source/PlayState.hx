package;

import openfl.display3D.textures.CubeTexture;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.filters.ShaderFilter;
import Shaders;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 50;
	public static var STRUM_X_MIDDLESCROLL = -273;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var shaderUpdates:Array<Float->Void> = [];
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	public var missTxt:FlxText;
	public var ratingTxt:FlxText;
	var ratingTxtTween:FlxTween;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var timeTxt:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public var showCountdown:Bool = true;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	// MCM Variables --
	/// Bopping HUD
	var boppingHUDFactor:Float;
	var boppingHUDTween:FlxTween;
	var boppingGameTween:FlxTween;

	/// Camera Movements
	//// Array with first entry being x, second being y
	var boyfriendCameraMovementPos:Array<Int> = [];
	var cameraMovementFactor:Int = 50;
	var moveCameraWithNotes:Bool = true;
	var opponentCameraMovementPos:Array<Int> = [];

	/// FlipUI
	var flipHUDTween:FlxTween;

	/// Goodbye Hud
	var GoodbyeHUDTween:FlxTween;

	/// Healthbar
	var healthBarOverlay:FlxSprite;

	/// hidehud
	var hidehudTween:FlxTween;

	/// Icon Bops
	var iconP1BopTween:FlxTween;
	var iconP2BopTween:FlxTween;

	/// Set Cam Zoom
	var zoomHUDTween:FlxTween;

	/// shoot
	var shootCpuCounter:Int = 0;
	var shootEventActive:Bool = false;
	var shootLoadSound:FlxSound;
	var shootSound:FlxSound;
	var shootTimer:FlxTimer;
	var shootWarn:FlxSprite;

	/// Stages
	//// Dead Hope
	var DHBFBody:FlxSprite;
	var DHDarkLight:BGSprite;
	var DHDarkWall:BGSprite;
	var DHDeadHallway:FlxSprite;
	var DHFloor:BGSprite;
	var DHLight:BGSprite;
	var DHPixelFloor:BGSprite;
	var DHPixelTable:BGSprite;
	var DHPixelWall:BGSprite;
	var DHTable:BGSprite;
	var DHWall:BGSprite;

	//// Doomsday
	var DoomsdayBGBlood:BGSprite;
	var DoomsdayCamBlood:BGSprite;
	var DoomsdayCamTween:FlxTween;
	var DoomsdayFireFirewall:BGSprite; ///// Lol
	var DoomsdayFireFloor:BGSprite;
	var DoomsdayFireFront:BGSprite;
	var DoomsdayFireShading:BGSprite;
	var DoomsdayFireWall:BGSprite;
	var DoomsdayMistLight:BGSprite;
	var DoomsdayMistRoom:BGSprite;
	var DoomsdayMistShading:BGSprite;
	var DoomsdayMistSky:BGSprite;
	var DoomsdayPhase:Int = 0;
	var DoomsdayRoom:BGSprite;
	var DoomsdayStage1BackCurtain:BGSprite;
	var DoomsdayStage1BigCurtain:BGSprite;
	var DoomsdayStage1Chair:BGSprite;
	var DoomsdayStage1Curtain:BGSprite;
	var DoomsdayStage1Front:BGSprite;
	var DoomsdayStage1People:BGSprite;
	var DoomsdayStage2Back:BGSprite;
	var DoomsdayStage2BackCurtain:BGSprite;
	var DoomsdayStage2Chair:BGSprite;
	var DoomsdayStage2Debris:BGSprite;
	var DoomsdayStage2Front:BGSprite;
	var DoomsdayStage2FrontCurtain:BGSprite;
	var DoomsdayStage2Pieces:BGSprite;
	var DoomsdayStage2RedLight:BGSprite;

	//// Dehydrated
	var DehydratedBGRUN:FlxSprite;
	var DehydratedBG:BGSprite;
	var DehydratedSpongeDIE:FlxSprite;
	var DehydratedSpongeBottom:FlxSprite;

	//// Joe Mama
	var JMPopUp:FlxSprite;

	//// Propaganda
	var Ford:FlxSprite;

	//// Sanguilacrimae
	var SanguilacrimaeEventEnabled:Bool = false;
	var SanguilacrimaeOpponentNoteXTweens:Array<FlxTween> = [];
	var SanguilacrimaePlayerNoteXTweens:Array<FlxTween> = [];

	//// Satisfaction
	var SatisfactionBlueLight:BGSprite;
	var SatisfactionKitchen:BGSprite;
	var SatisfactionKrabs:BGSprite;
	var SatisfactionLight:BGSprite;
	var SatisfactionPhase1:Bool = true;
	var SatisfactionSquidward:FlxSprite;
	var SatisfactionStandoff:BGSprite;
	var SatisfactionYellowLight:BGSprite;

	//// Served
	var ServedBus:BGSprite;
	var ServedBusTween:FlxTween;
	var ServedCamTween:FlxTween;
	var ServedDarkGround:BGSprite;
	var ServedDarkSky:BGSprite;
	var ServedGround:BGSprite;
	var ServedMountains:BGSprite;
	var ServedPillarLeft:BGSprite;
	var ServedPillarRight:BGSprite;
	var ServedSky:BGSprite;

	//// Tortured
	var TorturedThunderSounds:Array<FlxSound> = [];
	var TorturedThunderSprites:Array<FlxSprite> = [];

	/// Strum Positions
	var opponentStrumXPositions:Array<Float> = [];
	var opponentStrumYPositions:Array<Float> = [];
	var playerStrumXPositions:Array<Float> = [];
	var playerStrumYPositions:Array<Float> = [];
	
	/// why
	var whyEventDisabled:Bool = false;
	var whyEventEnabled:Bool = false;
	var whyOpponentNoteXTweens:Array<FlxTween> = [];
	var whyPlayerNoteXTweens:Array<FlxTween> = [];
	var whyPlayerNoteYTweens:Array<FlxTween> = [];

	/// Zoom
	var zoomGameTween:FlxTween;
	// -- End of MCM Variables

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'bedroom';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch(curStage) {
			case 'bedroom': // Mist
				var BG:BGSprite = new BGSprite('background/v1/bedroom/room', -700, -400);
				add(BG);

				boyfriendCameraMovementPos = [850, 550];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [420, 350];

			case 'canon': // Sanguilacrimae
				var BG:FlxSprite = new FlxSprite(-340, 70);
				BG.frames = Paths.getSparrowAtlas('background/v1/canon/static_bg');
				BG.animation.addByPrefix("Background Static", "doors", 24, true);
				BG.animation.play("Background Static");
				add(BG);
				BG.scale.set(0.9, 0.9);
				BG.updateHitbox();

				boyfriendCameraMovementPos = [280, 440];
				cameraMovementFactor = 10;
				opponentCameraMovementPos = [280, 440];

			case 'dehydrated': // Dehydrated
				if(!ClientPrefs.lowQuality) {
					/// Phase 2 (Run, Sponge, Run!)
					//// Phase 2 is added before Phase 1 so we can layer and prevent some web lag ;)
					DehydratedBGRUN = new FlxSprite(-690, -200);
					DehydratedBGRUN.frames = Paths.getSparrowAtlas("background/v1/dehydrated/Dehydrated");
					DehydratedBGRUN.animation.addByPrefix("Treedome Spin", "Dehydrated idle", 60, true);
					add(DehydratedBGRUN);
					DehydratedBGRUN.scale.set(4, 4);
					DehydratedBGRUN.updateHitbox();

					DehydratedSpongeBottom = new FlxSprite(dadGroup.x - 580, dadGroup.y - 240);
					DehydratedSpongeBottom.frames = Paths.getSparrowAtlas("background/v1/dehydrated/COMEHERE/DrySpongeBottom");
					DehydratedSpongeBottom.animation.addByPrefix("SpongeBottom Idle", " idle", 60, true);
					DehydratedSpongeBottom.animation.addByPrefix("SpongeBottom Left", " left", 60, false);
					DehydratedSpongeBottom.animation.addByPrefix("SpongeBottom Down", " down", 60, false);
					DehydratedSpongeBottom.animation.addByPrefix("SpongeBottom Up", " up", 60, false);
					DehydratedSpongeBottom.animation.addByPrefix("SpongeBottom Right", " right", 60, false);
					DehydratedSpongeBottom.animation.play("SpongeBottom Idle");
					add(DehydratedSpongeBottom);

					DehydratedSpongeDIE = new FlxSprite(0, 0);
					DehydratedSpongeDIE.frames = Paths.getSparrowAtlas("background/v1/dehydrated/COMEHERE/DrySpongeDeath");
					DehydratedSpongeDIE.animation.addByPrefix("SpongeBob Death", " die", 60, false);
					add(DehydratedSpongeDIE);
					DehydratedSpongeDIE.x = (0 - DehydratedSpongeDIE.width) + 1;
					DehydratedSpongeDIE.y = (0 - DehydratedSpongeDIE.height) + 1;
				}

				/// Phase 1
				DehydratedBG = new BGSprite('background/v1/dehydrated/TreeDomeBG', -700, -400);
				add(DehydratedBG);
				DehydratedBG.scale.set(1.4, 1.4);
				DehydratedBG.updateHitbox();

				addCharacterToList("dry_chase", 1);

				boyfriendCameraMovementPos = [390, 350];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [390, 350];

			case 'DOOMSDAYbf': // Doomsday
				if(!ClientPrefs.lowQuality) {
					/*
						MAJOR NOTE:
						ALTHOUGH this prevents lag on web by layering,
						it requires a lot of RAM to be free (3GB+)! Only
						play this with low quality off if your PC can handle
						it! Otherwise, your PC may freeze!
					*/
					/// Red Mist
					DoomsdayMistSky = new BGSprite('background/v1/bedroom/redmist/sky', -700, -400);
					add(DoomsdayMistSky);

					DoomsdayMistLight = new BGSprite('background/v1/bedroom/redmist/lighteffect', -700, -400);
					add(DoomsdayMistLight);

					DoomsdayMistRoom = new BGSprite('background/v1/bedroom/redmist/room', -700, -400);
					add(DoomsdayMistRoom);

					DoomsdayMistShading = new BGSprite('background/v1/bedroom/redmist/shading', -700, -400);
					add(DoomsdayMistShading);

					/// Stage (Phase 2)
					DoomsdayStage2Back = new BGSprite('background/v1/bedroom/doomsdayfb2/DoomsdayBack', -890, -400, 1, 1, ['Tearflow'], true);
					add(DoomsdayStage2Back);

					DoomsdayStage2RedLight = new BGSprite('background/v1/bedroom/doomsdayfb2/redlight', -890, -400);
					add(DoomsdayStage2RedLight);
					DoomsdayStage2RedLight.scrollFactor.set(1, 1);

					DoomsdayStage2Front = new BGSprite('background/v1/bedroom/doomsdayfb2/stage', -890, -200);
					add(DoomsdayStage2Front);
					DoomsdayStage2Front.scrollFactor.set(1, 1);

					DoomsdayStage2BackCurtain = new BGSprite('background/v1/bedroom/doomsdayfb2/backcurtains', -890, -450);
					add(DoomsdayStage2BackCurtain);
					DoomsdayStage2BackCurtain.scrollFactor.set(1, 1);
					DoomsdayStage2BackCurtain.scale.set(1, 1.1);
					DoomsdayStage2BackCurtain.updateHitbox();

					DoomsdayStage2FrontCurtain = new BGSprite('background/v1/bedroom/doomsdayfb2/frontcurtains', -890, -450);
					add(DoomsdayStage2FrontCurtain);
					DoomsdayStage2FrontCurtain.scrollFactor.set(1, 1);
					DoomsdayStage2FrontCurtain.scale.set(1, 1.1);
					DoomsdayStage2FrontCurtain.updateHitbox();

					DoomsdayStage2Pieces = new BGSprite('background/v1/bedroom/doomsdayfb2/pieces', -890, -450);
					add(DoomsdayStage2Pieces);
					DoomsdayStage2Pieces.scrollFactor.set(1, 1);
					DoomsdayStage2Pieces.scale.set(1, 1.1);
					DoomsdayStage2Pieces.updateHitbox();

					DoomsdayStage2Chair = new BGSprite('background/v1/bedroom/doomsdayfb2/BROKENCHAIR');
					DoomsdayStage2Chair.scrollFactor.set(1, 1);
					DoomsdayStage2Chair.scale.set(1.3, 1.3);
					DoomsdayStage2Chair.updateHitbox();
					DoomsdayStage2Chair.x = 1 - DoomsdayStage2Chair.width;
					DoomsdayStage2Chair.y = 1 - DoomsdayStage2Chair.height;
					DoomsdayStage2Chair.visible = false;

					DoomsdayStage2Debris = new BGSprite('background/v1/bedroom/doomsdayfb2/debris', 0, 0, 1, 1, ['fallingdebris'], true);
					DoomsdayStage2Debris.scale.set(1.3, 1.3);
					DoomsdayStage2Debris.updateHitbox();
					DoomsdayStage2Debris.x = 1 - DoomsdayStage2Debris.width;
					DoomsdayStage2Debris.y = 1 - DoomsdayStage2Debris.height;
					DoomsdayStage2Debris.visible = false;

					/// Fire (?)
					DoomsdayFireWall = new BGSprite('background/v1/bedroom/bedroomf/wall', -700, -400);
					add(DoomsdayFireWall);

					DoomsdayFireFirewall = new BGSprite('background/v1/bedroom/bedroomf/firewall', -700, -400);
					add(DoomsdayFireFirewall);

					DoomsdayFireFloor = new BGSprite('background/v1/bedroom/bedroomf/floor', -700, -400);
					add(DoomsdayFireFloor);

					DoomsdayFireFront = new BGSprite('background/v1/bedroom/bedroomf/firefront');
					DoomsdayFireFront.x = 1 - DoomsdayFireFront.width;
					DoomsdayFireFront.y =  1 - DoomsdayFireFront.height;
					DoomsdayFireFront.visible = false;

					DoomsdayFireShading = new BGSprite('background/v1/bedroom/bedroomf/shading');
					DoomsdayFireShading.x = 1 - DoomsdayFireShading.width;
					DoomsdayFireShading.y =  1 - DoomsdayFireShading.height;
					DoomsdayFireShading.visible = false;

					/// Stage (Phase 1)
					DoomsdayStage1Front = new BGSprite('background/v1/bedroom/doomsdayfb/stagefb', -890, -200);
					add(DoomsdayStage1Front);
					DoomsdayStage1Front.scrollFactor.set(1, 1);

					DoomsdayStage1BackCurtain = new BGSprite('background/v1/bedroom/doomsdayfb/curtainstage', -890, -450);
					add(DoomsdayStage1BackCurtain);
					DoomsdayStage1BackCurtain.scrollFactor.set(1, 1);
					DoomsdayStage1BackCurtain.scale.set(1, 1.1);
					DoomsdayStage1BackCurtain.updateHitbox();

					DoomsdayStage1Curtain = new BGSprite('background/v1/bedroom/doomsdayfb/bbcurtian', -890, -450);
					add(DoomsdayStage1Curtain);
					DoomsdayStage1Curtain.scrollFactor.set(1, 1);
					DoomsdayStage1Curtain.scale.set(1, 1.1);
					DoomsdayStage1Curtain.updateHitbox();

					DoomsdayStage1BigCurtain = new BGSprite('background/v1/bedroom/doomsdayfb/curtianbig', -890, -450);
					add(DoomsdayStage1BigCurtain);
					DoomsdayStage1BigCurtain.scrollFactor.set(1, 1);
					DoomsdayStage1BigCurtain.scale.set(1, 1.1);
					DoomsdayStage1BigCurtain.updateHitbox();

					DoomsdayStage1Chair = new BGSprite('background/v1/bedroom/doomsdayfb/FUCKINGCHAIR');
					DoomsdayStage1Chair.scrollFactor.set(1, 1);
					DoomsdayStage1Chair.scale.set(1.3, 1.3);
					DoomsdayStage1Chair.updateHitbox();
					DoomsdayStage1Chair.x = 1 - DoomsdayStage1Chair.width;
					DoomsdayStage1Chair.y = 1 - DoomsdayStage1Chair.height;
					DoomsdayStage1Chair.visible = false;

					DoomsdayStage1People = new BGSprite('background/v1/bedroom/doomsdayfb/people');
					DoomsdayStage1People.x = 1 - DoomsdayStage1People.width;
					DoomsdayStage1People.y = 1 - DoomsdayStage1People.height;
					DoomsdayStage1People.scrollFactor.set(1, 1);
					DoomsdayStage1People.visible = false;
				}

				DoomsdayRoom = new BGSprite('background/v1/bedroom/room', -700, -400);
				add(DoomsdayRoom);

				DoomsdayBGBlood = new BGSprite('background/v1/bedroom/suicide', -700, -400);
				add(DoomsdayBGBlood);
				DoomsdayBGBlood.visible = false;

				DoomsdayCamBlood = new BGSprite('background/v1/bedroom/blood');
				DoomsdayCamBlood.cameras = [camHUD];
				DoomsdayCamBlood.visible = false;

				boyfriendCameraMovementPos = [820, 550];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [420, 350];

			case 'dumped': // Dumped
				var Light:BGSprite = new BGSprite('background/v1/dumped/light', -1280, -750);
				add(Light);
				Light.scrollFactor.set(1, 1);
				Light.scale.set(1, 1.1);
				Light.updateHitbox();

				var Room:BGSprite = new BGSprite('background/v1/dumped/room', -1280, -750);
				add(Room);
				Room.scrollFactor.set(1, 1);
				Room.scale.set(1, 1.1);
				Room.updateHitbox();

				boyfriendCameraMovementPos = [0, 0];
				cameraMovementFactor = 16;
				opponentCameraMovementPos = [0, 0];

			case 'island': // Plagerize
				var Sky:BGSprite = new BGSprite('background/v1/island/sky', -700, -400);
				add(Sky);
				Sky.scrollFactor.set(0.6, 0.6);
				Sky.scale.set(2, 2);
				Sky.updateHitbox();

				var Sun:BGSprite = new BGSprite('background/v1/island/sun', -700, -400);
				add(Sun);
				Sun.scrollFactor.set(0.7, 0.7);
				Sun.updateHitbox();

				var Backtrees:BGSprite = new BGSprite('background/v1/island/backtrees', -700, -250);
				add(Backtrees);
				Backtrees.scrollFactor.set(0.8, 0.8);
				Backtrees.updateHitbox();

				var Foretrees:BGSprite = new BGSprite('background/v1/island/foretrees', -700, -250);
				add(Foretrees);
				Foretrees.scrollFactor.set(0.9, 0.9);
				Foretrees.updateHitbox();

				var Ground:BGSprite = new BGSprite('background/v1/island/ground', -700, -250);
				add(Ground);

				var Water:BGSprite = new BGSprite('background/v1/island/water', -700, -250);
				add(Water);

				boyfriendCameraMovementPos = [750, 550];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [420, 550];

			case 'kitchen': // Satisfaction
				if(!ClientPrefs.lowQuality) {
					// Phase 2
					/// Just like Dehydrated, Phase 2 is added before Phase 1 so we can layer and prevent some web lag ;)
					SatisfactionStandoff = new BGSprite('background/v1/kitchen/phase2/standoff', -700, -400);
					add(SatisfactionStandoff);

					SatisfactionLight = new BGSprite('background/v1/kitchen/phase2/light', -700, -400);
					SatisfactionLight.visible = false;
				}

				/// Phase 1
				SatisfactionBlueLight = new BGSprite('background/v1/kitchen/phase1/bluelight', -700, -400);
				add(SatisfactionBlueLight);
				
				SatisfactionKitchen = new BGSprite('background/v1/kitchen/phase1/kitchen', -700, -400);
				add(SatisfactionKitchen);

				SatisfactionKrabs = new BGSprite('background/v1/kitchen/phase1/krabs', 1300, -100);
				add(SatisfactionKrabs);
				SatisfactionKrabs.scale.set(0.65, 0.65);
				SatisfactionKrabs.updateHitbox();

				SatisfactionSquidward = new FlxSprite();
				SatisfactionSquidward.frames = Paths.getSparrowAtlas("background/v1/kitchen/phase1/mc_squidfart");
				SatisfactionSquidward.animation.addByPrefix("Squidward Hey", "hey", 24, true);
				SatisfactionSquidward.animation.addByPrefix("Squidward Idle", "idle", 24, true);
				add(SatisfactionSquidward);
				SatisfactionSquidward.scale.set(1.1, 1.1);
				SatisfactionSquidward.x = 1 - SatisfactionSquidward.width;
				SatisfactionSquidward.y = 1 - SatisfactionSquidward.height;
				SatisfactionSquidward.updateHitbox();

				SatisfactionYellowLight = new BGSprite('background/v1/kitchen/phase1/yellowlight', -700, -400);

				boyfriendCameraMovementPos = [420, 450];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [850, 350];

			case 'krustycrab': // Cannibalism
				var BG:BGSprite = new BGSprite('background/v1/krustycrab/BG', -800, -300);
				add(BG);
				BG.scale.set(2, 2);
				BG.updateHitbox();

				boyfriendCameraMovementPos = [450, 350];
				cameraMovementFactor = 25;
				opponentCameraMovementPos = [320, 350];

			case 'outside': // Humiliation
				var Sky:BGSprite = new BGSprite('background/v1/outside/sky', -700, -400);
				add(Sky);
				Sky.scrollFactor.set(0.5, 0.5);
				Sky.updateHitbox();

				var Hills:BGSprite = new BGSprite('background/v1/outside/hills', -700, -400);
				add(Hills);
				Hills.scrollFactor.set(0.8, 0.8);
				Hills.updateHitbox();

				var Ground:BGSprite = new BGSprite('background/v1/outside/ground', -700, -400);
				add(Ground);

				boyfriendCameraMovementPos = [850, 350];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [420, 250];

			case 'propaganda': // Propaganda
				var Showroom:BGSprite = new BGSprite('background/v2/propaganda/propaganda', -1200, -400);
				add(Showroom);

				Ford = new FlxSprite(350, 0);
				Ford.frames = Paths.getSparrowAtlas("background/v2/propaganda/Ford1");
				Ford.animation.addByPrefix("Ford Idle", "Ford1", 24, false);
				add(Ford);

				cameraMovementFactor = 15;

			case 'served': // Served
				ServedSky = new BGSprite('background/v1/served/p1/sky', -1037, -780);
				add(ServedSky);
				ServedSky.scrollFactor.set(0.5, 0.5);

				ServedMountains = new BGSprite('background/v1/served/p1/mountains', -1237, -680);
				add(ServedMountains);
				ServedMountains.scrollFactor.set(0.8, 0.8);

				ServedGround = new BGSprite('background/v1/served/p1/ground', -1437, -780);
				add(ServedGround);
				ServedGround.scrollFactor.set(1, 1);

				ServedDarkSky = new BGSprite('background/v1/served/p2/sky', -1037, -480);
				add(ServedDarkSky);
				ServedDarkSky.scrollFactor.set(0.5, 0.5);
				ServedDarkSky.visible = false;

				ServedDarkGround = new BGSprite('background/v1/served/p2/ground', -1437, -780);
				add(ServedDarkGround);
				ServedDarkGround.scrollFactor.set(1, 1);
				ServedDarkGround.visible = false;

				ServedPillarLeft = new BGSprite('background/v1/served/platform/pillar', -1255, -85);
				add(ServedPillarLeft);
				ServedPillarLeft.scrollFactor.set(1, 1);
				ServedPillarLeft.visible = false;

				ServedPillarRight = new BGSprite('background/v1/served/platform/pillar', -45, -85);
				add(ServedPillarRight);
				ServedPillarRight.scrollFactor.set(1, 1);
				ServedPillarRight.visible = false;

				ServedBus = new BGSprite('background/v1/served/bus/bus', -4845, -885);
				add(ServedBus);
				ServedBus.scrollFactor.set(1, 1);
				ServedBus.visible = false;

				boyfriendCameraMovementPos = [105, -60];
				cameraMovementFactor = 16;
				opponentCameraMovementPos = [-12, -60];
			
			case 'surgery': // Dead Hope
				if(!ClientPrefs.lowQuality) {
					//// Phase 2 is added before Phase 1 so we can layer and prevent some web lag ;)
					/// Phase 2
					DHDeadHallway = new FlxSprite(-700, -330);
					DHDeadHallway.frames = Paths.getSparrowAtlas("background/v1/surgery/phase2/DeadHallway");
					DHDeadHallway.animation.addByPrefix("Dead Hallway", "deadhallway", 24, true);
					add(DHDeadHallway);

					/// Boyfriend (Phase 2)
					DHBFBody = new FlxSprite(250, 200);
					DHBFBody.frames = Paths.getSparrowAtlas("background/v1/surgery/phase2/BF_BODY");
					DHBFBody.animation.addByPrefix("BF Body Idle", "BF BODY idle", 24, true);
					add(DHBFBody);
				}
			
				/// Phase 1 (Dark)
				DHDarkWall = new BGSprite('background/v1/surgery/dark/wall', -650, -370);
				add(DHDarkWall);

				DHDarkLight = new BGSprite('background/v1/surgery/dark/light', -650, -330);
				add(DHDarkLight);

				/// Phase 1 (Light)
				DHWall = new BGSprite('background/v1/surgery/wall', -650, -330);
				add(DHWall);
				DHWall.visible = false;

				DHFloor = new BGSprite('background/v1/surgery/floor', -650, -330);
				add(DHFloor);
				DHFloor.visible = false;

				DHTable = new BGSprite('background/v1/surgery/table', -650, -330);
				add(DHTable);
				DHTable.visible = false;

				if(!ClientPrefs.lowQuality) {
					/// Phase 1 (Pixel)
					DHPixelWall = new BGSprite('background/v1/surgery/wall-pixel', -650, -330);
					add(DHPixelWall);
					DHPixelWall.antialiasing = true;
					DHPixelWall.scale.set(10.24, 9.723);
					DHPixelWall.updateHitbox();
					DHPixelWall.visible = false;

					DHPixelFloor = new BGSprite('background/v1/surgery/floor-pixel', -650, -330);
					add(DHPixelFloor);
					DHPixelFloor.antialiasing = true;
					DHPixelFloor.scale.set(10.24, 9.723);
					DHPixelFloor.updateHitbox();
					DHPixelFloor.visible = false;

					DHPixelTable = new BGSprite('background/v1/surgery/table-pixel', -650, -330);
					add(DHPixelTable);
					DHPixelTable.antialiasing = true;
					DHPixelTable.scale.set(10.24, 9.723);
					DHPixelTable.updateHitbox();
					DHPixelTable.visible = false;
				}

				/// Phase 1 (All)
				DHLight = new BGSprite('background/v1/surgery/light', -650, -330);
				add(DHLight);
				DHLight.visible = false;

				if(!ClientPrefs.lowQuality) {
					/// Preload characters (which on web, this will still lag, but it's a lot better)
					addCharacterToList("bf-head", 0);
					addCharacterToList("SPONGECHASE", 1);
					addCharacterToList("PATRICKCHASE", 2);
				}

				boyfriendCameraMovementPos = [850, 500];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [370, 350];

			case 'tortured': // Tortured
				var Sky:BGSprite = new BGSprite('background/v1/tortured/sky', -1250, -780);
				add(Sky);
				Sky.scrollFactor.set(1, 1);

				var Backfloor:BGSprite = new BGSprite('background/v1/tortured/backfloor', -1250, -840);
				add(Backfloor);
				Backfloor.scrollFactor.set(1, 1);
				
				var Mountains:BGSprite = new BGSprite('background/v1/tortured/mountains', -1250, -700);
				add(Mountains);
				Mountains.scrollFactor.set(1, 1);

				var Floor:BGSprite = new BGSprite('background/v1/tortured/floor', -1250, -840);
				add(Floor);
				Floor.scrollFactor.set(1, 1);

				for(i in 1...4) {
					var Thunder:FlxSprite = new FlxSprite(-1250, -840).loadGraphic(Paths.image('background/v1/tortured/thunder/thunder$i'));
					add(Thunder);
					Thunder.visible = false;

					TorturedThunderSprites.push(Thunder);
				}

				boyfriendCameraMovementPos = [55, -60];
				cameraMovementFactor = 16;
				opponentCameraMovementPos = [50, -60];

			case 'void': // Joe Mama
				var BG:BGSprite = new BGSprite('background/v1/void/background', -700, -400);
				add(BG);
				BG.scale.set(2, 2);
				BG.updateHitbox();

				JMPopUp = new FlxSprite(0, 0).loadGraphic(Paths.image('background/v1/void/POPUP'));
				add(JMPopUp);
				JMPopUp.cameras = [camOther];

				boyfriendCameraMovementPos = [850, 550];
				cameraMovementFactor = 50;
				opponentCameraMovementPos = [420, 350];
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage) {
			case "DOOMSDAYbf":
				if(!ClientPrefs.lowQuality) {
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayStage2Chair);
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayStage2Debris);
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayFireFront);
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayFireShading);
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayStage1Chair);
					insert(members.indexOf(boyfriendGroup) + 1, DoomsdayStage1People);
				}
				add(DoomsdayCamBlood);
			case "kitchen":
				if(!ClientPrefs.lowQuality)
					insert(members.indexOf(boyfriendGroup) + 1, SatisfactionLight);
				insert(members.indexOf(boyfriendGroup) + 1, SatisfactionYellowLight);
		}
		
		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		// MCM Lua On Create Events --
		switch(curStage) {
			case 'canon' | 'dehydrated':
				boyfriendGroup.visible = false;
				gfGroup.visible = false;
			case 'krustycrab':
				triggerEventNote("Goodbye Hud", "0", "0.1");
			case 'kitchen' | 'served' | 'void':
				gfGroup.visible = false;
		}

		shootWarn = new FlxSprite(0, 150).loadGraphic(Paths.image('space'));
		shootWarn.screenCenter(X);
		shootWarn.cameras = [camHUD];
		// -- End of MCM Lua On Create Events

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(0, 19, 400, "", 32);
		timeTxt.screenCenter(X);
		timeTxt.setFormat(Paths.font("Krabby Patty.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('coolhealthborder');
		healthBarBG.y = FlxG.height * 0.85;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -25;
		healthBarBG.yAdd = -25;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = FlxG.height * 0.09;

		if(curStage == "kitchen") {
			healthBar = new FlxBar(healthBarBG.x + 25, healthBarBG.y + 25, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 50), Std.int(healthBarBG.height - 50), this,
				'health', 0, 2);
			healthBar.scrollFactor.set();
			// healthBar
			healthBar.alpha = ClientPrefs.healthBarAlpha;
			add(healthBar);
			healthBarBG.sprTracker = healthBar;
		} else {
			healthBar = new FlxBar(healthBarBG.x + 25, healthBarBG.y + 25, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 50), Std.int(healthBarBG.height - 50), this,
				'health', 0, 2);
			healthBar.scrollFactor.set();
			// healthBar
			healthBar.alpha = ClientPrefs.healthBarAlpha;
			add(healthBar);
			healthBarBG.sprTracker = healthBar;
		}

		healthBarOverlay = new FlxSprite(healthBar.x, healthBar.y).loadGraphic(Paths.image("coolhealthbar", "shared"));
		healthBarOverlay.alpha = 0.5;
		healthBarOverlay.setGraphicSize(Std.int(healthBar.width), Std.int(healthBar.height));
		healthBarOverlay.updateHitbox();
		add(healthBarOverlay);

		if(curStage == "kitchen") {
			iconP1 = new HealthIcon(dad.healthIcon, true);
			iconP1.y = healthBar.y - 75;
			iconP1.visible = !ClientPrefs.hideHud;
			iconP1.alpha = ClientPrefs.healthBarAlpha;
			add(iconP1);
		
			iconP2 = new HealthIcon(boyfriend.healthIcon, false);
			iconP2.y = healthBar.y - 75;
			iconP2.visible = !ClientPrefs.hideHud;
			iconP2.alpha = ClientPrefs.healthBarAlpha;
			add(iconP2);
		} else {
			iconP1 = new HealthIcon(boyfriend.healthIcon, true);
			iconP1.y = healthBar.y - 75;
			iconP1.visible = !ClientPrefs.hideHud;
			iconP1.alpha = ClientPrefs.healthBarAlpha;
			add(iconP1);
		
			iconP2 = new HealthIcon(dad.healthIcon, false);
			iconP2.y = healthBar.y - 75;
			iconP2.visible = !ClientPrefs.hideHud;
			iconP2.alpha = ClientPrefs.healthBarAlpha;
			add(iconP2);
		}

		reloadHealthBarColors();

		scoreTxt = new FlxText(38, (ClientPrefs.downScroll ? 183 : 693) - 78, 0, "", 22);
        scoreTxt.setFormat(Paths.font("Krabby Patty.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
        scoreTxt.visible = !ClientPrefs.hideHud;
        add(scoreTxt);

		missTxt = new FlxText(38, (ClientPrefs.downScroll ? 183 : 693) - 52, 0, "", 22);
        missTxt.setFormat(Paths.font("Krabby Patty.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        missTxt.scrollFactor.set();
		missTxt.borderSize = 1.25;
        missTxt.visible = !ClientPrefs.hideHud;
        add(missTxt);

		ratingTxt = new FlxText(38, (ClientPrefs.downScroll ? 183 : 693) - 26, 0, "", 22);
        ratingTxt.setFormat(Paths.font("Krabby Patty.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        ratingTxt.scrollFactor.set();
		ratingTxt.borderSize = 1.25;
        ratingTxt.visible = !ClientPrefs.hideHud;
        add(ratingTxt);

		botplayTxt = new FlxText(38, (ClientPrefs.downScroll ? 183 : 693 - 104), FlxG.width - 800, "BOTPLAY", 22);
		botplayTxt.setFormat(Paths.font("Krabby Patty.ttf"), 22, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarOverlay.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		missTxt.cameras = [camHUD];
		ratingTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case 'propaganda':
					showCountdown = false;
					startCountdown();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			switch(daSong)
			{
				case 'propaganda':
					showCountdown = false;
					startCountdown();

				default:
					startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		super.create();

		// MCM Lua On Create Post Events --
		switch(curStage) {
			case 'canon': // Sanguilacrimae
				triggerEventNote("Camera Follow Pos", "280", "440");
			case 'kitchen': // Satisfaction
				switch(boyfriend.curCharacter) {
					case "bfmc":
						GameOverSubstate.characterName = "bfmc";
				}
				if(!ClientPrefs.middleScroll) {
					for(i in 0...playerStrums.length) {
						playerStrums.members[i].x = opponentStrumXPositions[i];
					}
					for(i in 0...opponentStrums.length) {
						opponentStrums.members[i].x = playerStrumXPositions[i];
					}
				}
			case 'propaganda': // Propaganda
				boyfriendCameraMovementPos = [Std.int(boyfriend.x - 300), Std.int(boyfriend.y)];
				opponentCameraMovementPos = [Std.int(boyfriend.x - 300), Std.int(boyfriend.y)];
				switch(boyfriend.curCharacter) {
					case "bf-spongebobcage":
						GameOverSubstate.characterName = "bf-spongebobcage";
				}
		}

		if(ClientPrefs.enableShaders) {
			switch(curSong.toLowerCase()) {
				case "doomsday" |"humiliation" | "mist": // Doomsday, Humilation, Mist
					addShaderToCamera('camGame', new VCRDistortionEffect(0, true, true, true));
					addShaderToCamera('camHUD', new VCRDistortionEffect(0, true, true, true));
			}
		}
		// -- End of MCM Lua On Create Post Events

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addShaderToCamera(cam:String,effect:ShaderEffect){
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camHUDShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camOtherShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
			default:
				if(modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam),"shader",effect.shader);
				} else if(modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam),"shader",effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance,cam);
					Reflect.setProperty(OBJ,"shader", effect.shader);
				}
		}
	}

	public function removeShaderFromCamera(cam:String,effect:ShaderEffect){
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camHUDShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camOtherShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
	}

	public function clearShaderFromCamera(cam:String){
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}
	
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				if (!startedCountdown)
				{
					remove(bg);
					startAndEnd();
				}
				else
				{
					remove(bg);
					inCutscene = false;
				}
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			if (!startedCountdown)
			{
				startAndEnd();
			}
		}
		#end
		if (!startedCountdown)
		{
			startAndEnd();
		}
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				playerStrumXPositions[i] = playerStrums.members[i].x;
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				playerStrumYPositions[i] = playerStrums.members[i].y;
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				opponentStrumXPositions[i] = opponentStrums.members[i].x;
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				opponentStrumYPositions[i] = opponentStrums.members[i].y;
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				if (showCountdown)
				{
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						case 1:
							countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							countdownReady.scrollFactor.set();
							countdownReady.updateHitbox();

							if (PlayState.isPixelStage)
								countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

							countdownReady.screenCenter();
							countdownReady.antialiasing = antialias;
							add(countdownReady);
							FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownReady);
									countdownReady.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						case 2:
							countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							countdownSet.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

							countdownSet.screenCenter();
							countdownSet.antialiasing = antialias;
							add(countdownSet);
							FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownSet);
									countdownSet.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						case 3:
							countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							countdownGo.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

							countdownGo.updateHitbox();

							countdownGo.screenCenter();
							countdownGo.antialiasing = antialias;
							add(countdownGo);
							FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownGo);
									countdownGo.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						case 4:
					}
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);

		// MCM Lua On Song Start Events --
		switch(curStage) {
			case 'void': // Joe Mama
				JMPopUp.visible = false;
		}
		// -- End of MCM Lua On Song Start Events
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			
			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public function setDefaultNoteYPositions() {
		if(whyEventEnabled) {
			var curPlayerY:Array<Float> = [];
			for(i in 0...playerStrums.length) {
				curPlayerY[i] = playerStrums.members[i].y;
				whyPlayerNoteYTweens[i].cancel();
				playerStrums.members[i].y = curPlayerY[i];
			}
		}
	}

	function goodShootEvent() {
		remove(shootWarn, true);

		shootEventActive = false;
		shootTimer.cancel();
		
		triggerEventNote("Play Animation", "shoot", "0");
		triggerEventNote("Play Animation", "dodge", "1");
		triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");
		
		if(shootSound != null)
			shootSound.stop();

		shootSound = FlxG.sound.play(Paths.sound('gunshoot'));
	}

	function playThunderSound(i:Int) {
		TorturedThunderSounds[i] = FlxG.sound.play(Paths.sound('thunder'));
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		// MCM On Update Events --
		/// Camera Movements
		if(moveCameraWithNotes && SONG.notes[Math.floor(curStep / 16)] != null) {
			if(SONG.notes[Math.floor(curStep / 16)].mustHitSection) {
				switch(curStage) {
					case "bedroom":
						defaultCamZoom = 1.1;
					case "dehydrated":
						defaultCamZoom = 0.6;
					case "DOOMSDAYbf":
						switch(DoomsdayPhase) {
							case 0 | 9:
								defaultCamZoom = 1.1;
							case 1 | 5:
								defaultCamZoom = 0.5;
							case 2 | 7:
								defaultCamZoom = 0.85;
							case 3 | 4 | 6:
								defaultCamZoom = 0.65;
							case 8:
								defaultCamZoom = 0.95;
							case 10 | 11:
								defaultCamZoom = 0.75;
						}
					case "kitchen":
						if(SatisfactionPhase1)
							defaultCamZoom = 0.7;
						else
							defaultCamZoom = 0.6;
					case "krustycrab":
						defaultCamZoom = 0.85;
					case "outside":
						defaultCamZoom = 0.75;	
				}
				switch(boyfriend.animation.curAnim.name) {
					case "singLEFT" | "singLEFT-alt":
						triggerEventNote("Camera Follow Pos", Std.string(boyfriendCameraMovementPos[0] - cameraMovementFactor), Std.string(boyfriendCameraMovementPos[1]));
					case "singDOWN" | "singDOWN-alt":
						triggerEventNote("Camera Follow Pos", Std.string(boyfriendCameraMovementPos[0]), Std.string(boyfriendCameraMovementPos[1] + cameraMovementFactor));
					case "singUP" | "singUP-alt":
						triggerEventNote("Camera Follow Pos", Std.string(boyfriendCameraMovementPos[0]), Std.string(boyfriendCameraMovementPos[1] - cameraMovementFactor));
					case "singRIGHT" | "singRIGHT-alt":
						triggerEventNote("Camera Follow Pos", Std.string(boyfriendCameraMovementPos[0] + cameraMovementFactor), Std.string(boyfriendCameraMovementPos[1]));
					default:
						triggerEventNote("Camera Follow Pos", Std.string(boyfriendCameraMovementPos[0]), Std.string(boyfriendCameraMovementPos[1]));
				}
			} else {
				switch(curStage) {
					case "bedroom" | "DOOMSDAYbf":
						defaultCamZoom = 0.85;
					case "dehydrated" | "krustycrab":
						defaultCamZoom = 0.7;
					case "kitchen":
						if(SatisfactionPhase1)
							defaultCamZoom = 0.7;
						else
							defaultCamZoom = 0.58;
					case "outside":
						defaultCamZoom = 0.75;
				}
				switch(dad.animation.curAnim.name) {
					case "singLEFT" | "singLEFT-alt":
						triggerEventNote("Camera Follow Pos", Std.string(opponentCameraMovementPos[0] - cameraMovementFactor), Std.string(opponentCameraMovementPos[1]));
					case "singDOWN" | "singDOWN-alt":
						triggerEventNote("Camera Follow Pos", Std.string(opponentCameraMovementPos[0]), Std.string(opponentCameraMovementPos[1] + cameraMovementFactor));
					case "singUP" | "singUP-alt":
						triggerEventNote("Camera Follow Pos", Std.string(opponentCameraMovementPos[0]), Std.string(opponentCameraMovementPos[1] - cameraMovementFactor));
					case "singRIGHT" | "singRIGHT-alt":
						triggerEventNote("Camera Follow Pos", Std.string(opponentCameraMovementPos[0] + cameraMovementFactor), Std.string(opponentCameraMovementPos[1]));
					default:
						triggerEventNote("Camera Follow Pos", Std.string(opponentCameraMovementPos[0]), Std.string(opponentCameraMovementPos[1]));
				}
			}
		} else {
			triggerEventNote("Camera Follow Pos", "", "");
		}

		/// "Sanguilacrimae Middlescroll" event
		if(SanguilacrimaeEventEnabled) {
			for(i in 0...(unspawnNotes.length - 1)) {
				if(!unspawnNotes[i].mustPress && unspawnNotes[i].visible) {
					unspawnNotes[i].visible = false;
				}
			}
			for(i in 0...opponentStrums.length) {
				if(SanguilacrimaeOpponentNoteXTweens[i] != null)
					SanguilacrimaeOpponentNoteXTweens[i].cancel();
				
				SanguilacrimaeOpponentNoteXTweens[i] = FlxTween.tween(opponentStrums.members[i], {x: -640}, 0.2, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						SanguilacrimaeOpponentNoteXTweens[i] = null;
						for(i in 0...4) {
							opponentStrums.members[i].visible = false;
						}
					}
				});
			}
			for(i in 0...playerStrums.length) {
				if(SanguilacrimaePlayerNoteXTweens[i] != null)
					SanguilacrimaePlayerNoteXTweens[i].cancel();
				
				if(!ClientPrefs.middleScroll) {
					SanguilacrimaePlayerNoteXTweens[i] = FlxTween.tween(playerStrums.members[i], {x: playerStrumXPositions[i] - 323}, 0.2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							SanguilacrimaePlayerNoteXTweens[i] = null;
						}
					});
				}
			}
		}

		/// "shoot" event
		if(shootEventActive && !cpuControlled) {
			if(FlxG.keys.justReleased.SPACE && shootTimer != null) {
				goodShootEvent();	
			}
		}

		/// Stage events
		switch(curStage) {
			case "dehydrated":
				if(!ClientPrefs.lowQuality) {
					//// Dehydrated "SpongeBottom"
					switch(dad.animation.curAnim.name) {
						case "singLEFT" | "singLEFT-alt":
							DehydratedSpongeBottom.animation.play("SpongeBottom Left");
						case "singDOWN" | "singDOWN-alt":
							DehydratedSpongeBottom.animation.play("SpongeBottom Down");
						case "singUP" | "singUP-alt":
							DehydratedSpongeBottom.animation.play("SpongeBottom Up");
						case "singRIGHT" | "singRIGHT-alt":
							DehydratedSpongeBottom.animation.play("SpongeBottom Right");
						default:
							DehydratedSpongeBottom.animation.play("SpongeBottom Idle");
					}
				}
		}

		/// "why" event
		if(whyEventEnabled) {
			for(i in 0...4) {
				opponentStrums.members[i].visible = false;
			}
			for(i in 0...(unspawnNotes.length - 1)) {
				if(!unspawnNotes[i].mustPress && unspawnNotes[i].visible) {
					unspawnNotes[i].visible = false;
				}
			}
			var curEventBeat:Float = (Conductor.songPosition / 1000);
			for(i in 0...opponentStrums.length) {
				var newX:Float;
				if(i % 2 == 0)
					newX = opponentStrumXPositions[i] - (-341 + Math.sin((curEventBeat + 8 * 0.1) * Math.PI));
				else
					newX = opponentStrumXPositions[i] + 341 + Math.sin((curEventBeat + 8 * 0.1) * Math.PI);

				if(!ClientPrefs.middleScroll) {
					if(whyOpponentNoteXTweens[i] != null)
						whyOpponentNoteXTweens[i].cancel();

					whyOpponentNoteXTweens[i] = FlxTween.tween(opponentStrums.members[i], {x: newX}, 0.2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							whyOpponentNoteXTweens[i] = null;
						}
					});
				}
			}
			for(i in 0...playerStrums.length) {
				var newX, newY:Float;
				if(i % 2 == 0) {
					newX = playerStrumXPositions[i] - 323 + Math.sin((curEventBeat + 8 * 0.1) * Math.PI);
					newY = playerStrumYPositions[i] - 600 * Math.sin((curEventBeat + 8 * 0.1) * Math.PI);
				} else {
					newX = playerStrumXPositions[i] -323 + Math.sin((curEventBeat + 8 * 0.1) * Math.PI);
					newY = playerStrumYPositions[i] + 300 * Math.sin((curEventBeat + 8 * 0.1) * Math.PI);
				}

				if(!ClientPrefs.middleScroll) {
					if(whyPlayerNoteXTweens[i] != null)
						whyPlayerNoteXTweens[i].cancel();

					whyPlayerNoteXTweens[i] = FlxTween.tween(playerStrums.members[i], {x: newX}, 0.2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							whyPlayerNoteXTweens[i] = null;
						}
					});
				}

				if(whyPlayerNoteYTweens[i] != null)
					whyPlayerNoteYTweens[i].cancel();

				whyPlayerNoteYTweens[i] = FlxTween.tween(playerStrums.members[i], {y: newY}, 3, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						whyPlayerNoteYTweens[i] = null;
					}
				});
			}
		} else if(whyEventDisabled) {
			for(i in 0...4) {
				opponentStrums.members[i].visible = true;
			}
			for(i in 0...(unspawnNotes.length - 1)) {
				if(!unspawnNotes[i].mustPress && !unspawnNotes[i].visible) {
					unspawnNotes[i].visible = true;
				}
			}
			for(i in 0...opponentStrums.length) {
				var newX:Float;
				newX = opponentStrumXPositions[i];

				if(!ClientPrefs.middleScroll) {
					if(whyOpponentNoteXTweens[i] != null)
						whyOpponentNoteXTweens[i].cancel();

					whyOpponentNoteXTweens[i] = FlxTween.tween(opponentStrums.members[i], {x: newX}, 0.2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							whyOpponentNoteXTweens[i] = null;
						}
					});
				}
			}
			for(i in 0...playerStrums.length) {
				var newX, newY:Float;
				newX = playerStrumXPositions[i];
				newY = playerStrumYPositions[i];

				if(!ClientPrefs.middleScroll) {
					if(whyPlayerNoteXTweens[i] != null)
						whyPlayerNoteXTweens[i].cancel();

					whyPlayerNoteXTweens[i] = FlxTween.tween(playerStrums.members[i], {x: newX}, 0.2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							whyPlayerNoteXTweens[i] = null;
						}
					});
				}

				if(whyPlayerNoteYTweens[i] != null)
					whyPlayerNoteYTweens[i].cancel();

				whyPlayerNoteYTweens[i] = FlxTween.tween(playerStrums.members[i], {y: newY}, 3, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						whyPlayerNoteYTweens[i] = null;
					}
				});
			}
		}
		// -- End of MCM On Update Events

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		scoreTxt.text = "Score: " + songScore;
		missTxt.text = "Misses: " + songMisses;
		if(ratingName == '?') {
			ratingTxt.text = "Accuracy: " + ratingName;
		} else {
			ratingTxt.text = "Accuracy: " + ratingName + " (" + Highscore.floorDecimal(ratingPercent * 100, 2) + "%) - " + ratingFC; //peeps wanted no integer rating
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				//}
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if (health > 2)
			health = 2;

		var iconOffset:Int = 26;
		if(curStage == "kitchen") {
			iconP1.x = healthBar.x + healthBar.width - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + healthBar.width - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;	
			if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;

			if (healthBar.percent > 80)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;	
		} else {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;	

			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;

			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;	
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;
				
				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				
				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);

		// Shaders
		for(i in shaderUpdates) {
			i(elapsed);
		}
	}

	function clampValue(value:Float, minValue:Float, maxValue:Float):Float {
		if (value < minValue)
			return minValue;
		else if (value > maxValue)
			return maxValue;
		else
			return value;
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			if(curStage == 'served') {
				var QuoteToPlay:Int = Std.random(4);
				FlxG.sound.play(Paths.sound('ServedQuote$QuoteToPlay'));
			}

			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", dad.healthIcon.toLowerCase());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							if(curStage == "kitchen")
								iconP1.changeIcon(dad.healthIcon);
							else
								iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							if(curStage == "kitchen")
								iconP2.changeIcon(boyfriend.healthIcon);
							else
								iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					Reflect.setProperty(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					Reflect.setProperty(this, value1, value2);
				}

			// MCM Events
			case 'Bopping HUD':
				camGame.flash(FlxColor.WHITE, 1, null, true);
				camHUD.flash(FlxColor.WHITE, 1, null, true);
				var bopFactor:Float = Std.parseFloat(value1);
				if(!Math.isNaN(bopFactor))
					boppingHUDFactor = bopFactor;
				else
					boppingHUDFactor = 0;

			case 'Drain':
				var damageAmnt:Float;
				var drainAmnt:Float = Std.parseFloat(value1);
				if(Math.isNaN(drainAmnt))
					drainAmnt = 0.02;

				damageAmnt = drainAmnt + 0.02;

				if(health > damageAmnt)
					health = health - damageAmnt;

			case 'FlipUI':
				/// Don't let Bopping HUD interfere! 
				if(boppingHUDTween != null)
					boppingHUDTween.cancel();

				if(flipHUDTween != null)
					flipHUDTween.cancel();

				flipHUDTween = FlxTween.tween(camHUD, {angle: 360}, 0.15, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						camHUD.angle = 0;
						flipHUDTween = null;
					}
				});

			case 'Goodbye Hud':
				var alphaAmnt:Float = Std.parseFloat(value1);
				if(Math.isNaN(alphaAmnt))
					alphaAmnt = 1;

				if(GoodbyeHUDTween != null)
					GoodbyeHUDTween.cancel();

				GoodbyeHUDTween = FlxTween.tween(camHUD, {alpha: alphaAmnt}, Std.parseFloat(value2), {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						GoodbyeHUDTween = null;
					}
				});

			case 'hidehud':
				var hudAlpha:Int = Std.parseInt(value1);
				if(Math.isNaN(hudAlpha))
					hudAlpha = 0;

				if(hudAlpha < 0)
					hudAlpha = 0;

				if(hudAlpha > 1)
					hudAlpha = 1;

				if(hidehudTween != null)
					hidehudTween.cancel();

				hidehudTween = FlxTween.tween(camHUD, {alpha: hudAlpha}, 1, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						hidehudTween = null;
					}
				});

			case 'Light':
				var Flash:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720);
				add(Flash);
				Flash.scrollFactor.set();
				Flash.cameras = [camHUD];

				var FlashTween:FlxTween = FlxTween.tween(Flash, {alpha: 0}, Std.parseFloat(value1), {
					ease: FlxEase.linear
				});

			case 'playVideo':
				startVideo(value1);

			case 'Sanguilacrimae Middlescroll':
				SanguilacrimaeEventEnabled = !SanguilacrimaeEventEnabled;

			case 'Set Cam Zoom':
				if(value2 != '' && value2 != null) {
					if(zoomHUDTween != null)
						zoomHUDTween.cancel();

					zoomHUDTween = FlxTween.tween(camGame, {zoom: Std.parseFloat(value1)}, Std.parseFloat(value2), {
						ease: FlxEase.sineInOut,
						onComplete: function(twn:FlxTween) {
							zoomHUDTween = null;
							defaultCamZoom = camGame.zoom;
						}
					});
				} else {
					defaultCamZoom = Std.parseFloat(value1);
				}

			case 'shoot':
				shootEventActive = true;
				remove(shootWarn, true);

				if(shootLoadSound != null)
					shootLoadSound.stop();

				shootLoadSound = FlxG.sound.play(Paths.sound('gunload'));

				insert(2, shootWarn);

				if(shootTimer != null)
					shootTimer.cancel();

				shootTimer = new FlxTimer().start(1, function(tmr:FlxTimer) {
					shootEventActive = false;
					remove(shootWarn, true);

					triggerEventNote("Play Animation", "shoot", "0");
					triggerEventNote("Play Animation", "hurt", "1");
					
					health -= 0.35;

					if(shootSound != null)
						shootSound.stop();

					shootSound = FlxG.sound.play(Paths.sound('gunshoot'));
					triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");

					shootTimer = null;
				});

			case 'why':
				whyEventDisabled = false;
				whyEventEnabled = true;

			case 'why-stop':
				whyEventDisabled = true;
				whyEventEnabled = false;

			case 'Zoom':
				var zoomAmnt:Float = Std.parseFloat(value1);
				if(Math.isNaN(zoomAmnt))
					zoomAmnt = 1;

				if(zoomGameTween != null)
					zoomGameTween.cancel();

				zoomGameTween = FlxTween.tween(camGame, {zoom: zoomAmnt}, Std.parseFloat(value2), {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						zoomGameTween = null;
					}
				});
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new MainMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				if(!note.ratingDisabled) shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				if(!note.ratingDisabled) bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				if(!note.ratingDisabled) goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				if(!note.ratingDisabled) sicks++;
		}
		note.rating = daRating;

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});

				if(ratingTxtTween != null) {
					ratingTxtTween.cancel();
				}
				ratingTxt.scale.x = 1.075;
				ratingTxt.scale.y = 1.075;
				ratingTxtTween = FlxTween.tween(ratingTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						ratingTxtTween = null;
					}
				});
			}
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		insert(members.indexOf(strumLineNotes), comboSpr);

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}
	
	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		// MCM Lua On Step Hit events --
		switch(curStage) {
			case 'dehydrated': // Dehydrated
				if(!ClientPrefs.lowQuality) {
					// Run, Sponge, Run!
					switch(curStep) {
						case 544:
							triggerEventNote("Change Character", "1", "dry_chase");
							DehydratedBG.visible = false;
							DehydratedBGRUN.animation.play("Treedome Spin");

							boyfriendCameraMovementPos = [390, 430];
							cameraMovementFactor = 0;

						case 2096:
							dadGroup.visible = false;
							DehydratedSpongeBottom.visible = false;
							DehydratedSpongeDIE.x = dadGroup.x - 580;
							DehydratedSpongeDIE.y = dadGroup.y - 240;
							DehydratedSpongeDIE.animation.play("SpongeBob Death");
					}
				}

			case 'DOOMSDAYbf': // Doomsday
				if(curStep > 2464 && curStep < 2520)
					triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");

				if(!ClientPrefs.lowQuality) {
					switch(curStep) {
						case 1055:
							DoomsdayPhase++;
							boyfriendGroup.visible = false;
							defaultCamZoom = 0.5;
							gfGroup.visible = false;

							triggerEventNote("Change Character", "1", "normality");
							cameraMovementFactor = 0;
							opponentCameraMovementPos = [350, 350];

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.5}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});

							DoomsdayRoom.visible = false;
							DoomsdayStage1Chair.x = -1390;
							DoomsdayStage1Chair.y = -500;
							DoomsdayStage1People.x = -890;
							DoomsdayStage1People.y = -300;
						case 1312:
							DoomsdayPhase++;
							boyfriendGroup.visible = true;
							defaultCamZoom = 0.85;
							gfGroup.visible = true;

							triggerEventNote("Change Character", "1", "DOOMSDAY_SQUIDWARD");
							cameraMovementFactor = 50;
							opponentCameraMovementPos = [420, 350];

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.85}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});

							DoomsdayRoom.visible = true;
							DoomsdayStage1BackCurtain.visible = false;
							DoomsdayStage1BigCurtain.visible = false;
							DoomsdayStage1Chair.visible = false;
							DoomsdayStage1Curtain.visible = false;
							DoomsdayStage1Front.visible = false;
							DoomsdayStage1People.visible = false;
						case 1568:
							DoomsdayPhase++;
							defaultCamZoom = 0.65;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.65}, 0.7, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});
						case 1572:
							DoomsdayPhase++;

							opponentCameraMovementPos = [390, 350];
							triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");
							
							DoomsdayRoom.visible = false;
							DoomsdayFireFront.x = -700;
							DoomsdayFireFront.y = -400;
							DoomsdayFireShading.x = -700;
							DoomsdayFireShading.y = -400;
						case 2336:
							DoomsdayPhase++;
							boyfriendGroup.visible = false;
							defaultCamZoom = 0.5;
							gfGroup.visible = false;
							
							triggerEventNote("Change Character", "1", "normality2");
							cameraMovementFactor = 0;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.5}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});

							DoomsdayFireFirewall.visible = false;
							DoomsdayFireFloor.visible = false;
							DoomsdayFireFront.visible = false;
							DoomsdayFireShading.visible = false;
							DoomsdayFireWall.visible = false;
							DoomsdayStage2Chair.x = -1390;
							DoomsdayStage2Chair.y = -500;
							DoomsdayStage2Debris.x = -890;
							DoomsdayStage2Debris.y = -400;
						case 2464:
							DoomsdayPhase++;
							boyfriendGroup.visible = true;
							defaultCamZoom = 0.65;
							gfGroup.visible = true;
							
							cameraMovementFactor = 50;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.65}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});

							DoomsdayStage2Back.visible = false;
							DoomsdayStage2BackCurtain.visible = false;
							DoomsdayStage2Chair.visible = false;
							DoomsdayStage2Debris.visible = false;
							DoomsdayStage2Front.visible = false;
							DoomsdayStage2FrontCurtain.visible = false;
							DoomsdayStage2Pieces.visible = false;
							DoomsdayStage2RedLight.visible = false;
						case 2592 | 2726:
							if(curStep == 2592)
								DoomsdayPhase++;
							defaultCamZoom = 0.85;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.85}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});
						case 2656 | 2732:
							if(curStep == 2656)
								DoomsdayPhase++;
							defaultCamZoom = 0.95;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.95}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});
						case 2720 | 2740:
							if(curStep == 2720)
								DoomsdayPhase++;
							defaultCamZoom = 0.75;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 0.75}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});
						case 2736:						
							defaultCamZoom = 1.1;

							if(DoomsdayCamTween != null)
								DoomsdayCamTween.cancel();

							DoomsdayCamTween = FlxTween.tween(camGame, {zoom: 1.1}, 0.2, {
								ease: FlxEase.cubeOut,
								onComplete: function(twn:FlxTween) {
									DoomsdayCamTween = null;
								}
							});
						case 2744:
							triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");
							
							remove(dadGroup, true);
							insert(members.indexOf(boyfriendGroup) + 1, dadGroup);

							DoomsdayRoom.visible = true;
							DoomsdayBGBlood.visible = true;
							DoomsdayCamBlood.visible = true;
							DoomsdayMistLight.visible = false;
							DoomsdayMistRoom.visible = false;
							DoomsdayMistShading.visible = false;
							DoomsdayMistSky.visible = false;
					}
				} else {
					switch(curStep) {
						case 2744:
							triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");
							
							remove(dadGroup, true);
							insert(members.indexOf(boyfriendGroup) + 1, dadGroup);

							DoomsdayBGBlood.visible = true;
							DoomsdayCamBlood.visible = true;
					}
				}

			case 'kitchen': // Satisfaction
				switch(curStep) {
					case 149:
						SatisfactionSquidward.animation.play("Squidward Idle");
					case 880:
						triggerEventNote("Play Animation", "talk", "0");
				}

			case 'krustycrab': // Cannibalism
				if(curStep > 55 && curStep < 63)
					triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");

			case 'served': // Served
				switch(curStep) {
					case 176:
						ServedSky.visible = false;
						ServedMountains.visible = false;
						ServedGround.visible = false;
						ServedDarkSky.visible = true;
						ServedDarkGround.visible = true;
					case 1056:
						opponentCameraMovementPos = [-102, -60];
					case 1070:
						ServedBus.visible = true;
						ServedBusTween = FlxTween.tween(ServedBus, {x: 150}, 0.5, {
							ease: FlxEase.cubeOut,
							onComplete: function(twn:FlxTween) {
								ServedBusTween = null;
							}
						});
					case 1072:
						ServedCamTween = FlxTween.tween(camGame, {zoom: 0.3}, 2, {
							ease: FlxEase.cubeOut,
							onComplete: function(twn:FlxTween) {
								ServedCamTween = null;
							}
						});
						defaultCamZoom = 0.3;
						opponentCameraMovementPos = [-12, -60];

						ServedDarkSky.visible = false;
						ServedDarkGround.visible = false;
						ServedBus.visible = false;
						ServedPillarLeft.visible = true;
						ServedPillarRight.visible = true;
				}

				if ((curStep > 1072 && curStep < 1094) || (curStep > 1099 && curStep < 1123) || (curStep > 1131 && curStep < 1154))
					triggerEventNote("Screen Shake", "0.25, 0.012", "0.1, 0.008");

			case 'surgery': // Dead Hope
				if(curStep == 464) {
					DHDarkLight.visible = false;
					DHDarkWall.visible = false;
					DHFloor.visible = true;
					DHLight.visible = true;
					DHTable.visible = true;
					DHWall.visible = true;
				}

				if(!ClientPrefs.lowQuality) {
					switch(curStep) {
						case 1232:
							DHFloor.visible = false;
							DHPixelFloor.visible = true;
							DHPixelTable.visible = true;
							DHPixelWall.visible = true;
							DHTable.visible = false;
							DHWall.visible = false;

							triggerEventNote("Change Character", "0", "bf-pixel");
							triggerEventNote("Change Character", "1", "DEAD HOPE PIXEL-SPONG");
							triggerEventNote("Change Character", "2", "DEAD HOPE PIXEL-PAT");

							boyfriendCameraMovementPos = [800, 550];
							opponentCameraMovementPos = [370, 400];

						case 1487:
							var DHFlash:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720);
							add(DHFlash);
							DHFlash.scrollFactor.set();
							DHFlash.cameras = [camHUD];

							var DHFlashTween:FlxTween = FlxTween.tween(DHFlash, {alpha: 0}, 0.3, {
								ease: FlxEase.linear
							});

							DHBFBody.animation.play("BF Body Idle");
							DHDeadHallway.animation.play("Dead Hallway");
							DHLight.visible = false;
							DHPixelFloor.visible = false;
							DHPixelTable.visible = false;
							DHPixelWall.visible = false;

							triggerEventNote("Change Character", "0", "bf-head");
							triggerEventNote("Change Character", "1", "SPONGECHASE");
							triggerEventNote("Change Character", "2", "PATRICKCHASE");

							boyfriendCameraMovementPos = [620, 350];
							cameraMovementFactor = 0;
							opponentCameraMovementPos = [620, 350];
					}
				}
			
			case 'tortured': // Tortured
				switch(curStep) {
					case 32 | 208 | 291:
						playThunderSound(0);
						TorturedThunderSprites[0].visible = true;
					case 33 | 209 | 292:
						TorturedThunderSprites[0].visible = false;
					case 37 | 135:
						playThunderSound(1);
						TorturedThunderSprites[1].visible = true;
					case 38 | 136:
						TorturedThunderSprites[1].visible = false;
					case 96 | 278 | 368:
						playThunderSound(2);
						TorturedThunderSprites[2].visible = true;
					case 97 | 279 | 369:
						TorturedThunderSprites[2].visible = false;
					case 128 | 217:
						playThunderSound(3);
						TorturedThunderSprites[0].visible = true;
					case 129 | 218:
						TorturedThunderSprites[0].visible = false;
				}
		}
		// -- End of MCM Lua On Step Hit Events
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		lastBeatHit = curBeat;

		// MCM Lua On Beat Hit Events
		if(curBeat % 2 == 0) {
			/// Bopping HUD
			camGame.angle = boppingHUDFactor * -12;
			if(boppingGameTween != null)
				boppingGameTween.cancel();

			boppingGameTween = FlxTween.tween(camGame, {angle: 0}, 0.5, {
				ease: FlxEase.backOut,
				onComplete: function(twn:FlxTween) {
					boppingGameTween = null;
				}
			});

			//// Don't interfere with FlipUI!
			if(flipHUDTween == null) {
				if(boppingHUDTween != null)
					boppingHUDTween.cancel();

				camHUD.angle = boppingHUDFactor * -12;
				boppingHUDTween = FlxTween.tween(camHUD, {angle: 0}, 0.5, {
					ease: FlxEase.backOut,
					onComplete: function(twn:FlxTween) {
						boppingHUDTween = null;
					}
				});
			}

			/// Icon Bops
			if(iconP1BopTween != null)
				iconP1BopTween.cancel();

			iconP1.angle = -20;
			iconP1BopTween = FlxTween.tween(iconP1, {angle: 0}, 0.2, {
				onComplete: function(twn:FlxTween) {
					iconP1BopTween = null;
				}
			});
			
			if(iconP2BopTween != null)
				iconP2BopTween.cancel();

			iconP2.angle = -20;
			iconP2BopTween = FlxTween.tween(iconP2, {angle: 0}, 0.2, {
				onComplete: function(twn:FlxTween) {
					iconP2BopTween = null;
				}
			});

			/// Stage Events
			switch(curStage) {
				case "propaganda":
					Ford.animation.play("Ford Idle", true);
			}
		} else {
			/// Bopping HUD
			camGame.angle = boppingHUDFactor * 12;
			if(boppingGameTween != null)
				boppingGameTween.cancel();

			boppingGameTween = FlxTween.tween(camGame, {angle: 0}, 0.5, {
				ease: FlxEase.backOut,
				onComplete: function(twn:FlxTween) {
					boppingGameTween = null;
				}
			});

			//// Don't interfere with FlipUI!
			if(flipHUDTween == null) {
				if(boppingHUDTween != null)
					boppingHUDTween.cancel();

				camHUD.angle = boppingHUDFactor * 12;
				boppingHUDTween = FlxTween.tween(camHUD, {angle: 0}, 0.5, {
					ease: FlxEase.backOut,
					onComplete: function(twn:FlxTween) {
						boppingHUDTween = null;
					}
				});
			}

			/// Icon Bops
			if(iconP1BopTween != null)
				iconP1BopTween.cancel();

			iconP1.angle = 20;
			iconP1BopTween = FlxTween.tween(iconP1, {angle: 0}, 0.2, {
				onComplete: function(twn:FlxTween) {
					iconP1BopTween = null;
				}
			});

			if(iconP2BopTween != null)
				iconP2BopTween.cancel();

			iconP2.angle = 20;
			iconP2BopTween = FlxTween.tween(iconP2, {angle: 0}, 0.2, {
				onComplete: function(twn:FlxTween) {
					iconP2BopTween = null;
				}
			});
		}

		if(shootEventActive && cpuControlled) {
			if(shootCpuCounter < 2) {
				shootCpuCounter += 1;
			} else if(shootCpuCounter == 2) {
				goodShootEvent();
				shootCpuCounter = 0;
			}
		}

		switch(curStage) {
			case "kitchen": // Satisfaction
				switch(curBeat) {
					case 32:
						SatisfactionSquidward.x = 700;
						SatisfactionSquidward.y = -380;
						SatisfactionSquidward.animation.play("Squidward Hey");
					case 260:
						if(!ClientPrefs.lowQuality) {
							boyfriendCameraMovementPos = [600, 350];
							cameraMovementFactor = 10;
							opponentCameraMovementPos = [600, 350];
							boyfriendGroup.visible = false;
							SatisfactionBlueLight.visible = false;
							SatisfactionKitchen.visible = false;
							SatisfactionKrabs.visible = false;
							SatisfactionLight.visible = true;
							SatisfactionSquidward.visible = false;
							SatisfactionYellowLight.visible = false;
						}
				}
		}
		// -- End of MCM Lua On Beat Hit Events

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
