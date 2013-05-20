/**
 * ...
 * @author Moach
 * 
 *    Utility Math class! 
 * 
 *      best implemented via "using" mixin logic
 */

package gen;
import flash.Memory;

class UtMath 
{
	
	private static inline var FISR_BUFFER_32:Int = 0;
	
	public static inline function sqrt(x:Float):Float 
	{
		Memory.setFloat(FISR_BUFFER_32, x);
		Memory.setI32(FISR_BUFFER_32, 0x1fbb4000 + (Memory.getI32(FISR_BUFFER_32) >> 1));
		var x2 = Memory.getFloat(FISR_BUFFER_32);
		return 0.5 * (x2 + x / x2);
	}
	
	public static inline function invSqrt(x:Float):Float 
	{
		Memory.setFloat(FISR_BUFFER_32, x);
		Memory.setI32(FISR_BUFFER_32, 0x5f3759df - (Memory.getI32(FISR_BUFFER_32) >> 1));
		var x2 = Memory.getFloat(FISR_BUFFER_32);
		return x2 * (1.5 - 0.5 * x * x2 * x2);
	}	
	
	
	
	
	
	
	/**
	 * NOTE - since these are meant to be used with mixing syntax, it makes more sense to read min and max as "limits", rather than the usual highest/lowest
	 *  semantic employed by the "Math" variants of such functions.... this is contrary behavior to the default, but lexically it makes more sense to be this way,
	 *  since the first parameter will be ommmited (will actually be the calling object) from the syntax, giving it an alternative sense of the logic implied therein
	 * 
	 *  you have been warned!
	 * 
	 */
	public static inline function max(a:Float, b:Float) : Float
	{
		return (a < b)? a : b;
	}
	public static inline function min(a:Float, b:Float) : Float
	{
		return (a > b)? a : b;
	}
	public static inline function clamp(v:Float, low:Float, hi:Float) : Float
	{
		return (v < low)? low : (v > hi)? hi : v;
	}
	
	
	
	
	public static inline function lowst(a:Float, b:Float) : Float
	{
		return (a < b)? a : b;
	}
	public static inline function higst(a:Float, b:Float) : Float
	{
		return (a > b)? a : b;
	}
	
	
	public static inline function abs(value: Float): Float 
	{
			return (value < 0.0)?  -value : value;
	}
	
	
	public static inline function toDeg(a:Float) : Float 
	{
		return a * 57.29577951308232;
	}
	public static inline function toRad(a:Float) : Float 
	{
		return a * 0.017453292519943295;
	}
	
	
	public static inline function sign( value: Float): Float 
	{
			return (value < 0.0)? -1.0 : 1.0;
	}
	
	
	public static inline function sqr(a:Float) : Float
	{
		return a * abs(a);
	}
	
	
	
	
	
	
	
	public static inline function sin(x:Float) : Float
	{
		if (x < -3.14159265)
			x += 6.28318531;
		else
		if (x >  3.14159265)
			x -= 6.28318531;

		//compute sine
		if (x < 0)
		{
			x = 1.27323954 * x + .405284735 * x * x;
			if (x < 0)
				x = .225 * (x *-x - x) + x;
			else
				x = .225 * (x * x - x) + x;
		}
		else
		{
			x = 1.27323954 * x - 0.405284735 * x * x;
			if (x < 0)
				x = .225 * (x *-x - x) + x;
			else
				x = .225 * (x * x - x) + x;
		}
		return x;
	}
	public static inline function cos(x:Float) : Float
	{
		return sin(x + 1.57079632);
	}
	
	
/*	public static inline function atan2(y:Float, x:Float):Float {
		var sgn:Float = sign(y);
		var absYandR:Float = y * sgn + 2.220446049250313e-16;
		var partSignX:Float = (Std.int(x < 0.0) << 1); // [0.0/2.0]
		var signX:Float = 1.0 - partSignX; // [1.0/-1.0]
		absYandR = (x - signX * absYandR) / (signX * x + absYandR);
		return ((partSignX + 1.0) * 0.7853981634 + (0.1821 * absYandR * absYandR - 0.9675) * absYandR) * sgn;
	}
*/	
	
	
}