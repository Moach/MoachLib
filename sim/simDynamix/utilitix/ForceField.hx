/**
 * ...
 * @author Moach
 */

package sim.simDynamix.utilitix;
import flash.Vector;
import sim.simData.Vec2D;

class ForceField<T>  
{
	
	public var simFlags:Int;
	public var forces:Vector<IForceSampler>;
	//
	//
	
	public function new(?_fcs:Vector<IForceSampler<T>> = null, ?_flags:Int = 0) 
	{
		//
		if (_fcs != null) forces = _fcs;
		simFlags = _flags;
	}
	
	
	function poll(vOut:Vec2D, ref:T) : Vec2D
	{ 
		//
		var vs:Vec2D = Vec2D.load();
		
		for (fsp in forces)
		{
			fsp.poll(vs, point);
			vOut.add(vs);
		}
		
		//
		vs.dump();
		
		return vOut;
	}
	
}


interface IForceSampler<RT>
{
	//
	function poll(vOut:Vec2D, ref:<RT>) : Vec2D; // should return vOut after assigning force to it!
	
}
