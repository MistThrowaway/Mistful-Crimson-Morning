package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var bg:FlxSprite;
	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('mcm/warning'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(1280,720);
		bg.updateHitbox();
		add(bg);

		warnText = new FlxText(380, 545, 0, "Psst... If you have issues with songs, try\ndisabling effects for certain songs in the options!");
		warnText.setFormat(Paths.font("Krabby Patty.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.borderSize = 2;
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(bg, {alpha: 0}, 1);
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
			}
		}
		super.update(elapsed);
	}
}