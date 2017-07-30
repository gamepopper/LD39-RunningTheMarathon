package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PlayState extends FlxState
{
	var player:Player;
	var sweat:FlxSprite;
	var followObject:FlxObject;
	
	var start:FlxSprite;
	var finish:FlxSprite;
	
	var bird:FlxSprite;
	
	var text:FlxText;
	var timeText:FlxText;
	
	var time:Float = 0;
	var stopTime:Float = 0;
	var state:Int = 0;
	var miles:Bool = true;
	
	var clouds:FlxGroup;
	
	var fireworks:FlxEmitter;
	
	public static var MarathonDistance:Float = 42195.39;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.useSystemCursor = true;
		
		bird = new FlxSprite(FlxG.random.int(165, 500), FlxG.random.int(0, 20));
		bird.loadGraphic("assets/images/bird.png", true, 10, 8);
		bird.animation.add("flap", [0, 1, 2, 3, 4], 10);
		bird.animation.play("flap");
		bird.scrollFactor.set(0, 0);
		bird.velocity.x = -6;
		
		clouds = new FlxGroup();
		for (i in 0...4)
		{
			var cloud = new FlxSprite(160 + FlxG.random.int(0, 160), FlxG.random.int(0, 30));
			cloud.loadGraphic("assets/images/cloud.png", true, 14, 14);
			cloud.animation.randomFrame();
			cloud.velocity.x = -FlxG.random.int(1, 20);
			cloud.scrollFactor.set(0, 0);
			clouds.add(cloud);
		}
		
		start = new FlxSprite(0, 68);
		start.loadGraphic("assets/images/crowd.png", true, 72, 14);
		start.animation.add("cheer", [0, 1, 2, 3], 10);
		start.animation.play("cheer");
		
		finish = new FlxSprite(MarathonDistance * Player.PixelPerMetre * 6, 68);
		finish.loadGraphic("assets/images/crowd.png", true, 72, 14);
		finish.animation.add("cheer", [0, 1, 2, 3], 10);
		finish.animation.play("cheer");
		
		player = new Player(20, 70);
		followObject = new FlxObject(20, player.height * 2, player.width, player.height);
		
		sweat = new FlxSprite(20, 65);
		sweat.loadGraphic("assets/images/sweat.png", true, 15, 7);
		sweat.animation.add("sweat", [0, 1, 2, 3], 18);
		sweat.animation.play("sweat");
		sweat.visible = false;
		
		text = new FlxText(2, 88, 160);
		text.setFormat("assets/data/cp437-8x8.ttf", 8, FlxColor.WHITE, LEFT);
		text.antialiasing = false;
		text.scrollFactor.set(0, 0);
		
		timeText = new FlxText(2, 108, 160);
		timeText.setFormat("assets/data/cp437-8x8.ttf", 8, FlxColor.WHITE, LEFT);
		timeText.antialiasing = false;
		timeText.scrollFactor.set(0, 0);
		timeText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		
		var bg1:FlxBackdrop = new FlxBackdrop("assets/images/bg1.png", 1, 1, true, false);
		var bg2:FlxBackdrop = new FlxBackdrop("assets/images/bg2.png", 0.5, 1, true, false);
		
		camera.follow(followObject, FlxCameraFollowStyle.PLATFORMER);
		
		fireworks = new FlxEmitter();
		fireworks.makeParticles(1, 1, FlxColor.WHITE, 80);
		fireworks.launchMode = FlxEmitterMode.CIRCLE;
		fireworks.speed.set(100, 300);
		fireworks.acceleration.set(0, 800, 0, 1000);
		fireworks.launchAngle.set( -135, -45);
		fireworks.color.set(FlxColor.RED, FlxColor.YELLOW);
		
		FlxG.sound.play("crowd", 1, true);
		
		add(bird);
		add(clouds);
		add(bg2);
		add(bg1);
		add(start);
		add(finish);
		add(player);
		add(sweat);
		add(fireworks);
		add(text);
		add(timeText);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		followObject.x = player.x;
		
		sweat.x = player.x;
		sweat.visible = player.health <= 80;
		
		clouds.forEachOfType(FlxSprite, foreachCloud);
		
		if (bird.x < -bird.width)
		{
			bird.x += bird.width + FlxG.random.int(165, 500);
			bird.y = FlxG.random.int(0, 20);
		}
		
		if (FlxG.keys.justPressed.T)
		{
			miles = !miles;
		}
		
		if (state == 0) //Start
		{
			if (player.velocity.x > 0)
			{
				state = 1;
				player.animation.play("run");
				
				var timer:FlxTimer = new FlxTimer();
				timer.start(FlxG.random.float(30, 90), PlanePassover);
				
				for (i in 0...FlxG.sound.list.length)
				{
					FlxG.sound.list.members[i].looped = false;
				}
			}
		}
		else if (state == 1) //Run
		{
			time += elapsed;
			
			if (player.velocity.x == 0)
			{
				stopTime += elapsed;
				
				if (stopTime > 5)
				{
					state = 4;
				}
			}
			
			if (player.health == 0)
			{
				state = 3;
			}
			
			if (player.GetRunningDistance() > MarathonDistance)
			{
				FlxG.sound.play("crowd");
				camera.flash();
				state = 2;
				
				LaunchRandomFirework(new FlxTimer());
				
				player.animation.play("ready");
			}
			
			if (state > 1)
			{
				FlxTween.tween(timeText, {y:2}, 1.0, {ease: FlxEase.quadOut} );
			}
			
			var speed = fixedFloat((player.velocity.x * (Player.PixelPerMetre / 1000) * 10));
			player.animation.curAnim.frameRate = Std.int((speed / 22.5) * 20);
			
			text.text = 
				"Speed: " + speed + "km/h";
				
			if (miles)
				text.text += "\nDist: " + fixedFloat(player.GetRunningDistance() / 1609.34) + " miles";
			else
				text.text += "\nDist: " + fixedFloat(player.GetRunningDistance()) + "m";
		
			var intTime:Int = Std.int(time);
			var seconds:Int = intTime % 60;
			var minutes:Int = Std.int(intTime / 60) % 60;
			var hours:Int = Std.int(intTime / 3600) % 24;
		
			timeText .text = "Time: " + 
			IntToString(hours) + ":" + 
			IntToString(minutes) + ":" +
			IntToString(seconds) + "." + 
			Std.int(fixedFloat(time - Std.int(time), 3) * 1000);
		}
		else //Finish
		{
			player.enableInput = false;
			player.velocity.x *= 0.90;
			
			text.text = "";
			
			if (state != 2)
			{
				if (state == 4)
					text.text = "You gave up. Fair play.";
				else if (state == 3)
					text.text = "You ran out of power.";
			}
			
			if (miles)
				text.text += "\nDist: " + fixedFloat(MarathonDistance / 1609.34) + " miles";
			else
				text.text += "\nDist: " + fixedFloat(MarathonDistance) + "m";
				
			if (FlxG.keys.justPressed.R)
			{
				FlxG.resetGame();
			}
		}
	}
	
	function IntToString(x:Int):String
	{
		if (x < 10)
		{
			return "0" + x;
		}
		else
		{
			return "" + x;
		}
	}
	
	function foreachCloud(cloud:FlxSprite)
	{
		if (cloud.x < -cloud.width)
		{
			cloud.setPosition(FlxG.random.int(160, 200), FlxG.random.int(0, 30));
			cloud.animation.randomFrame();
			cloud.velocity.x = -FlxG.random.int(1, 20);
		}
	}
	
	function PlanePassover(timer:FlxTimer)
	{
		FlxG.sound.play("plane");
		timer.start(FlxG.random.float(30, 120), PlanePassover);
	}
	
	function LaunchRandomFirework(timer:FlxTimer)
	{
		FlxG.sound.play("explosion");
		fireworks.setPosition(FlxG.random.int(-40, 40) + player.x, FlxG.random.int(30, 90));
		fireworks.start(true, 0.1, 20);
		timer.start(FlxG.random.float(0.5, 2), LaunchRandomFirework);
	}
	
	public static function fixedFloat(v:Float, ?precision:Int = 2):Float
	{
		return Math.round( v * Math.pow(10, precision) ) / Math.pow(10, precision);
	}
}
