/**
 * ...
 * @author Moach
 */

package sim.simData;

import flash.Memory;
import haxe.macro.Expr;
import haxe.macro.Context;
import sim.simData.SimDefs;



class Vec2D
{

		public var x:Float;
		public var y:Float;
		
	
		
		//
		public function new(?_x:Float = 0.0, ?_y:Float = 0.0)
		{
			x = _x; y = _y;
		}
		
		
		
		
		/// if created with "load", remember to dump() when done
		
		//
		/**
		 * returns a new vector from the pool 
		 * @param	?x optional x, default 0
		 * @param	?y optional y, default 0
		 * @return the new vector - handle with care, pickup after yourself when done with "dump"
		 */
		public inline static function load(?x:Float = 0.0, ?y:Float = 0.0) : Vec2D
		{
			var getVec:Vec2D = SimDataPools.vectorPool.load();
				getVec.x = x;
				getVec.y = y;
			//
			return getVec;
		}
		
		/**
		 * returns a new vector from the pool - copying x/y from another
		 * @param  v1 - vector to copy stuff from
		 * @return the new vector - handle with care, pickup after yourself when done with "dump"
		 */
		public inline static function loadCpy(v1:Vec2D) : Vec2D
		{
			var getVec:Vec2D = SimDataPools.vectorPool.load();
				getVec.x = v1.x;
				getVec.y = v1.y;
			//
			return getVec;
		}
		
		
		
		public inline static function loadPtr(addr:Int) : Vec2D
		{
			var getVec:Vec2D = SimDataPools.vectorPool.load();
				getVec.x = Memory.getFloat(addr);
				getVec.y = Memory.getFloat(addr+4);
			//
			return getVec;
		}
		
		public inline static function loadPtrD(addr:Int) : Vec2D
		{
			var getVec:Vec2D = SimDataPools.vectorPool.load();
				getVec.x = Memory.getDouble(addr);
				getVec.y = Memory.getDouble(addr+8);
			//
			return getVec;
		}
		
		
		
		/**
		 * returns a utility scratch vector for quick loading of one-off vectors... NOT FOR USE WITH FUNCTIONS OTHER THAN IN THIS CLASS
		 *  use only once at a time - only a single scratch vector is available and it's delivered as a reference - new calls will overwrite it's value
		 *  regardless of whether you're done using it - so... do not call scratch untill it's safe to overwrite!
		 * 
		 *   you've been warned
		 * 
		 * @param	_x
		 * @param	_y
		 * @return
		 */
		public static inline function scratch(_x:Float, _y:Float) : Vec2D
		{
			scratchVec.x = _x;
			scratchVec.y = _y;
			return scratchVec;
		}
		//
		
		// do not dump! -- not a part of the pool
		 public static var scratchVec:Vec2D = Type.createEmptyInstance(Vec2D); 
		private static var serviceVec:Vec2D = Type.createEmptyInstance(Vec2D); 
		
		
		
		
		
