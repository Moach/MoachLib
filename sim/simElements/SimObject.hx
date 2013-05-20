/**
 * ...
 * @author Moach
 */

package sim.simElements;
import flash.Memory;
import flash.Vector;
import haxe.FastList;
import sim.simData.Quad;
import sim.simData.RotMatrix;
import sim.simData.SimDefs;
import sim.simData.SimNode;
import sim.simData.SimNode;
import sim.simData.Vec2D;
import sim.simDynamix.SimStep;
import sim.simDynamix.SimSpace;
import sim.simElements.props.SolidShape;
import sim.Simulation;

enum SimCondition
{
	SIM_OUT;      // out of the simulation
	
	SIM_FREE;     // active and freely tossing about without touching anything...
	
	SIM_SLVD;     // slaved to rig - check rig proxy for actual condition
	
	SIM_IDLE;     // rested against other object (or otherwise not moving)
	
	 
	SIM_PATCH;    // patched against stack manifold
	
	SIM_FROZEN;	  // intentionally frozen in place
	
	
	HAP_COLLIDE;  // hit against something (event)
	HAP_SEPARATE; // separated from a surface (event)
	
	HAP_STICK;    // stop into rest  (event)
	HAP_BUDGE;    // move out of rest (event)
	
	
}

enum QuantumCastPrecision
{
	
	QCP_LOW; QCP_MED; QCP_HIGH; QCP_OMG;
	//
	//	low       | if vectors cross - resolve by base-radius at intersection (crude)
	//	med       | if vectors cross and ToI is in range - resolve by base-radius at PoI (simple, but enough for billiards)
	//  high      | if vectors cross and ToI is in range - and shapes radius overlap at PoI - resolve by closest shapes base-radius (fancy!)
    //  omg       | if vectors cross and ToI is in range - and vector shapes intersect at PoI - resolve by closest shape intersections (omg!)
}


class SimObject/* implements ISimNodeType<SimObject> , implements ISimActor*/
{
	
	
	public var simRef:Simulation;   // reference to parent simulation
	public var simFlags:Int;        // binary interaction layers
	
	
	/// simulation options...
	
	//
	public var obj_translate:Bool;   // object may be moved by the sim
	public var obj_rotate:Bool;      // may be rotated by the sim
	//
	public var obj_detect:Bool;      // may be detected as contact
	public var obj_deflect:Bool;     // deflects other objects that hit it
	public var obj_divert:Bool;      // diverts upon being hit by other objects
	//
	public var obj_rig_isolate:Bool; // isolated to rig environment - does not interact with outside things
	//
	public var obj_patchable:Bool;   // may be patched into stack manifold when rested against it....
	
	//
	//
	
	//
	//
	private var _condition:SimCondition; // object current condition
	//private var _simState:Vector<Float>; // integration-compliant state
	
	
	
	//
	public var pos:Vec2D;     // object position
	public var vel:Vec2D;     // velocity (pixels/sec)
	public var acc:Vec2D;     // post-mass acceleration
	
	public var rtv:Float;     // rotation velocity (rads/sec)
	public var trq:Float;     // post-tensor torque
	
	public var rot:RotMatrix; // rotaion tranform matrix
	
	
	//
	public var mass:Float;
	public var tensor:Float;
	
	public var inverseMass:Float;    //   1 / mass of object
	public var inverseTensor:Float;  //   1 / angular tensor
	//
	
	//
	//
	public var baseRadius:Float;     // base-radius for low-res contact checking
	public var sqRadius:Float;       // squared base-radius for low-res contact checking
	public var invRadius:Float;      // 1 / base radius
	
	// collision vars - will be multiplied with opposing body for final effect
	//
	public var surfBounce:Float;     // collision restitution multiplier
	public var surfFrictn:Float;     // surface friction
	public var surfStickSq:Float;    // min squared relative velocity for full surface stop (go idle)
	public var surfBudgeSq:Float;    // min squared relative velocity for moving out of a full stop
	//
	
	public var quantumBias:Float;    // base-radius multiplier for determining quantum-velocity gate (when object moves faster than own size per frame)
	public var quantumCastLvl:QuantumCastPrecision;  // quantum-cast precision level - aka: "how to handle fast-mover collisions" - see enum above
	//
	   
	//
	//
	public var solidShapes:Vector<SolidShape>; // defined solid shapes....
	
	
	public var autoSurface:Bool;
	
	/*
	public var self:SimObject;
	public var next:SimObject;
	public var prev:SimObject;
	*/
	
	public var node:SimNode<SimObject>;
	
