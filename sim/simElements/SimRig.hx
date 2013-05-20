/**
 * ...
 * @author Moach
 */

package sim.simElements;
import de.polygonal.ds.VectorTools;
import flash.Vector;
import sim.simData.RotMatrix;
import sim.simData.SimDefs;
import sim.simData.SimNode;
import sim.simData.Vec2D;
import sim.simDynamix.SimStep;
import sim.simElements.SimObject;

using gen.UtMath;

class SimRig //implements ISimNodeType<SimRig>
{
	
	public var simProxy:SimObject; // proxy object to represent rig as a whole
	
	public var objsHead:SimNode<SimObject>; // head for objects that are part of this rig
	
	public var simFlags:Int;
	
			
	public var CoG:Vec2D; // center of gravity offset from proxy in local (proxy) coords
	//public var pos:Vec2D; // rig CoG position in world space
	
	
	// rigs are node-link types as well...
	//
	public var  node:SimNode<SimRig>;
	
	private var objIter:SimNodeIterator<SimObject>; // iterates object on update cycle
	private var fnxIter:SimNodeIterator<SimObject>; // service iterator used in functions (keeps the above undisturbed) 
	//
	
	//
	//

	public function new(proxy:SimObject, objs:SimNode<SimObject>) 
	{
		//
		//
		simProxy = proxy;
		objsHead = objs; // simProxy.node;
		
		node = cast SimDataPools.nodePool.load();
		node.ref = this; 
		
		objIter = new SimNodeIterator<SimObject>();
		fnxIter = new SimNodeIterator<SimObject>();
		
		CoG = Vec2D.load();
		//pos = Vec2D.load();
		
		
		objIter.toHead(objsHead);
		
		for (i in objIter)
		{
			i.ref.userData = new RigObjectRef(i.ref);
			
		}
	}
	
	public function clear()
	{
		node.ref = null;
		SimDataPools.nodePool.unload(node);
		
		objIter.toHead(objsHead);
		
		for (i in objIter)
		{
			var objRef:RigObjectRef = cast i.ref.userData;
			objRef.dump();
			
			i.ref.userData = null;
			
		}
		
		//pos.dump();
		CoG.dump();
		
		objsHead = null;
		simProxy = null;
		objIter	 = null;
		fnxIter  = null;
	}
	
	

	public function shiftCG(cgx:Vec2D)
	{
		//
		// offset the proxy object when doing this...
		_v0.sub2(cgx, CoG).rotate(simProxy.rot);
		simProxy.pos.sub(_v0);
		
		CoG.cpy(cgx);
	
	}
	public function setCG(cgx:Vec2D)
	{
		//
		//
		CoG.cpy(cgx);
	
	}
	
	public inline function getRigCG(_vOut:Vec2D) : Vec2D
	{
		_v0.rotate2(CoG, simProxy.rot);
		return _vOut.add2(simProxy.pos, _v0);
	}
	
	
	
	public inline function getAccelTorque(accel:Vec2D, attPos:Vec2D) : Float
	{
		// get attack point in proxy space...
		_v0.sub2(attPos, simProxy.pos).rotateTranspose(simProxy.rot);
		return _v0.cross(accel);
	}
	
	
	