		public inline function set(_x:Float, _y:Float) : Vec2D
		{
			x = _x; y = _y;
			
			return this;
		}
		
		
		public inline function zero() : Vec2D
		{
			x = y = 0;
			return this;
		}
		
		
		/**
		 * recycles this instance to the pool... 
		 */
		public inline function dump() : Vec2D
		{
			//x = y = 0;
			SimDataPools.vectorPool.unload(this);
			return null;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		public inline function add( v:Vec2D ) : Vec2D
		{
			x += v.x;
			y += v.y;
			
			return this;
		}
		
		public inline function addXY( _x:Float, _y:Float ) : Vec2D
		{
			x += _x;
			y += _y;
			
			return this;
		}
		
		
		public inline function add2( v1:Vec2D, v2:Vec2D ) : Vec2D
		{
			x = v1.x + v2.x;
			y = v1.y + v2.y;
			
			return this;
		}
		
		
		public inline static function _add( vOut:Vec2D, v1:Vec2D, v2:Vec2D ) : Vec2D		
		{
			vOut.x = v1.x + v2.x;
			vOut.y = v1.y + v2.y;
			
			return vOut;
		}
		
		
		
		
		
		
		
		public inline function sub( v:Vec2D ) : Vec2D
		{
			x -= v.x;
			y -= v.y;
			
			return this;
		}
		
		
		public inline function sub2( v1:Vec2D, v2:Vec2D ) : Vec2D
		{
			x = v1.x - v2.x;
			y = v1.y - v2.y;
			
			return this;
		}
		
		public inline function subXY( _x:Float, _y:Float ) : Vec2D
		{
			x -= _x;
			y -= _y;
			
			return this;
		}
		
		
		public inline static function _sub( vOut:Vec2D, v1:Vec2D, v2:Vec2D ) : Vec2D
		{
			vOut.x = v1.x - v2.x;
			vOut.y = v1.y - v2.y;
			
			return vOut;
		}

		
		
		
		
		
		
		
		public inline function mult( scalar:Float ) : Vec2D
		{
			x *= scalar;
			y *= scalar;
			
			return this;
		}
		
		
		public inline function mult2( v1:Vec2D, scalar:Float ) : Vec2D
		{
			x = v1.x * scalar;
			y = v1.y * scalar;
			
			return this;
		}
		
		
		public inline static function _mult( vOut:Vec2D, v1:Vec2D, scalar:Float ) : Vec2D		
		{
			vOut.x = v1.x * scalar;
			vOut.y = v1.y * scalar;
			
			return vOut;
		}
		
		
		
		
		
		
		
		
		public inline function div( scalar:Float ) : Vec2D
		{
			x /= scalar;
			y /= scalar;
			
			return this;
		}
		
		
		public inline function div2( v1:Vec2D, scalar:Float ) : Vec2D
		{
			x = v1.x / scalar;
			y = v1.y / scalar;
			
			return this;
		}
		
		
		
		public inline function _div( vOut:Vec2D, v1:Vec2D, scalar:Float ) : Vec2D
		{
			vOut.x = v1.x / scalar;
			vOut.y = v1.y / scalar;
			
			return vOut;
		}
		
		
		
		
		
		
		public inline function vMult( v1:Vec2D ) : Vec2D
		{
			x *= v1.x;
			y *= v1.y;
			
			return this;
		}
		
		public inline function vMult2( v1:Vec2D, v2:Vec2D ) : Vec2D
		{
			x = v1.x * v2.x;
			y = v1.y * v2.y;
			
			return this;
		}
		
		public inline function vMultXY( _x:Float, _y:Float ) : Vec2D
		{
			x *= _x;
			y *= _y;
			
			return this;
		}
		
		public inline static function _vMult( vOut:Vec2D, v1:Vec2D, v2:Vec2D ) : Vec2D		
		{
			vOut.x = v1.x * v2.x;
			vOut.y = v1.x * v2.y;
			
			return vOut;
		}
		
		
		
		
		
		
		public inline function vDiv( v1:Vec2D ) : Vec2D
		{
			x /= v1.x;
			y /= v1.y;
			
			return this;
		}
		
		public inline function vDiv2( v1:Vec2D, v2:Vec2D ) : Vec2D
		{
			x = v1.x / v2.x;
			y = v1.y / v2.y;
			
			return this;
		}
		
		public inline function vDivXY( _x:Float, _y:Float ) : Vec2D
		{
			x /= _x;
			y /= _y;
			
			return this;
		}
		
		public inline function _vDiv( vOut:Vec2D, v1:Vec2D, v2:Vec2D) : Vec2D
		{
			vOut.x = v1.x / v2.x;
			vOut.y = v1.y / v2.y;
			
			return vOut;
		}
		
		
		
		
		
		
		public inline function abs() : Vec2D
		{
			x = (x < 0)? -x : x;
			y = (y < 0)? -y : y;
			
			return this;
		}
		
		
		public inline function abs2(v1:Vec2D) : Vec2D
		{
			x = (v1.x < 0)? -v1.x : v1.x;
			y = (v1.y < 0)? -v1.y : v1.y;
			
			return this;
		}
		
		
		public inline static function _abs(vOut:Vec2D, v1:Vec2D) : Vec2D		
		{
			vOut.x = (v1.x < 0)? -v1.x : v1.x;
			vOut.y = (v1.y < 0)? -v1.y : v1.y;
			
			return vOut;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		public inline function clamp(cl:Vec2D) : Vec2D
		{
			x = (x < cl.x)? x : cl.x;
			y = (y < cl.y)? y : cl.y;
			return this;
		}
		
		public inline function clampXY(cx:Float, cy:Float) : Vec2D
		{
			x = (x < cx)? x : cx;
			y = (y < cy)? y : cy;
			return this;
		}
		
		public inline function clamp2(v1:Vec2D,  cl:Vec2D) : Vec2D
		{
			x = (v1.x < cl.x)? v1.x : cl.x;
			y = (v1.y < cl.y)? v1.y : cl.y;
			return this;
		}
		
		public inline static function _clamp(vOut:Vec2D, v1:Vec2D,  cl:Vec2D) : Vec2D
		{
			vOut.x = (v1.x < cl.x)? v1.x : cl.x;
			vOut.y = (v1.y < cl.y)? v1.y : cl.y;
			return vOut;
		}
		
		
		
		
		
		
		/**
		 * Gets the magnitude of the instance
		 * 
		 * @return magnitude of the Vector
		 * */
		public inline function getMagnitude() : Float
		{
			var d:Float = (x * x) + (y * y);
			return 1 / invSqrt( (d<0)? -d : d );
		}
		
		
		public inline function getInvMag() : Float
		{
			var d:Float = (x * x) + (y * y);
			return invSqrt( (d<0)? -d : d );
		}
		
		
		
		/**
		 * Gets the squared length of the vector (faster)
		 * @return magnitude^2
		 */
		public inline function getMagSQ() : Float
		{
			var d:Float = (x * x) + (y * y);
			return ((d<0)? -d : d);
		}
		
		
		
		
		
		
		
		public inline function norm() : Vec2D
		{
			mult(getInvMag());
			return this;
		}
		
		public inline function norm2( v1:Vec2D ) : Vec2D
		{
			cloneFrom(v1);
			mult(getInvMag());
			return this;
		}
		
		
	//	public static var lastFnMag:Float;
		
	
		public inline function normGetMag() : Float
		{
			var m = getInvMag();
			mult(m);
			return 1.0 / m;
		}
		
		public inline function norm2GetMag(_v1:Vec2D) : Float
		{
			var m = _v1.getInvMag();
			mult2(_v1, m);
			return 1.0 / m;
		}
		
		
		
		/**
		 * Gets the dot product of the Vector and instance
		 * 
		 * @param v Vector to evaluate dot product with
		 * @return the dot product of v and the instance
		 * */
		public inline function dot( v:Vec2D ) : Float
		{
			return x * v.x + y * v.y;
		}
		public inline static function _dot( v1:Vec2D, v2:Vec2D ) : Float
		{
			return v1.x * v2.x + v1.y * v2.y;
		}
		
		/**
		 * Gets the cross product of the Vector and instance
		 * 
		 * @param v Vector to evaluate cross product with
		 * @return cross product of v and instance
		 * */
		public inline function cross( v:Vec2D ) : Float
		{
			return x * v.y - y * v.x;
		}
		
		
		public inline static function _cross( v1:Vec2D, v2:Vec2D) : Float
		{
			return v1.x * v2.y - v1.y * v2.x;
		}
		
		
		
		
		
		public inline function perp() : Vec2D
		{
			var _x = x;
			x = -y;
			y = _x;
			return this;
		}
		
		public inline function perp2( v1:Vec2D ) : Vec2D
		{
			x = -v1.y;
			y =  v1.x;
			return this;
		}
		public inline static function _perp(vOut:Vec2D, v1:Vec2D) : Vec2D
		{
			vOut.x = -v1.y;
			vOut.y =  v1.x;
			return vOut;
		}
		
		
		/**
		 * makes a Vector identical to the instance
		 * */
		public inline function cloneTo(vOut:Vec2D) : Vec2D
		{
			//var scV:Vec2D = SimDataPools.vectorPool.load();
			vOut.x = x;
			vOut.y = y;
			
			return vOut;
			//return scV;
		}
		
		
		/**
		 * opposite of cloneTo - makes this instance identical to a vector
		 */
		public inline function cloneFrom(v1:Vec2D) : Vec2D
		{
			//var scV:Vec2D = SimDataPools.vectorPool.load();
			  x = v1.x;
			  y = v1.y;
			  
			  return this;
			//return scV;
		}
		/**
		 * same as above, but with fewer keystrokes
		 */
		public inline function cpy(v1:Vec2D) : Vec2D
		{
			 x = v1.x;
			 y = v1.y; 
			 return this;
		}
		
		
		
		public inline function negate() : Vec2D
		{
			x = -x;
			y = -y;
			
			return this;
		}
		public inline function negate2(v1:Vec2D) : Vec2D
		{
			x = -v1.x;
			y = -v1.y;
			
			return this;
		}
		public inline static function _negate(vOut:Vec2D, v1:Vec2D) : Vec2D
		{
			vOut.x = -v1.x;
			vOut.y = -v1.y;
			
			return vOut;
		}
		
		
		
		
		
		
		
		public inline function crossScalar(scalar:Float ) : Vec2D
		{
			var tx:Float = x;
			
			x = -scalar * y;
			y =  scalar * x;	
			
			return this;
		}

		public inline function crossScalar2( v1:Vec2D, scalar:Float ) : Vec2D
		{
			x = -scalar * v1.y;
			y =  scalar * v1.x;
			
			return this;
		}
		public inline static function _crossScalar( vOut:Vec2D, v1:Vec2D, scalar:Float ) : Vec2D
		{
			vOut.x = -scalar * v1.y;
			vOut.y =  scalar * v1.x;
			
			return vOut;
		}
		
		
		
		
		
		
		
		
		public inline function getDir() : Float
		{
			return Math.atan2( y, x );
		}
		
		
		public inline function getDeltaDir( v:Vec2D ) : Float
		{
			return Math.atan2( v.y - y, v.x - x );
		}
		
		public inline static function _getDeltaDir( v1:Vec2D, v2:Vec2D ) : Float
		{
			return Math.atan2( v1.y - v2.y, v1.x - v2.x );
		}
		
		
		public inline function getDistance( v:Vec2D ) : Float
		{
			var dX:Float = x - v.x;
			var dY:Float = y - v.y;
			
			return 1 / invSqrt(dX * dX + dY * dY);
		}
		public inline function getDistSQ( v:Vec2D ) : Float
		{
			var dX:Float = x - v.x;
			var dY:Float = y - v.y;
			return (dX * dX + dY * dY);
		}
		
		public inline static function _getDistance( v1:Vec2D, v2:Vec2D ) : Float
		{
			var dX:Float = v1.x - v2.x;
			var dY:Float = v1.y - v2.y;
			
			return 1 / invSqrt(dX * dX + dY * dY);
		}
		
		public inline static function _getDistSQ( v1:Vec2D, v2:Vec2D ) : Float
		{
			var dX:Float = v1.x - v2.x;
			var dY:Float = v1.y - v2.y;
			return (dX * dX + dY * dY);
		}
		
		public inline function getInvDist( v:Vec2D ) : Float
		{
			var dX:Float = x - v.x;
			var dY:Float = y - v.y;
			return invSqrt(dX * dX + dY * dY);
		}
		
		public inline static function _getInvDist( v1:Vec2D, v2:Vec2D ) : Float
		{
			var dX:Float = v1.x - v2.x;
			var dY:Float = v1.y - v2.y;
			
			return invSqrt(dX * dX + dY * dY);
		}
		
		
		
		
		
		
		public inline function rotate( mtx:RotMatrix ) : Vec2D
		{
			mtx.rotateVector(this);
			return this;
		}
		public inline function rotate2( v1:Vec2D, mtx:RotMatrix ) : Vec2D
		{
			cloneFrom(v1);
			mtx.rotateVector(this);
			return this;
		}
		public inline static function _rotate( vOut:Vec2D, v1:Vec2D, mtx:RotMatrix ) : Vec2D
		{
			v1.cloneTo(vOut);
			mtx.rotateVector(vOut);
			
			return vOut;
		}
		
		
		
		public inline function rotateTranspose( mtx:RotMatrix ) : Vec2D
		{
			mtx.rotateTransposeVector(this);
			return this;
		}
		
		public inline function rotateTranspose2( v1:Vec2D, mtx:RotMatrix ) : Vec2D
		{
			cloneFrom(v1);
			mtx.rotateTransposeVector(this);
			
			return this;
		}
		
		public inline static function _rotateTranspose( vOut:Vec2D, v1:Vec2D, mtx:RotMatrix ) : Vec2D
		{
			v1.cloneTo(vOut);
			mtx.rotateTransposeVector(vOut);
			
			return vOut;
		}
		
		
		
		
		
		public inline function resize( mag:Float ) : Vec2D
		{
			norm();
			x *= mag;
			y *= mag;
			
			return this;
		}
		
		public inline function resize2( v1:Vec2D, mag:Float ) : Vec2D
		{
			cloneFrom(v1);
			norm();
			x *= mag;
			y *= mag;
			
			return this;
		}
		
		public inline static function _resize( vOut:Vec2D, v1:Vec2D, mag:Float ) : Vec2D
		{
			v1.cloneTo(vOut);
			vOut.norm();
			vOut.x *= mag;
			vOut.y *= mag;
			
			return vOut;
		}
		
		
		
		
		
		public inline function stretch( deltaMag:Float ) : Vec2D
		{
			var iMag:Float = getInvMag();
			
			x += (x * iMag) * deltaMag;
			y += (y * iMag) * deltaMag;
			
			return this;
		}
		
		public inline function stretch2( v1:Vec2D, deltaMag:Float ) : Vec2D
		{
			cloneFrom(v1);
			norm();
			x = v1.x + (x * deltaMag);
			y = v1.y + (y * deltaMag);
			
			return this;
		}
		
		public inline static function _stretch( vOut:Vec2D, v1:Vec2D, deltaMag:Float ) : Vec2D
		{
			v1.cloneTo(vOut);
			vOut.norm();
			vOut.x = v1.x + (vOut.x * deltaMag);
			vOut.y = v1.y + (vOut.y * deltaMag);
			
			return vOut;
		}
		
		
		
		//
		//
		
		
		public inline static function _project( vOut:Vec2D, theta:Float, mag:Float ) : Vec2D
		{
			vOut.x = Math.cos( theta ) * mag;
			vOut.y = Math.sin( theta ) * mag;
			
			return vOut;
		}
		
		
		
		
		public inline static function _lerp(vOut:Vec2D, v1:Vec2D, d:Float, v2:Vec2D) : Vec2D		
		{
			vOut.x = v1.x + ((v1.x - v2.x) * d);
			vOut.y = v1.y + ((v1.y - v2.y) * d);
			
			
			//
			return vOut;
		}
		
		
		
		
		
		//
		//
		
		
		/** these are meant to reorient a vector into "as seen" from another (which MUST be normalized)
			this is a shortcut to using a rotation matrix in order to convert a vector into the oriented space described by another
		*/
		public inline function alignIn(ref:Vec2D) : Vec2D	
		{
			var x0:Float = x; // in this case we must hold the "old" X value, so when we go for Y its not all messed up
			x = (x  * ref.y) - (y * ref.x);
			y = (x0 * ref.x) + (y * ref.y);
			return this;
		}		
		public inline function alignIn2(v1:Vec2D, ref:Vec2D) : Vec2D	
		{
			x = (v1.x * ref.y) - (v1.y * ref.x);
			y = (v1.x * ref.x) + (v1.y * ref.y);
			return this;
		}
		public static inline function _alignIn(vOut:Vec2D, v1:Vec2D, ref:Vec2D) : Vec2D	 
		{
			vOut.x = (v1.x * ref.y) - (v1.y * ref.x);
			vOut.y = (v1.x * ref.x) + (v1.y * ref.y);
			return vOut;
		}
		
		
		
		
		public inline function alignOut(ref:Vec2D) : Vec2D	
		{
			var x0:Float = x; // same....
			x = (x * ref.y) + (y  * ref.x);
			y = (y * ref.y) - (x0 * ref.x);
			return this;
		}
		public inline function alignOut2(v1:Vec2D, ref:Vec2D) : Vec2D	
		{
			x = (v1.x * ref.y) + (v1.y * ref.x);
			y = (v1.y * ref.y) - (v1.x * ref.x);
			return this;
		}
		public static inline function _alignOut(vOut:Vec2D, v1:Vec2D, ref:Vec2D) : Vec2D	
		{
			vOut.x = (v1.x * ref.y) + (v1.y * ref.x);
			vOut.y = (v1.y * ref.y) - (v1.x * ref.x);
			return vOut;
		}
		
		
		
		//
		//
		
		
		//
		//
				
		public static inline function invSqrt( x : Float ) : Float 
		{
			//
			var h:Float = x * .5;
			
			Memory.setFloat( SimDefs.FISR_BUFFER_32, x );
			Memory.setI32( SimDefs.FISR_BUFFER_32, 0x5f3759df - ( Memory.getI32(SimDefs.FISR_BUFFER_32) >> 1 )); // ?!! magic!
			//
			x = Memory.getFloat(SimDefs.FISR_BUFFER_32);
			//
			return  (x * ( 1.5 - h * x * x )); // whoa, gnarly...
		}
		
		
		
		
		
		
		public inline function commit( addr:Int )
		{
			Memory.setFloat(addr,     x);
			Memory.setFloat(addr + 4, y);
		}
		public inline function recall( addr:Int ) : Vec2D
		{
			x = Memory.getFloat(addr);
			y = Memory.getFloat(addr + 4);
			
			return this;
		}
		
		
		public static inline function _commit( addr:Int, v1:Vec2D )
		{
			Memory.setFloat(addr,     v1.x);
			Memory.setFloat(addr + 4, v1.y);
		}
		public static inline function _recall( addr:Int, vOut:Vec2D ) : Vec2D
		{
			vOut.x = Memory.getFloat(addr);
			vOut.y = Memory.getFloat(addr + 4);
			return vOut;
		}
		
		
		
		
		public inline function commitD( addr:Int )
		{
			Memory.setDouble(addr,     x);
			Memory.setDouble(addr + 8, y);
		}
		public inline function recallD( addr:Int ) : Vec2D
		{
			x = Memory.getDouble(addr);
			y = Memory.getDouble(addr + 8);
			return this;
		}
		
		
		public static inline function _commitD( addr:Int, v1:Vec2D )
		{
			Memory.setDouble(addr,     v1.x);
			Memory.setDouble(addr + 8, v1.y);
		}
		public static inline function _recallD( addr:Int, vOut:Vec2D ) : Vec2D
		{
			vOut.x = Memory.getDouble(addr);
			vOut.y = Memory.getDouble(addr + 8);
			return vOut;
		}
	
}

class _V
{
	/*
	public static inline function def(x:Expr, y:Expr)
	{
		
	}
	
	
	
	static function def(x:Expr, y:Expr)
	{
		//
		
		
	}
	*/
	
	
	/**
	 * 
	 * 
	 scratch vectors for your convenience!
	 do not dump these!, they're not in the pool
	 
	 also, i'd advise these are not to be used outside of the engine - most engine functions use them and they get oft-overwritten without warning
	 
	 so for out-of-core things, get your own damn scratch vectors!
	*/
	//
	public static var v1:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v2:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v3:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v4:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v5:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v6:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v7:Vec2D = Type.createEmptyInstance(Vec2D); 
	public static var v8:Vec2D = Type.createEmptyInstance(Vec2D); 
	
	 
}
//
//