	public var userData:Dynamic;
	
	
	public var quadRef:Quad; // quad at which this object is located
	
	//
	//
	
	public static inline function load(?_simRef:Simulation = null) : SimObject
	{
		var loadObj:SimObject = SimDataPools.objPool.load();
		
		loadObj.simRef     = _simRef;
		loadObj.quadRef    = _simRef.main;
		loadObj._condition = SIM_OUT;
		
		loadObj.pos = Vec2D.load();
		loadObj.vel = Vec2D.load();
		loadObj.acc = Vec2D.load();
		
		loadObj.rot = RotMatrix.load();
		loadObj.rtv = loadObj.trq =  0.0;
		
		
		loadObj.node = cast SimDataPools.nodePool.load();
		loadObj.node.ref = loadObj;
		
		loadObj.autoSurface = true;
		
		// default settings...
		//
		
		
		loadObj.obj_translate = loadObj.obj_rotate = true;
		loadObj.obj_deflect   = loadObj.obj_detect = loadObj.obj_divert = true;
		loadObj.obj_patchable   = true;
		loadObj.obj_rig_isolate = false;
		
		loadObj.quantumBias = 1.0;
		
		loadObj.surfBounce  = 0.5;
		loadObj.surfFrictn  = 0.5;
		loadObj.surfStickSq = 0.01;
		loadObj.surfBudgeSq = 0.1;
		
		
		loadObj.mass   = loadObj.inverseMass   = 1.0;
		loadObj.tensor = loadObj.inverseTensor = 1.0;
		
		
		//
		return loadObj;
		
		
	}
	
	
	
	
	
	public function dump()
	{
		if (_condition != SIM_OUT) stopSim();
		//
		simRef     = null;
		userData   = null;
		node.ref   = null;
		
		//stepIntegrator = null;
		
		//
		clbkChangeCondition = null;
		clbkUpdate       = null;
		
		clbkRK4GaugeAccel  = null;
		//
		
		if (solidShapes != null)
		{
			
		}
		
		//
		pos.dump();
		vel.dump();
		rot.dump();
		acc.dump();
		//
		SimDataPools.nodePool.unload(node);
		SimDataPools.objPool.unload(this);
	}
	
	
	
	
	
	
	public function startSim()
	{
		if (_condition == SIM_OUT) _condition = SIM_FREE;
		lockOn2Quad(simRef.main);
		
	}
	
	
	public function stopSim()
	{
		_condition = SIM_OUT;
	}
	
	
	
	
	
	
	//
	//
	
	public var clbkChangeCondition:SimObject->SimCondition->Bool;
	//
	public function changeCondition(xcd:SimCondition)
	{
		//
		if (clbkChangeCondition != null)
			if (!clbkChangeCondition(this, xcd)) return;
		
		switch (xcd)
		{
			case SIM_IDLE:
				_condition = xcd;
			
			
			case SIM_FREE:
				_condition = xcd;
				
				
			case SIM_SLVD:
				_condition = xcd;
			
			
			case SIM_PATCH:
				_condition = xcd;
			
			
			case SIM_FROZEN:
				_condition = xcd;
			
			
			
			case HAP_STICK:
				_condition = SIM_IDLE;
			
			
			case HAP_BUDGE:
				_condition = SIM_FREE;
				
			
			case HAP_COLLIDE:
				_condition = SIM_FREE;
				
			
			case HAP_SEPARATE:
				_condition = SIM_FREE;
			
				
				
			
			case SIM_OUT:
				_condition = xcd;
				
				
			default:
		}
		
	}
	
	
	
	
	
	public inline function setBaseRadius(rds:Float)
	{
		baseRadius = rds;
		sqRadius = rds * rds;
		invRadius = 1 / rds;
	}
	
	
	public inline function setMass(ms:Float)
	{
		mass = ms;
		inverseMass = 1 / ms;
	}
	
	
	public inline function setTensor(ts:Float)
	{
		tensor = ts;
		inverseTensor = 1 / ts;
	}
	
	
	
	
	
	
	public inline function addForce(frcVec:Vec2D) : Vec2D
	{
		//
		acc.add(Vec2D.scratchVec.mult2(frcVec, inverseMass));
		return frcVec;
	}
	
	
	
	public inline function applyForce(frcVec:Vec2D) : Vec2D
	{
		//
		acc.add(frcVec.mult(inverseMass));
		return frcVec;
	}
	
	
	
	
	
	
	
	public inline function addTorque(t:Float) : Float
	{
		//
		var xt:Float = (t * inverseTensor);
		trq += xt;
		return xt;
	}
	
	
	
	
	//
	//
	//
	//
	
	
	
