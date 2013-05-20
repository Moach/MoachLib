/**
 * ...
 * @author Moach
 */

package sim.simElements.props;

import sim.simData.Quad;
import sim.simData.Vec2D;
import sim.simElements.SimObject;

class SolidShape 
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
	 * how shapes work! -- 
	 * 
	 * 	unlike most engines out there - here we use a novel way to represent non-spherical solids - any time
	 *   object shapes are defined as small quadtrees with a manifold of their own - this manifold is what shapes the object's surface
	 * 	
	 *  collision check is done by scanning the contact pair by transposing occupied quad positions in ob1 over to ob2 quad-space
	 * 	 this is done recursively, refining the search in positive ob1 quads that also have a positive quad in ob2 at the transposed position
	 */
	
	//
	//
	
	public var quadMain:Quad; // the first quad is defined by a struct - the engine will grind down from the pointer in it without creating
	//                           new structs as it runs... this is (theoretically) faster and saves up oodles of memory
	
	
	public function new(_obj:SimObject) 
	{
		obj = _obj;
	} 
	
	
	//
	//
	

	
	
}
