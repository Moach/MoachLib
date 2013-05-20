/**
 * ...
 * @author Moach
 */

package sim.simElements.props;

import sim.simData.Quad;
import sim.simData.Vec2D;
import sim.simElements.SimObject;


class ImplicitShape 
{

		
	public var sqRadius:Float;       // squared base-radius of this specific shape
	
	
	// collision vars - will be multiplied with opposing body for final effect
	
	/// note that these appear here again! - this enables multi-shaped objects to define different surface sections
	/// that react differently to collisions and whatnot
	///
	
	//
	public var surfBounce:Float;     // collision restitution multiplier
	public var surfSlip:Float;       // surface friction
	public var surfStickSq:Float;    // min squared relative velocity for full surface stop (go idle)
	public var surfBudgeSq:Float;    // min squared relative velocity for moving out of a full stop
	
	
	public var obj(null, default):SimObject; // the object to which this shape belongs
	//
	
	
	public var lPos:Vec2D; // local position of shape in objects space - also, the origin for the shapes quadtree
	//
	//  do mind - shapes have no rotation of their own - instead, they are slaved to that of the parenting object
	// for objects with rotating parts, use rigs instead... that's what they're there for
	
	//
	
	/**
	 * 
	 * 
	 * what are implicit shapes...
	 * 
	 *   while quadtree based solids can be used to represent most objects, they can be impractical in certain situations
	 *  whereas a function would work more efficiently... this is the case for semi-circles, ovals and even simpple boxes
	 *  which are more effectively represented as an implicit field functionn than as a points-and-lines surface
	 * 
	 *   an implicit shape is accessed just like a solid shape, once a potential contact is found, its shape-defining function is called
	 *  with a pair of vectors containing the sampled position, this function must return a separation vector (in case of collision) or null, (if the
	 *  sample point doesn't make contact with the shape) - it also receives a "normal" vector that should be set to the collision-plane normal, so
	 *  proper reaction calculations can be performed
	 * 
	 * 
	 */
	
	//
	//

	
	public function new(_obj:SimObject, _fnx:Vec2D->Vec2D->Bool) 
	{
		obj     = _obj;
		shapeFX = _fnx;
	} 
	
	
	
	
	
	public var shapeFX:Vec2D->Vec2D->Bool;
	
	//
	//
	

	
}