	//
	public function update(dT:Float)
	{
		//
		//
		
		
		simProxy.update(dT);
		
		// inverse torque from spinning proxy
		var counterTrq:Float = -simProxy.trq;
		
		var rT:Float = 1.0 / dT;
		
		
		
		// objects under rig are overriden - no point in trying to simulate them independently... it would only complicate things...
		// more fitting is to just update them as children of the proxy object, then simulate their stuff accordingly "by hand"
		
		objIter.toHead(objsHead);
		for (i in objIter)
		{
			//
			//
			var objRef:RigObjectRef = cast i.ref.userData;
			
			// rig children still have rotational freedom (we need it for now)
			///i.ref.trq += simProxy.trq;
			if (i.ref.trq != 0.0 || i.ref.rtv != 0.0 || counterTrq != 0.0)
			{
				//
				_stV[0] = objRef.lcRot;
				_stV[1] = i.ref.rtv;
				
				
				SimStep.integrateRK4(dT, 2, _stV, function (dv:Vector<Float>)
				{
					dv[0] = dv[1];
					dv[1] = i.ref.trq + counterTrq;
				});
				
				
				if (_stV[0] >= Math.PI * 2) _stV[0] -= Math.PI * 2; // 360-0 wrap around
				else if (_stV[0] < 0.0)     _stV[0] += Math.PI * 2; // 0-360 wrap around
				//
				
				objRef.lcRot   = _stV[0]; // increase rotation... (but don't bother calculating components just now)
				i.ref.rtv = _stV[1];
				i.ref.trq = 0.0; // reset
				
			}
			
			/** final rotation is object local rot + proxy rot */
			i.ref.rot._ang = (objRef.lcRot); 
			
			if (i.ref.rot._ang > 360.0)    i.ref.rot._ang -= 360.0;
			else if (i.ref.rot._ang < 0.0) i.ref.rot._ang += 360.0;
			
			
			
			/// position is simple enough...
			_v1.rotate2(_v0.sub2(objRef.lcPos, CoG), simProxy.rot);
			//
			i.ref.pos.add2(simProxy.pos, _v1); 
		
			
			_v2.cpy(i.ref.vel);
			
			/// now for velocity...
			if (simProxy.trq != 0.0 || simProxy.rtv != 0.0)
			{
				_v0.cpy(_v1);
				_v1.perp().mult(simProxy.rtv);   // we need our tangent speed, hence what i'm trying to do here....
				i.ref.vel.add2(_v1, simProxy.vel);
				_v1.mult2(_v0, -simProxy.rtv.sqr());
				i.ref.vel.add(_v1);
				
			} else
			{
				i.ref.vel.cpy(simProxy.vel);
			}
			
			
			// as for acceleration, it's easier to just backtrack by velocity delta....
			i.ref.acc.sub2(_v2, i.ref.vel).mult(rT);
			
			
			/// that should do it... - notice how we're just updating the numbers here.... they're not propagated from this over frames
			
			
			i.ref.quadRef = simProxy.quadRef;
			i.ref.trackQuadSpace(); // narrow down to a valid quad
			
		}
		
		//pos.cloneFrom(simProxy.pos).sub(_v0.rotateTranspose2(CoG, simProxy.rot));
		
	}
	
	private static var _stV:Vector<Float> =  new Vector<Float>(2);
	
	//
	//
	private static var _v0:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v1:Vec2D = Type.createEmptyInstance(Vec2D);
	//private static var _r1:RotMatrix = Type.createEmptyInstance(RotMatrix);
	private static var _v2:Vec2D = Type.createEmptyInstance(Vec2D);
	
	
	
	
	
	public function startSim()
	{
		simProxy.startSim();
		
		fnxIter.toHead(objsHead);
		
		for (i in fnxIter)
		{
			i.ref.changeCondition(SIM_SLVD);
			i.ref.startSim();
		}
		
	}
	
	
	public function stopSim()
	{
		simProxy.stopSim();
		
		fnxIter.toHead(objsHead);
		for (i in fnxIter)
		{
			i.ref.stopSim();
		}
	}
	
	
	//
	//
	
	//public var clbkChangeCondition:SimObject->SimCondition->Bool;
	//
	public function changeCondition(xcd:SimCondition)
	{
		//
		//
		simProxy.changeCondition(xcd);
		
		//fnxIter.toHead(objsHead);
		//for (i in fnxIter) i.ref.changeCondition(xcd);
	}
	
	
}



class RigObjectRef
{
	public var ref:SimObject;
	public var lcPos:Vec2D;
	public var lcRot:Float;	
	
	public function new(_ref:SimObject)
	{
		ref = _ref;
		
		lcPos = Vec2D.loadCpy(_ref.pos);
		lcRot = 0.0;
	}

	public function dump()
	{
		ref = null;
		lcPos.dump();
	//	lcRot.dump();
		
	}
}



