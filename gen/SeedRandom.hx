/**
 * ...
 * @author Moach
 */

package gen;

class SeedRandom 
{

	
	//
	// only satic stuff
	
	
	/**
	 * generates a seeded random Float - BETWEEN -1 and 1 - unlike Math.random(), this method 
	 * generates the same results every time the same seed is entered
	 * @param	seed - the seed Float 
	 */
	public static function randomNegToPos(?seed:Int=1) :Float {
		//
		// - i don´t understand how ANY of that works, but if it does, i´m happy ;)
		seed = (seed<<13) ^ seed;
		return ( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 0x7fffffff) * 9.31322574615478515625e-10);    
	}
	
	/**
	 * generates a seeded random Float - BETWEEN 0 and 1 - unlike Math.random(), this method 
	 * generates the same results every time the same seed is entered
	 * @param	seed - the seed Float 
	 */
	public static function randomFloat(?seed:Int=1) :Float{
		//
		// - i don´t understand how ANY of that works, but if it does, i´m happy ;)
		seed = (seed<<13) ^ seed;
		return (( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 0x7fffffff) * 9.31322574615478515625e-10)* .5;    
	}
	
	/**
	 * generates a seeded random integer - BETWEEN 0 and multiplier (default 10) - unlike Math.random(), this method 
	 * generates the same results every time the same seed is entered
	 * @param	seed - the seed Float 
	 * @param   mult - the multiplier Float - result will be from 0 to this Float (default is 10)
	 */
	public static function randomInt(?seed:Int = 1, ?mult:Int = 100) : Int {
		//
		// - i don´t understand how ANY of that works, but if it does, i´m happy ;)
		seed = (seed<<13) ^ seed;
		return Math.floor( ((((seed * (seed * seed * 15731 + 789221) + 1376312589) & 0x7fffffff) * 9.31322574615478515625e-10) * .5 )*mult );    
	}
		
		
		

}