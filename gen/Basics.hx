/**
 * ...
 * @author Moach
 */

package gen;
import flash.Memory;

class Basics 
{

	
	
	public static function vec2W(x:Float, y:Float)
	{
		
		Memory.setFloat(1024, x);
		Memory.setFloat(1024+4, y);
	}
	
	
	
}