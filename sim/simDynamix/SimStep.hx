/**
 * ...
 * @author Moach
 */

package sim.simDynamix;
import flash.Memory;
import flash.Vector;
import sim.simData.SimDefs;
import sim.simData.Vec2D;
import sim.simElements.SimObject;

interface ISimActor
{
	function simStepVec(spIn:Vec2D, svIn:Vec2D, spOut:Vec2D, svOut:Vec2D) : Void;
}

class SimStep
{ 
	//
	//
	
	private static var rk1:Vector<Float> = new Vector<Float>(SimDefs.STEP_FIELDS_MAX);
	private static var rk2:Vector<Float> = new Vector<Float>(SimDefs.STEP_FIELDS_MAX);
	private static var rk3:Vector<Float> = new Vector<Float>(SimDefs.STEP_FIELDS_MAX);
	 public static var rkX:Vector<Float> = new Vector<Float>(SimDefs.STEP_FIELDS_MAX);
	 
	//
	//
	public static inline function integrateRK4(dT:Float, pars:UInt, st:Vector<Float>, fx:Vector<Float>->Void)
	{
		var i:UInt = 0;
		while (i < pars) { rkX[i] = st[i]; ++i; } // initial state
		
		fx(rkX); i = 0; while (i < pars) { rkX[i] = st[i] + ( rk1[i] = rkX[i] ) * dT * .5; ++i; } // poll delta at initial state (half)
		fx(rkX); i = 0; while (i < pars) { rkX[i] = st[i] + ( rk2[i] = rkX[i] ) * dT * .5; ++i; } // poll delta at 1st half-way state (half)
		fx(rkX); i = 0; while (i < pars) { rkX[i] = st[i] + ( rk3[i] = rkX[i] ) * dT; ++i; }      // poll delta at 2nd half-way state (full)
		fx(rkX); i = 0; while (i < pars) // poll delta at full-step state
		{
			rkX[i] = ( rk1[i] + rk2[i] + rk2[i] + rk3[i] + rk3[i] + rkX[i] ) * .16666666666666666667; // average out (half-way deltas go 2X)
			st[i] = st[i] + rkX[i] * dT ; /// advance - note that rkX now holds the final delta for public reference
			i++;
		}
	}
	
	//
	//
	
	
	
	
	/// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// 
	
}


class SimUtils
{
	
	//
	//
	public static inline function line(x1 : Float, x2 : Float, y0 : Float, y1 : Float, y2 : Float) 
	{
        return (x2 - x1) * (y0 - y1) / (y2 - y1) + x1;
		
	}
	public static inline function lineInt(x1 : Float, x2 : Float, y0 : Float, y1 : Float, y2 : Float) 
	{
		return Math.round(line(x1, x2, y0, y1, y2));
	}
	//
	//
}





