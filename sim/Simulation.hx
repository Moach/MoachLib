/**
 * ...
 * @author Moach
 */

package sim;

import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.TypedDictionary;
import gen.Pool;
import sim.simData.Quad;
import sim.simData.RotMatrix;
import sim.simData.SimDefs;
import sim.simData.SimNode;
import sim.simData.SimNode;
import sim.simData.Vec2D;
import sim.simElements.SimObject;
import sim.simElements.SimRig;


class Simulation 
{
	//
	//
	
	public var _maxRange:Float;
	
	//
	public var main:Quad;
	
	//
	public var objsHead:SimNode<SimObject>;
	public var rigsHead:SimNode<SimRig>;
	
	
	//
	private var objIter:SimNodeIterator<SimObject>;
	private var rigIter:SimNodeIterator<SimRig>;
	
	
	//
	private var cntcHead:SimNode<Contact>;
	private var cntcIter:SimNodeIterator<Contact>;
	
	//
	//
	
	public function new(maxRange:Float = 500)
	{
		
		//
		//
		
		main = Quad.load();
		main.frameRng = _maxRange = maxRange;
		//
		main.stackLevel = 0;
		
		//
		
		objIter  = new SimNodeIterator<SimObject>();
		rigIter  = new SimNodeIterator<SimRig>();
		
		cntcIter = new SimNodeIterator<Contact>();
		
	}
	
	
	
	/**
	 * commands a global update of the simulation state, causing all active objects and rigs to update accordingly
	 * @param	dT "delta-time" multiplier to advance (1 = one full step)
	 */
	
	public function step(dT:Float)
	{
		//
		// update standalone objects...
		
		objIter.toHead(objsHead);
		
		for (i in objIter)
		{
			//
			//
			i.ref.update(dT);
			
			//
			//
		}
		
		//
		// update rigs...
		
		rigIter.toHead(rigsHead);
		
		for (i in rigIter)
		{
			//
			//
			i.ref.update(dT);
			
			//
			//
		}
		
		
		//
		//
	}
	
	
}


/**
 *
 * this here class is for setting up the static parts of the simulation engine...
 *  used to be in SimDefs... but i don't really want any working functions in there making a mess of things...
 */


