package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;

import flixel.util.FlxColor;

class Player extends FlxSprite 
{
	public static var PixelPerMetre = 8;
	private var cappedPower:Float = 0;
	private var power:Float = 0;
	private var lastPressedA:Bool = false;	
	private var startPos:Float;
	private var lastFrame:Int;
	
	public var enableInput = true;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
		health = 100;
		startPos = X;
		
		loadGraphic("assets/images/player.png", true, 14, 15);		
		animation.add("ready", [0]);
		animation.add("run", [1, 2, 3, 4, 5, 6, 5, 4, 3, 2], 12, true);
		animation.add("down", [7]);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		//Slowly decrease power
		power *= 0.988;
		power = power < 0.09 ? 0 : power;
		
		//Slowly increase health
		health += elapsed * 15;
		health = health > 100 ? 100 : health;
		
		color = FlxColor.fromHSB(0, 0, 0.5 + ((health / 100) * 0.5));
		
		if (enableInput)
		{
			ProcessInput();
		
			//Cap power and use that to effect the rate of decrease in health
			cappedPower = power > 100 ? 100 : power;
			health -= (cappedPower / 100) * (elapsed * 20);
		
			//if health is < 0 then player dies.
			if (health < 0)
			{
				health = 0;
				kill();
			}
		
			velocity.x = ((power / 100) * (health / 100) * (45000 / PixelPerMetre)) * 0.1;
		}
		
		if (animation.curAnim != null)
		{
			if ((animation.curAnim.curFrame == 2 &&	lastFrame != 2) || 
				(animation.curAnim.curFrame == 8 &&	lastFrame != 8))
			{
				FlxG.sound.play("step");
			}
		
			lastFrame = animation.curAnim.curFrame;
		}
	}
	
	override public function kill():Void 
	{
		alive = false;
		
		if (health == 0)
		{
			animation.play("down");
		}
	}
	
	function ProcessInput()
	{
		var boolAButton:Bool = FlxG.keys.anyJustPressed([A, LEFT]) || 
		FlxG.gamepads.anyJustPressed(FlxGamepadInputID.A);
		var boolBButton:Bool = FlxG.keys.anyJustPressed([D, RIGHT]) || 
		FlxG.gamepads.anyJustPressed(FlxGamepadInputID.B);
		
		//Increase power when button is pressed
		if ((lastPressedA && boolBButton) || (!lastPressedA && boolAButton))
		{
			power += 10.0;
			lastPressedA = !lastPressedA;
		}
	}
	
	public function GetPower()
	{
		return power;
	}
	
	public function GetCappedPower()
	{
		return cappedPower;
	}
	
	public function GetRunningDistance()
	{
		return (x - startPos) / PixelPerMetre / 6;
	}
}