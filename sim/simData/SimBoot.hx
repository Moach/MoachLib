/**
 * ...
 * @author Moach
 */

package sim.simData;

import sim.simData.SimDefs;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;
import gen.Pool;
import sim.simElements.SimObject;

class SimBoot
{
	
	/**
	 * call me only once at game start... this is mostly just to fire up the pools used by the sim to supply commonly used structs...
	 *  however - although simple, this is CRITICAL and MUST be done before starting a simulation or using any simData stuff - 
	 * 
	 * 	otherwise, it all goes south...
	 */
	public static function lockNLoad()
	{
		//
		//
		//
			
		/// boot up the AVM2 memory system for our sim...
		//
		SimDefs.simHeapCache        = new ByteArray();
		SimDefs.simHeapCache.endian = Endian.LITTLE_ENDIAN;
		SimDefs.simHeapCache.length = SimDefs.SIM_VM_CACHE;
		//
		Memory.select(SimDefs.simHeapCache); // ok, now don't mess with this anymore... it'll fuck up the sim to no end if you do
		
		//
		
		
		
		
		/// now, start up ur pooling system... we don't wanna have to go around using "new" all the time...
		//
		SimDataPools.vectorPool = new Pool(Vec2D);      SimDataPools.vectorPool.allocate( SimDataPools.VECTOR_POOL_SIZE );
		SimDataPools.matrixPool = new Pool(RotMatrix);  SimDataPools.matrixPool.allocate( SimDataPools.MATRIX_POOL_SIZE );
		//
		SimDataPools.objPool    = new Pool(SimObject);  SimDataPools.objPool.allocate ( SimDataPools.OBJECT_POOL_SIZE  );	
		SimDataPools.cntcPool   = new Pool(Contact);    SimDataPools.cntcPool.allocate( SimDataPools.CONTACT_POOL_SIZE );
		//
		
		//
		SimDataPools.quadPool   = new Pool(Quad);       SimDataPools.quadPool.allocate(SimDataPools.QUAD_POOL_SIZE);
		
		//
		SimDataPools.nodePool   = new Pool(SimNode);    SimDataPools.nodePool.allocate(SimDataPools.NODE_POOL_SIZE);
		
		
		//
		//
		
		/*
		
		// create and setup the address lineups for the low-level bins
		//
		QuadBin.quadLocLineup = new List<UInt>();
		QuadBin.quadLocMax = SimDataPools.QUADBIN_BASE;
		
		//
		//QuadBin.stockQuadLineup(SimDataPools.QUADBIN_PRIME);
		//QuadBin.stockMnfdLineup(SimDataPools.MANIFOLD_PRIME);
		*/
	}
	
}