	public var clbkRK4GaugeAccel:SimObject->Vec2D->Vec2D->Vec2D->Vec2D->Float;
	//public var clbkRK4GaugeAccel:SimObject->Void;
	//
	
	private static var _vfx:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _rfx:Vec2D = Type.createEmptyInstance(Vec2D);
	//
	
	// for use with simulation steps...
	public static var simPos:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var simVel:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var simRot:Vec2D = Type.createEmptyInstance(Vec2D);

	//
	
	
	
	// this separate function for integrating the step allows us to forecast an objects motion... possibly very useful
	//
	
	private static var simState:Vector<Float> = new Vector<Float>(6);
	
	//
	public function simulate(_pos:Vec2D, _vel:Vec2D, _acc:Vec2D, _rot:Vec2D, _trq:Float, dT:Float)
	{
		
		if (clbkRK4GaugeAccel == null) // if we don't have a callback to assign forces, we must integrate with a less precise per-step accel
		{
			
			simState[0] = _pos.x; simState[2] = _pos.y; simState[4] = _rot.x;
			simState[1] = _vel.x; simState[3] = _vel.y; simState[5] = _rot.y;
			
			//
			SimStep.integrateRK4(dT, 6, simState, function(sp:Vector<Float>)
			{
				// go for derivative!
				sp[0] = sp[1];   sp[2] = sp[3];   sp[4] = sp[5];
				sp[1] = _acc.x;  sp[3] = _acc.y;  sp[5] = _trq;
				
			});
			
			
			// 
			_pos.x = simState[0];  _pos.y = simState[2];
			_vel.x = simState[1];  _vel.y = simState[3];
			
		} else // otherwise, we can use this much more awesome delta-sampling RK4 method
		{
			//
			//
			var tgt:SimObject = this;
			
			simState[0] = _pos.x; simState[2] = _pos.y; simState[4] = _rot.x;
			simState[1] = _vel.x; simState[3] = _vel.y; simState[5] = _rot.y;
			
			//
			SimStep.integrateRK4(dT, 6, simState, function(sp:Vector<Float>)
			{
				
				_pos.x = sp[0];  _pos.y = sp[2]; _rot.x = sp[4];
				_vel.x = sp[1];  _vel.y = sp[3]; _rot.y = sp[5];
				
				_trq = tgt.clbkRK4GaugeAccel(tgt, _pos, _vel, _rot, _acc);
				
				// now, turn sp into a derivative!
				sp[0] = sp[1];   sp[2] = sp[3];   sp[4] = sp[5];
				sp[1] = _acc.x;  sp[3] = _acc.y;  sp[5] = _trq;
				
			});
			
			
			
			_pos.x = simState[0];  _pos.y = simState[2];
			_vel.x = simState[1];  _vel.y = simState[3];
			_rot.x = simState[4];  _rot.y = simState[5];
			
			_acc.set(SimStep.rkX[1], SimStep.rkX[3]); /// lastly, update the proper acceleration from the calculated delta for external reference
		}
	
	}
	
	
	public var contactSurface:Bool;
	//
	
	public var clbkHandleSurface:SimObject->Quad->Float->Bool;
	
	public var clbkUpdate:SimObject->Float->Bool;

	
	/*
	public inline function getSweepRange(dT:Float, vOut:Vec2D) : Float
	{
		vOut.mult2(vel, -.5 * dT).add(pos); // find middle of velocity range over the last frame
		return baseRadius + (vel.getMagnitude() * .5 * dT); // return maximum range from that point
		
	}*/
	
	
	
	public inline function trackMotionData(dT:Float)
	{
		md_InvVel = vel.getInvMag();
		md_velocity = dT * (1 / md_InvVel);
		
		md_sweepMeanX = pos.x - (vel.x * dT * .5);
		md_sweepMeanY = pos.y - (vel.y * dT * .5);
		
		md_sweepRange = (md_velocity * .5) + baseRadius;
		
	}
	
	
	public var md_velocity:Float;
	public var md_InvVel:Float;
	
