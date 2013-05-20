/**
 * ...
 * @author Moach
 */

package sim.simData;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;
import gen.Pool;
import sim.simElements.props.SolidShape;
import sim.simElements.SimObject;
import sim.Simulation;
import sim.simData.Quad;

class SimDefs
{
	//
	// import me!
	
	
	//
	public static var defSim:Simulation; // a poor-man's-singleton rig to allow switching between Simulation instances
	
	
	
	public static var simHeapCache:ByteArray; // byte-array "heap" so we can put those alchemy op-codes to good use
	//
	public static inline var SIM_VM_CACHE:UInt = 1048576; // 1 MB! enough?
	
	
	public static inline var FISR_BUFFER_32:Int = 0;
	//
	
	
	public static inline var STEP_ADDRS_BASE:Int = 4;
	public static inline var STEP_FIELDS_MAX:Int = 8;
	public static inline var STEP_FLDBYTES:Int = 4;
	//
	
	
	
	
	public static inline var _DEG:Float =  57.29577951308232;
	public static inline var _RAD:Float =  0.017453292519943295;
	
	
	
	//
	//
}



class SimDataPools 
{
	// stuff here gets pooled! it's much more efficient than using "new" all the time and leaving stuff up for the garbage collector...
	// plus, it's eco-friendly! - makes cap'n planet proud!... well, not really - but it's better than not ;)
	//
	
	public static inline var VECTOR_POOL_SIZE:UInt  = 1024;
	public static inline var MATRIX_POOL_SIZE:UInt  = 128;
	
	public static inline var QUAD_POOL_SIZE:UInt    = 1024;
	
	public static inline var OBJECT_POOL_SIZE:UInt  = 64;
	
	public static inline var CONTACT_POOL_SIZE:UInt = 64;
	
	public static inline var NODE_POOL_SIZE:UInt    = 1024;
	
	//
	//
	//
	
	// to be initialized upon sim spoolup
	//
	public static var vectorPool:Pool<Vec2D>;
	public static var matrixPool:Pool<RotMatrix>;
	
	public static var quadPool:Pool<Quad>;
	public static var cntcPool:Pool<Contact>;
	
	public static var objPool:Pool<SimObject>;
	
	public static var nodePool:Pool<SimNode<Dynamic>>;
	
}





class CollisionInfo 
{

	public static var impactVel:Float;   // total impact velocity
	//
	
	public static var friction:Float;    // combined surface friction
	public static var restitution:Float; // combined surface bounce
	
	public static var tangentRVel:Float; // tangential relative velocity (along contact plane)
	public static var tangent:Vec2D;     // tangent normal
	
	public static var tangentXFrm:RotMatrix; // rotation from global to contact-plane coords
	
	//
	public static var contact:Contact; // more contact info....
	
	
	public static var contactPos:Vec2D; // contact position in world space
	//
	
	public static var contactRPos1:Vec2D; // contact position relative to object 1
	public static var contactRPos2:Vec2D; // contact position relative to object 2
	//
	
	public static var uData1:Dynamic; // userdata for object 1
	public static var uData2:Dynamic; // userdata for object 2
	
	public static var linDV1:Vec2D; // linear relative velocity for object 1
	public static var linDV2:Vec2D; // linear relative velocity for object 2
	// 
	public static var rotDV1:Float; // angular relative velocity for object 1
	public static var rotDV2:Float; // angular relative velocity for object 2
	
	
	public static var velocityAtContact1:Vec2D; // global velocity of object 1 upon collision
	public static var velocityAtContact2:Vec2D; // global velocity of object 2 upon collision
	
	public static var relativeVelocity:Vec2D; // total impact velocity at contact point
		
		
	
}
 


enum CollisionOps
{
	CO_DEFAULT;   // handle collision as needed (default)
	CO_FORCE;     // force contact to collision state and set it up for resolve at current state
	CO_BYPASS;    // ignore collision at this time (leave to next pass)
	CO_OVERRIDE;  // override colision resolution - go for manual mode and let callback handle it
	CO_SUPPRESS;  // ignore contact altogether - let it run through
	CO_CLAMP;     // clamp resolution to separation only - objects will cease to overlap but their velocity will not be affected
}

enum ContactType
{
	CT_QUADLOC;     // co-located objects in quad tree
	CT_BASERADIUS;  // overlapping base radii
	CT_SHAPERADIUS; // overlapping shapes
	CT_SHAPEXSECT;  // intersecting shapes geometry (full contact)
	CT_FIXED;       // contact has already been dealt with....
}


class Contact
{
	
	public var type:ContactType;
	//
	
	public var quadRef:Quad;
	//
	public var ob1:SimObject; 
	public var ob2:SimObject;
	//
	public var ss1:SolidShape;
	public var ss2:SolidShape;
	
	//
	public static var action:CollisionOps;
	
}





interface ISimElement
{
	
	function startSim() : Void;
	function stopSim()  : Void;
	
	function simulate(dT:Float) : Void;
	function update(dT:Float) : Void;
	
	
	function remove() : Void;
	
}





