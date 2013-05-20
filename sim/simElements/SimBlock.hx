/**
 * ...
 * @author Moach
 * 
 * a block is a non-static and yet non-moving piece of collision mesh... is something to fill the gap between SimObjects and the global
 * 	quadtree collision manifold... 
 * 
 * blocks, as objects, have their own quadtree and transform space, and may or not interfere with physics...
 *	these are also set out to run callbacks, just like objects do, upon contact events with other objects
 *   
 * 
 * 
 * behold! -- since shapes are defined in objects apart, this leaves open the possibility of collision data INSTANCING! 
 * 
 * 
 */

package sim.simElements;
import flash.Vector;
import sim.simData.RotMatrix;
import sim.simData.Vec2D;
import sim.simElements.props.SolidShape;

class SimBlock 
{
	
	
	public var pos:Vec2D;
	public var rot:RotMatrix; // rotaion tranform matrix
	
	
	public var solidShapes:Vector<SolidShape>; // defined solid shapes....
	
	
	
	
	public function new() 
	{
		//
		//
		
	}
	
}