	public var md_sweepRange:Float;
	public var md_sweepMeanX:Float;
	public var md_sweepMeanY:Float;
	
//	public var md_deltaV:Float;
//	public var md_InvDV:Float;
	

	
	//
	public function update(dT:Float)
	{
		if (clbkUpdate != null)
			if (!clbkUpdate(this, dT)) return;
		
		//
		//
		switch (_condition)
		{
			case SIM_IDLE:
			
			
			
			case SIM_FREE:
				
				//
				//
				

				simRot.set(rot.getAngle(), rtv);
				//
				//acc.zero();
				//trq = 0.0;
				
				simulate(pos, vel, acc, simRot, trq,  dT);
				if (simRot.y != 0.0)
				{
					rot.setAngle(simRot.x);
					rtv = simRot.y;
					trq = SimStep.rkX[5];
				}
				
				//trackMotionData(dT); // refresh motion tracking data...
				
				trackQuadSpace();
				/*
				Main.field.graphics.lineStyle(0, 0, 0);
				Main.field.graphics.beginFill(0x00CCFF, .25);
				Main.field.graphics.drawRect(quadRef.framePos.x - quadRef.frameRng, quadRef.framePos.y - quadRef.frameRng, 
											   quadRef.frameRng + quadRef.frameRng,   quadRef.frameRng + quadRef.frameRng);
				Main.field.graphics.endFill();
				*/
				if (clbkHandleSurface == null)
					if (autoSurface) SimBroadPhase.autoSurface(this);
				else 
					SimBroadPhase.quadSurface(this, quadRef, dT, clbkHandleSurface);
				
				
					
					
				
			
				
				
			case SIM_SLVD:
			
				//
				
				
				
				
			case SIM_PATCH:
			
			
			
			case SIM_FROZEN:
			
			
			
			/*
			case HAP_STICK:
			
			d
			
			case HAP_BUDGE:
			
			
			
			case HAP_COLLIDE:
			*/
			
			
			case SIM_OUT:
			default:
		}
		
	}
	
	
	//
	//
	
	
	public inline function trackQuadSpace() : Void
	{
		/*
		(Math.abs(md_sweepMeanX - quadRef.framePos.x) + md_sweepRange >= quadRef.frameRng) ||
		(Math.abs(md_sweepMeanY - quadRef.framePos.y) + md_sweepRange >= quadRef.frameRng) ) 
		
		*/
		
		// figure out where we are...
		// we can skip this if the current quad remains correct for this position
		if ((quadRef == null) ||
			(Math.abs(pos.x - quadRef.framePos.x) + baseRadius >= quadRef.frameRng) ||
			(Math.abs(pos.y - quadRef.framePos.y) + baseRadius >= quadRef.frameRng) ) 
		{
			//
			
			if (quadRef!=simRef.main) // if you're already atop, then you're in shit, for you have stepped right out of the world
				quadRef = lockOn2Quad(simRef.main); /// scan down from top
				
				
				
		} else
		{
			quadRef = lockOn2Quad(quadRef); /// try to refine from current
		}
	}
	
	
	
	private static var quadScanStack:FastList<Quad> = new FastList<Quad>();
	
	public inline function lockOn2Quad(simMain:Quad) : Quad
	{
		// we're here to find the first quad that can completely contain our object... we'll just use the base-raduis for this, regardless
		// of whether we have shapes defined or not (a good reason to ensure your radius fully encompasses all the objects shapes)
		//
		
		if (!quadScanStack.isEmpty())
			while (quadScanStack.pop() != null){};
			
			
		quadScanStack.add(simMain);
		var cq:Quad;
		
		while ((cq = quadScanStack.pop()) != null)
		{
			//
			
			
			if (SimSpace.getFrameVsRadiusOverlap(pos, baseRadius, cq.framePos, cq.frameRng)) // overlap!
			{
				
				
				//
				//
				
				if ((Math.abs(pos.x - cq.framePos.x) + baseRadius >= cq.frameRng) ||
				    (Math.abs(pos.y - cq.framePos.y) + baseRadius >= cq.frameRng) )
				{
					
					// sticking out - the parent of this one is our quad!
					//
					if (cq.up == null) break; // unless this is the root...
					
					cq = cq.up;
					break;
				}
				
				
				if (cq.stump) break; // nothing further, stop here! this is our quad!
				
				
				
				// not there yet... refine!
				quadScanStack.add(cq.tl);
				quadScanStack.add(cq.tr);
				quadScanStack.add(cq.bl);
				quadScanStack.add(cq.br);
			}
				
			
		}
		
		return cq;
		
	}
	
	
}



private class _Vcs
{
	public static var _v0:Vec2D = Type.createEmptyInstance(Vec2D);
	//
	public static var _v1:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _v2:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _v3:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _v4:Vec2D = Type.createEmptyInstance(Vec2D);
	
	public static var _p0:Vec2D = Type.createEmptyInstance(Vec2D);
	//
	public static var _p1:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _p2:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _p3:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var _p4:Vec2D = Type.createEmptyInstance(Vec2D);
}


