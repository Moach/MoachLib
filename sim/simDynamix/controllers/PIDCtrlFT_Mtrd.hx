/**
 * ...
 * @author Moach
 */

package sim.simDynamix.controllers;
import sim.simData.Vec2D;

using gen.UtMath;


///    yeah, really... - the only difference between the regular PIDCtrl class and this "FT" version is that this one uses an optimized preset time component,
///     rather than having a delta-time parameter fed to each function....  obviously enough, this one is able to run faster


/**    this is the monitored variant of the PIDCtrlFT class -- variables here are monitored for gauging purposes - for critical performance, use the regular unmonitored one
 *     but make sure you know what you're dooing - 'cuz then you won't know if you fuck something up....
 *     
 *     the monitoring overhead isn't really all that big a deal - so this should be the standard, unless you're up to something quite a bit gnarly....
 * 
 */


class PIDCtrlFT_Mtrd
{
	
	public var Kp:Float;
	public var Ki:Float;
	public var Kd:Float;
	
	public var Cp:Float;
	public var Ci:Float; 
	public var Cd:Float;
	
	public var sp:Float;
	
	public var spLerpD:Float;
	public var spRampQ:Float;
	//
	public var intgMax:Float;
	public var intgMin:Float;
	
	public var lErr:Float;
	public var intg:Float;
	
	public static var _defT:Float = 1.0; // remember to set this to the inverse delta-time -- that's standard practice for everything in this library, anyways....
	
	public var dT:Float;
	public var rT:Float;
	
	//
	//
	
	public function new(?_Kp:Float = 0.50, ?_Ki:Float = 0.45, ?_Kd:Float = 0.60) 
	{
		Kp = _Kp;   sp  = 0.0;  Cp = 0.0;
		Ki = _Ki;  lErr = 0.0;  Ci = 0.0;
		Kd = _Kd;  intg = 0.0;  Cd = 0.0;
		spLerpD = spRampQ = intgMax = 1.0;
		intgMin = 0.0;
		
		dT = _defT;
		rT = 1 / _defT;
		
	}
	
	// 
	//
	
	private inline function loopMtrPass(e:Float, dvr:Float, feed:Float) : Float
	{
		Cp = Kp * e;   Ci = Ki * intg;    Cd = Kd * dvr;
		var out:Float = Cp + Ci + Cd;
		var mtrRng:Float = (e != 0.0)? 1/e.abs() : 0.0;
		//
		Cp *= mtrRng;
		Cd *= mtrRng;
		Ci *= mtrRng;
		
		return out;
	}
	
	//
	private inline function intgClipCheck() : Void
	{
		
		
	}
	
	private inline function lerpSpMaxCheck(spTgt:Float) : Void
	{
		
		
	}
	
	
	
	public inline function basicLoop(feed:Float) : Float
	{
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		return loopMtrPass(e, dvr, feed);
		
	}
	
	
	
	//
	public inline function lerpSetpointLoop(feed:Float, spTgt:Float) : Float
	{
		var delta:Float = (spTgt - sp)*spRampQ*dT;
		sp += (delta.abs() < spLerpD)? delta : spLerpD*delta.sign();
		
		return basicLoop(feed);
		
	}
	
	
	
	public inline function intgClipLoop(feed:Float) : Float
	{
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		intg = (intg.abs() < intgMin)? 0.0 : ((intg > intgMax)? intgMax : ((intg < -intgMax)? -intgMax : intg));
		
		return loopMtrPass(e, dvr, feed);
		
	}
	
	
	public inline function fullFtrLoop(feed:Float, spTgt:Float) : Float
	{
		var delta:Float = (spTgt - sp)*spRampQ*dT;
		sp += (delta.abs() < spLerpD)? delta : spLerpD*delta.sign();
		
		
		var e:Float = sp - feed;
		intg += e * dT; 
		var dvr:Float = (e - lErr) * rT;
		lErr = e;
		
		intg = (intg.abs() < intgMin)? 0.0 : ((intg > intgMax)? intgMax : ((intg < -intgMax)? -intgMax : intg));
		
		return loopMtrPass(e, dvr, feed);
		
	}
	
	
	
	public inline function flush(?_sp:Float = 0.0) : Void
	{ 
		//
		intg = 0.0;
		lErr = 0.0;
		sp = _sp;
		
	}
	
	
	
	
}

