/**
 * ...
 * @author Moach
 */

package sim.simData;

import sim.simData.SimDefs;


class RotMatrix 
{
	
	public var _ang:Float;
	//
	public var _cos:Float;
	public var _sin:Float;
	public var _isn:Float;

	
	
	public inline function setAngle( value:Float ) : Float
	{
		
		_ang = value;
		//
		
		
		//
		//
		
		_cos = Math.cos( _ang );   
		_sin = Math.sin( _ang );
		_isn= -_sin;            
		
		//
		//
		
		
		return _ang;
	}
	
	
	
	public inline function getAngle() : Float
	{
		return _ang;
	}
	
	
	
	
	public inline function cloneFrom(rtx:RotMatrix) : RotMatrix
	{
		_cos = rtx._cos; 
		_sin = rtx._sin;
		_isn = rtx._isn;
		
		_ang = rtx._ang;
		
		return this;
	}
	
	
	
	public inline function setRCP( rX:Float, rY:Float, ?a:Float = 0.0 ) : RotMatrix
	{
		_cos =  rX;
		_sin =  rY;
		_isn = -rY;
		
		_ang = a;
		
		return this;
	}
	
	
	
	
	public inline function rotateVector( v:Vec2D ) : Vec2D
	{
		var xR:Float = _cos * v.x + _isn * v.y;
		var yR:Float = _sin * v.x + _cos * v.y;
		v.x = xR; v.y = yR;
		return v;
	}
	
	public inline function rotateTransposeVector( v:Vec2D ) : Vec2D
	{
		var xR:Float = _cos * v.x + _sin * v.y;
		var yR:Float = _isn * v.x + _cos * v.y;
		v.x = xR; v.y = yR;
		return v;
	}
	
	public inline function rotateVector2( vOut:Vec2D, v:Vec2D ) : Vec2D
	{
		vOut.x = _cos * v.x + _isn * v.y;
		vOut.y = _sin * v.x + _cos * v.y;
		return vOut;
	}
	
	public inline function rotateTransposeVector2( vOut:Vec2D, v:Vec2D ) : Vec2D
	{
		vOut.x = _cos * v.x + _sin * v.y;
		vOut.y = _isn * v.x + _cos * v.y;
		return vOut;
	}
	
	
	public static inline function load(?a:Float = 0.0 ) : RotMatrix
	{
		var getRM:RotMatrix = SimDataPools.matrixPool.load();
			getRM.setAngle(a);
		
		return getRM;
		
	}
	
	
	public static inline function loadRCP(rX:Float, rY:Float, ?a:Float = 0.0) : RotMatrix
	{
		var getRM:RotMatrix = SimDataPools.matrixPool.load();
			//getRM.setAngle(a);
			
			getRM._cos =  rX;
			getRM._sin =  rY;
			getRM._isn = -rY;
			//
			getRM._ang = a; 
			
		return getRM;
		
	}
	


	
	public inline function dump()
	{
		_ang = _cos = _sin = _isn = 0.0; // dump values
		 
		
	}
	
}
