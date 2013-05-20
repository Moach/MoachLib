/**
 * ...
 * @author Moach
 */

package sim.simDynamix.controllers;
import sim.simData.Vec2D;

using gen.UtMath;


///    yeah, really... - the only difference between the regular PIDCtrl class and this "FT" version is that this one uses an optimized preset time component,
///     rather than having a delta-time parameter fed to each function....  obviously enough, this one is able to run faster


class PIDCtrlFT
{
	
	public var Kp:Float;
	public var Ki:Float;
	public var Kd:Float;
	

	public var sp:Float;
	
	public var spLerpD:Float;
	public var intgMax:Float;
	
	private var lErr:Float;
	private var intg:Float;
	
	public static var _defT:Float = 1.0; // remember to set this to the inverse delta-time -- that's standard practice for this library
	
	public var dT:Float;
	public var rT:Float;
	
	//
	//
	
	public function new(?_Kp:Float = 0.50, ?_Ki:Float = 0.45, ?_Kd:Float = 0.60) 
	{
		Kp = _Kp;   sp  = 0.0;
		Ki = _Ki;  lErr = 0.0;
		Kd = _Kd;  intg = 0.0;
		spLerpD = intgMax = 1.0;
		
		dT = _defT;
		rT = 1 / _defT;
		
	}
	

	
	public inline function basicLoop(feed:Float) : Float
	{
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		return (Kp * e) + (Ki * intg) + (Kd * dvr);
		
	}
	
	
	
	//
	public inline function lerpSetpointLoop(feed:Float, spTgt:Float) : Float
	{
		var delta:Float = (spTgt - sp)*dT;
		sp += (delta.abs() < spLerpD)? delta : spLerpD*delta.sign();
		
		return basicLoop(feed);
		
	}
	
	
	public inline function intgClipLoop(feed:Float) : Float
	{
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		intg = (intg > intgMax)? intgMax : (intg < -intgMax)? -intgMax : intg;
		
		return  (Kp * e) + (Ki * intg) + (Kd * dvr);
		
	}
	
	
	public inline function fullFtrLoop(feed:Float, spTgt:Float) : Float
	{
		var delta:Float = (spTgt - sp)*dT;
		sp += (delta.abs() < spLerpD)? delta : spLerpD*delta.sign();
		
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		intg = (intg > intgMax)? intgMax : (intg < -intgMax)? -intgMax : intg;
		
		return  (Kp * e) + (Ki * intg) + (Kd * dvr);
		
	}
	
	
	
	
}

