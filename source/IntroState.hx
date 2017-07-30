package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
/**
 * ...
 * @author Gamepopper
 */
class IntroState extends FlxState 
{
	var player:Player;
	var followObject:FlxObject;
	
	var start:FlxSprite;
	
	var logo:FlxSprite;
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.mouse.useSystemCursor = true;
		
		logo = new FlxSprite(-50, -120, "assets/images/logo.png");
		
		start = new FlxSprite(0, 68);
		start.loadGraphic("assets/images/crowd.png", true, 72, 14);
		start.animation.add("cheer", [0, 1, 2, 3], 10);
		start.animation.play("cheer");
		
		player = new Player(20, 70);
		followObject = new FlxObject(20, -100, player.width, player.height);
		
		var bg1:FlxBackdrop = new FlxBackdrop("assets/images/bg1.png", 1, 1, true, false);
		var bg2:FlxBackdrop = new FlxBackdrop("assets/images/bg2.png", 0.5, 1, true, false);
		
		camera.follow(followObject, FlxCameraFollowStyle.PLATFORMER);
		camera.fade(FlxColor.BLACK, 1, true, Move);
		
		add(logo);
		add(bg2);
		add(bg1);
		add(start);
		add(player);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
	function Move()
	{
		FlxTween.tween(followObject, {y: 55}, 2, { ease: FlxEase.quadInOut, onComplete: GoToPlay});
	}
	
	function GoToPlay(tween:FlxTween)
	{
		FlxG.switchState(new PlayState());
	}
}