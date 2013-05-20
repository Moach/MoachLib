/**
 * ...
 * @author Moach
 */

package sim.simDynamix;
import flash.Memory;
import haxe.FastList;
import sim.simData.Quad;
import sim.simData.RotMatrix;
import sim.simData.SimDefs;
import sim.simData.Vec2D;
import sim.simElements.SimObject;



using gen.UtMath;

class SimSpace
{
	//
	
	
	
	/**
	 * gets the squared distance between two points
	 * @param	v1 first point
	 * @param	v2 second point
	 * @return   the squared distance between them
	 */
	
	public static inline function getDistSQ(v1:Vec2D, v2:Vec2D) : Float
	{
		var dx:Float = v1.x - v2.x; var dy:Float = v1.y - v2.y;
		return (dx * dx) + (dy * dy);
	}
	
	
	
	/**
	 * gets whether or not two points have a radial overlap by comparing the squared sum of their radii with the squared distance between them 
	 * @param	v1 first point
	 * @param	r1 radius around first point
	 * @param	v2 second point
	 * @param	r2 radius around secon point
	 * @return true/false on if there is an overlap
	 */
	public static inline function getRadiusOverlap(v1:Vec2D, r1:Float, v2:Vec2D, r2:Float) : Bool
	{
		return getDistSQ(v1, v2) > ((r1 + r2) * (r1 + r2));
		//
	}
	
	
	
	/**
	 * returns whether there's overlap between the boxes discribed between vMin/vMax 1 and 2
	 * @param	vMin1
	 * @param	vMax1
	 * @param	vMin2
	 * @param	vMax2
	 * @return
	 */
	public static inline function getBoxOverlap(vMin1:Vec2D, vMax1:Vec2D, vMin2:Vec2D, vMax2:Vec2D) : Bool
	{
		if( vMax1.x < vMin2.x ) return false;
		if( vMax1.y < vMin2.y ) return false;
		if( vMax2.x < vMin1.x ) return false;
		if( vMax2.y < vMin1.x ) return false;
		//if none of our outs work, the 2 rectangles collide- return true
		return true;
	}
	
	public static inline function getAbsBoxOverlap(vA1:Vec2D, vA2:Vec2D, vB1:Vec2D, vB2:Vec2D) : Bool
	{
		// first we gotta work out which of these are actually min and max.... otherwise it might fail
		var xAmax:Float; var xAmin:Float; if ( vA1.x > vA2.x ) { xAmax = vA1.x; xAmin = vA2.x; } else { xAmax = vA2.x; xAmin = vA1.x; }
		var yAmax:Float; var yAmin:Float; if ( vA1.y > vA2.y ) { yAmax = vA1.y; yAmin = vA2.y; } else { yAmax = vA2.y; yAmin = vA1.y; }
		var xBmax:Float; var xBmin:Float; if ( vB1.x > vB2.x ) { xBmax = vB1.x; xBmin = vB2.x; } else { xBmax = vB2.x; xBmin = vB1.x; }
		var yBmax:Float; var yBmin:Float; if ( vB1.y > vB2.y ) { yBmax = vB1.y; yBmin = vB2.y; } else { yBmax = vB2.y; yBmin = vB1.y; }
		
		if( xAmax < xBmin ) return false;
		if( yAmax < yBmin ) return false;
		if( xBmax < xAmin ) return false;
		if( yBmax < yAmin ) return false;
		
		//if none of our outs work, the 2 rectangles collide- return true
		return true;
	}
	
	
	
	public static inline function getPointInAbsBox(pt:Vec2D, v1:Vec2D, v2:Vec2D) : Bool
	{
		var xmax:Float; var xmin:Float; if ( v1.x > v2.x ) { xmax = v1.x; xmin = v2.x; } else { xmax = v2.x; xmin = v1.x; }
		var ymax:Float; var ymin:Float; if ( v1.y > v2.y ) { ymax = v1.y; ymin = v2.y; } else { ymax = v2.y; ymin = v1.y; }
		if (pt.x > xmax || pt.x < xmin) return false;
		if (pt.y > ymax || pt.y < ymin) return false;
		return true;
	}
	
	
	
	public static inline function getPointVsFrameOverlap(pt:Vec2D, fPos:Vec2D, fRng:Float) : Bool
	{
		var cdx:Float = pt.x - fPos.x; 
		var cdy:Float = pt.y - fPos.y; 
		if (cdx < 0.0) cdx = -cdx;
		if (cdy < 0.0) cdy = -cdy;
		return ((cdx <= fRng) && (cdy <= fRng));
	}
	
	//public static var lastOverlapType:OverlapType;
	public static function getFrameVsRadiusOverlap(cp:Vec2D, rd:Float, fPos:Vec2D, fRng:Float) : Bool
	{
		// this is allegedly faster than Math.abs - much more inconvenient, no doubt
		var cdx:Float = cp.x - fPos.x; if (cdx < 0.0) cdx = -cdx;
		var cdy:Float = cp.y - fPos.y; if (cdy < 0.0) cdy = -cdy;

		if (cdx > (fRng + rd)) return false;
		if (cdy > (fRng + rd)) return false;

		if (cdx-fRng <= fRng) return true;
		if (cdy-fRng <= fRng) return true;
		
		return (((cdx - fRng) * (cdx - fRng)) + ((cdy - fRng) * (cdy - fRng))  <=  (rd*rd) );
	}
	
	
	
	/*
	public static inline function getFrameVsRadiusAspect(cp:Vec2D, rd:Float, fPos:Vec2D, fRng:Float) : Int	
	{
		//
		
		var cdx:Float = Math.abs(cp.x - fPos.x);
		var cdy:Float = Math.abs(cp.y - fPos.y);

		if (cdx > (fRng + rd)) return 0; // completely out
		if (cdy > (fRng + rd)) return 0;

		if (cdx-fRng <= fRng) return 1; // completely in
		if (cdy-fRng <= fRng) return 1;
		
		return (((cdx - fRng) * (cdx - fRng)) + ((cdy - fRng) * (cdy - fRng))  <=  (rd*rd) )? 2 : 0; // half-way in or fully out
	}
	*/
	
	public static inline function getLineIntercept(vOut:Vec2D, v1:Vec2D, v2:Vec2D, v3:Vec2D, v4:Vec2D ) : Vec2D
	{
		// this i got from wikiedia, i really have no idea what i'm doing...
		//
		
		var dxL1:Float = v1.x - v2.x; var dxL2:Float = v3.x - v4.x;
		var dyL1:Float = v1.y - v2.y; var dyL2:Float = v3.y - v4.y;
		
		var crsL1:Float = (v1.x * v2.y) - (v1.y * v2.x);
		var crsL2:Float = (v3.x * v4.y) - (v3.y * v4.x);
		var dxy:Float = 1 / ((dxL1 * dyL2) - (dyL1 * dxL2)); // denominator is the same for x and y, so math was optimized a bit here
		//
		
		vOut.x = ( (crsL1 * dxL2) - (dxL1 * crsL2) ) * dxy;			
		vOut.y = ( (crsL1 * dyL2) - (dyL1 * crsL2) ) * dxy;
					
		
		return vOut; // here's hoping...
	}
	
	public static inline function getSegIntersect(vOut:Vec2D, v1:Vec2D, v2:Vec2D, v3:Vec2D, v4:Vec2D ) : Bool
	{
		var dxL1:Float = v1.x - v2.x; var dxL2:Float = v3.x - v4.x;
		var dyL1:Float = v1.y - v2.y; var dyL2:Float = v3.y - v4.y;
		
		var crsL1:Float = (v1.x * v2.y) - (v1.y * v2.x);
		var crsL2:Float = (v3.x * v4.y) - (v3.y * v4.x);
		var det:Float = ((dxL1 * dyL2) - (dyL1 * dxL2));
		var dxy:Float = 1 / det;
		
		vOut.x = ((crsL1 * dxL2) - (dxL1 * crsL2)) * dxy;			
		vOut.y = ((crsL1 * dyL2) - (dyL1 * crsL2)) * dxy;

		// but this time we return whether or not the intercept is within segments
		return (det > 0.0 && det < 1.0);
	}
	
	
	
	
	
	
	public static function getSegVsRectOverlap(rMin:Vec2D, rMax:Vec2D, v1:Vec2D, v2:Vec2D) : Bool
	{                     
		//
		//
		var xMax:Float = v1.x;
		var yMax:Float = v1.y;
		
		var xMin:Float = v2.x;
		var yMin:Float = v2.y;
		
		var swap:Bool = false;
		
		// swap as needed for Min and Max...
		if (xMax < v2.x) 
		{
			xMax = v2.x;
			xMin = v1.x;
			
			swap = true;
		}
		if (yMax < v2.y)
		{
			yMax = v2.y;
			yMin = v1.y;
			
			swap = !swap;
		}

		//
		// early outs... basic rectangle test
		
		if (xMin > rMax.x) return false; // too far left
		if (xMax < rMin.x) return false; // too far right
		
		if (yMin > rMax.y) return false; // too far down
		if (yMax < rMin.y) return false; // too far up
		
		//
		// ok, we're close enough...
		
		// before we go into by-line checks, we can still make sure the line isn't completely inside or at least has one end inside the rect
		// that would be an easy-in situation... so let's clear that one first
		
		if ((v1.x > rMin.x && v1.x < rMax.x) && (v1.y > rMin.y && v1.y < rMax.y)) return true; // v1 is inside!
		if ((v2.x > rMin.x && v2.x < rMax.x) && (v2.y > rMin.y && v2.y < rMax.y)) return true; // v2 is inside!
		
		
		// instead of checking each side, let's do something simpler...
		// we'll just check line-vs-line along the min/max division of the rect - this considerably reduces the needed checks...
		
		// and... since we already have a defined min and max vector, we can simply xy-swap that and check dierectly against rMin and rMax
		// that should guarantee we have the mostly opposing cross-rect line, so we only have to do one line check! :)
		
		
		// this requires checking for the better opposing diagonal - if one of the vectors got swapped, we swap vectors
		// if both or none were swaped above, then we swap the diagonal corners instead!
		//
		if (swap)
			getSegIntersect(_V.v1, _V.v2.set(xMin, yMax), _V.v3.set(xMax, yMin), rMin, rMax);
		else
			getSegIntersect(_V.v1, v1, v2, _V.v2.set(rMin.x, rMax.y), _V.v3.set(rMax.x, rMin.y));
		
		
		if (_V.v1.x > rMax.x || _V.v1.x < rMin.x) return false; // x is out
		if (_V.v1.y > rMax.y || _V.v1.y < rMin.y) return false; // y is out
		
		// still here?
		
		return true; // got it!
  	}
	
	
	

	
	
	
	public static function frameLineClip(clipV0:Vec2D, clipV1:Vec2D, framePos:Vec2D, frameRng:Float) : Bool
	{
		
		var t0:Float = 0.0; var t1:Float = 1.0;
		var dX:Float = clipV1.x - clipV0.x;
		var dY:Float = clipV1.y - clipV0.y;
		
		var p:Float = 0.0; var q:Float = 0.0; var r:Float = 0.0;
		
		var edge:UInt = 0;
		while (edge < 4)
		{
			switch (edge)
			{
				case 0: p = -dX; q = -((framePos.x - frameRng) - clipV0.x);
				case 1: p =  dX; q =  ((framePos.x + frameRng) - clipV0.x);
				case 2: p = -dY; q = -((framePos.y - frameRng) - clipV0.y);
				case 3: p =  dY; q =  ((framePos.y + frameRng) - clipV0.y);
			}
			
			r = q / p;
			if (p == 0 && q < 0) return false; // parallel outside - useless...
			
			if (p < 0)
			{
				if (r > t1) return false; // out!
				if (r > t0) t0 = r; /// clipped!
			} else 
			if (p > 0)
			{
				if (r < t0) return false; // out!
				if (r < t1) t1 = r; /// got it!
			}
			
			++edge;
		}
		
		
		clipV0.x = clipV0.x + t0 * dX;
		clipV0.y = clipV0.y + t0 * dY;
		clipV1.x = clipV0.x + t1 * dX;
		clipV1.y = clipV0.y + t1 * dY;
		//
		return true;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	public static var _closestSegScalar:Float = 0.0;
	//
	public static inline function getClosestSegPoint(vOut:Vec2D, pt:Vec2D, v1:Vec2D, v2:Vec2D) : Vec2D
	{
		var v:Vec2D = _V.v1.sub2(v2, v1);
		var w:Vec2D = _V.v2.sub2(pt, v1);
		
		var _closestSegScalar:Float =  w.dot( v ) / v.dot( v );
		_closestSegScalar = ((_closestSegScalar > 0)? ((_closestSegScalar < 1)? _closestSegScalar : 1) : 0); 
		
		return vOut.add2( v1, v.mult( _closestSegScalar ) );
	}
	
	
	public static inline function getCircleVsSegIntersect(vOut:Vec2D, pt:Vec2D, rd:Float, v1:Vec2D, v2:Vec2D) : Bool
	{
		return ( _V.v4.sub2( getClosestSegPoint(vOut, pt, v1, v2), pt ).getMagSQ() <= rd * rd );
	}
	
	
	
	
	
	
	public static inline function getClosestDistToSeg(vOut:Vec2D, pt:Vec2D, v1:Vec2D, v2:Vec2D) : Float
	{
		return ( _V.v4.sub2( getClosestSegPoint(vOut, pt, v1, v2), pt ).getMagnitude() );
	}
	
	public static inline function getClosestDistSQToSeg(vOut:Vec2D, pt:Vec2D, v1:Vec2D, v2:Vec2D) : Float
	{
		return ( _V.v4.sub2( getClosestSegPoint(vOut, pt, v1, v2), pt ).getMagSQ() );
	}
	
	public static inline function getClosestInvDistToSeg(vOut:Vec2D, pt:Vec2D, v1:Vec2D, v2:Vec2D) : Float
	{
		return ( _V.v4.sub2( getClosestSegPoint(vOut, pt, v1, v2), pt ).getInvMag() );
	}
	
	
	
	
	
	//
	//
	//
	public static inline function quadScan(main:Quad, fn:Quad->Bool)
	{
		var stack:FastList<Quad> = new FastList<Quad>();
		
		var q:Quad;
		//
		
		stack.add(main); // load up...
		
		while ((q = stack.pop()) != null)
		{
			//
			var rt:Bool = fn(q);
			if (!rt) continue;
			
			
			stack.add(q.tl);
			stack.add(q.tr);
			stack.add(q.bl);
			stack.add(q.br);
			
		}
		
	}
	
	
}





/**
 * the BroadPhase class is designed to provide means to detect possible contacts in the general simulation quadtree (sim-space)
 * 	as well as contacts against the blockage manifold 
 * 
 * 	all calculations here are based on global space
 */
class SimBroadPhase
{
	//
	
	private static var qStack:FastList<Quad> = new FastList<Quad>();
	
	private static var _v0:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v1:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v2:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v3:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v4:Vec2D = Type.createEmptyInstance(Vec2D);
	private static var _v5:Vec2D = Type.createEmptyInstance(Vec2D);
	
	private static var _rt:RotMatrix = Type.createEmptyInstance(RotMatrix);
	
	/**
	 * searches for and automatically resolves collisions between the given object and the global surface quatree
	 * @param	obj object to check for
	 * @return returns true or false on whether a collision has occurred
	 */
	public static function autoSurface(obj:SimObject) : Bool
	{
		var hit:Bool = false;
		
		if (obj.quadRef != null)
		{
			var cq:Quad = obj.quadRef;
			
			//var cvel:Vec2D = Vec2D.loadCpy(testBall.vel);
			var ctpt:Vec2D = _v0;
			var nrml:Vec2D = _v1;
			var vMag = obj.vel.getMagnitude();
			
			
			
			//
			qStack.add(cq);
			
			while ((cq = qStack.pop()) != null)
			{
				//
				//
				
				
				if (SimSpace.getFrameVsRadiusOverlap(obj.pos, obj.baseRadius, cq.framePos, cq.frameRng)) // overlap!
				//if (SimSpace.getCircleVsSegIntersect(ctpt, cq.framePos, testBall.baseRadius, testBall.pos,dir.add2(testBall.pos, testBall.vel))) // overlap!
				{
					
					
					
					if (cq.block > 0)
					{
						//
						//
						if (SimSpace.getCircleVsSegIntersect(ctpt, obj.pos, obj.baseRadius, cq.manifoldFrom, cq.manifoldTo))
						{
							
							//
							nrml.sub2(ctpt, obj.pos);
							
							//
							if (nrml.getMagSQ() <= obj.sqRadius) 
							{
								/// first we correct for the intersection
								//
								
								var nMag = nrml.getMagnitude();
							
								var spar:Vec2D = Vec2D.load().resize2(nrml, nMag - obj.baseRadius);
								
								obj.pos.add(spar); // correct position
								
								spar.dump();
								
								
								if (hit) continue;
								
								
								//
								nrml.div(nMag); // normalize
								
								
								//
								//
								/// now we figure out a transform for the contact surface... this should make things much simpler to handle
								
								
								// transform to surface plane local space
								//var ctXfrm:RotMatrix = RotMatrix.load( Math.atan2(nrml.x, nrml.y)/*Vec2D._cross(nrml, Vec2D.scratch(0,1))*/);
								var ctXfrm:RotMatrix = RotMatrix.loadRCP(nrml.y, -nrml.x);
								
								
								// and this makes things a lot more 1-dimensional... now every contact can be handled as a x-aligned surface
								//
								
								//obj.clbkRK4GaugeAccel(obj, obj.pos, obj.vel, Vec2D.scratch(0, 0), obj.acc.zero());
								
								
								ctXfrm.rotateVector(obj.vel);
								ctXfrm.rotateVector(obj.acc);
							//	obj.acc.zero();
								
								obj.acc.add(obj.vel);
								
							
								var surfVel:Float = ((obj.rtv / Math.PI) * obj.baseRadius) - obj.vel.x;
								var surfAcc:Float = surfVel * obj.surfFrictn * (obj.acc.y * obj.acc.getInvMag());
								
								
								obj.trq += /*surfTrq; */ (( surfAcc / obj.baseRadius ) * Math.PI);
								
								// bouncing off is easy when things are flat...
								obj.acc.y = -((1 + obj.surfBounce) * obj.vel.y);
								
								obj.acc.x = surfAcc;
								
								
								 
								
								// unrotate back into world space...
								ctXfrm.rotateTransposeVector(obj.vel);
								ctXfrm.rotateTransposeVector(obj.acc);
								
								
								
								ctXfrm.dump();
								
								
								hit = true;
								//break;
							}
						} 
						
						//
						//
					}
					
					if (cq.stump) continue; //...
					
					// not there yet... refine!
					qStack.add(cq.tl);
					qStack.add(cq.tr);
					qStack.add(cq.bl);
					qStack.add(cq.br);
				}
				
			}
			
		//	nrml.dump();
		//	ctpt.dump();
			//
			
			//
		}
		
		if (!qStack.isEmpty()) while (qStack.pop() != null) { };
		return hit;
	}
	
	
	
	public static var surfCtPos:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var surfCtSep:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var surfCtNrm:Vec2D = Type.createEmptyInstance(Vec2D);
	public static var surfCtVel:Vec2D = Type.createEmptyInstance(Vec2D);
	//
	public static function quadSurface(obj:SimObject, cq:Quad, dT:Float, fn:SimObject->Quad->Float->Bool) : Bool
	{
		
		
		if (cq.stump && cq.block == 0) return false; // nothing here or below... easy out!
		
		//
		
		//
		var ctpt:Vec2D = _v0;
		var vctr:Vec2D = _v1;
		var rpos:Vec2D = _v2;
		var rvel:Vec2D = _v3;
		
		var refQuad:Quad = cq;
		
		//
		if (!qStack.isEmpty()) while (qStack.pop() != null) { };
		qStack.add(cq);
		
		
		surfCtSep.zero();
		surfCtPos.zero();
		surfCtVel.zero();
		surfCtNrm.zero();
		
		var ctc:Float = 0.0; /// contact averaging interpolator 
		
		var t:Float = 1.0;
		
		
		// start with stuff that we'll need later.....
		
		var dpos:Vec2D = _v4;
		var dvel:Vec2D = _v5;
		
		dvel.mult2(obj.acc, dT * .5);
		dpos.add2(obj.pos, rvel.sub2(obj.vel, dvel).mult(dT)); // that should give us a good approximation of where the object is coming from
		
		
		while ((cq = qStack.pop()) != null)
		{
			//
			
			
			if (cq.block > 0 && SimSpace.getFrameVsRadiusOverlap(obj.pos, obj.baseRadius, cq.framePos, cq.frameRng)) // quad frame overlap!
			{
				// so far, this is just to isolate the quads where our object "could" hit surface... not the actual contact check
				//
				
				// now, for actual surface-loaded quads....
				if (cq.block == 2)
				{
					/// there's a surface in this quad....
					
					// check for a surface level crossing
					//
					rpos.sub2(obj.pos, cq.framePos).alignIn(cq.manifoldNrml);
					rvel.cpy(obj.vel).alignIn(cq.manifoldNrml);
					if (rvel.y > 0.0) continue; // moving away / backfacing - ignoring these makes it possible to "climb" onto surfaces from below
					
					
				/*  vctr.set(0, 25).alignOut(cq.manifoldNrml).add(cq.framePos);// -- aligning vectors DOES work!
				    Main.vs.useMarkerRef(cq.manifoldNrml).setLineToMarker(vctr, cq.framePos, 0x00FF00, 1, 1.0);
				*/	
					rpos.y -= obj.baseRadius;
					//
					if (rpos.y <= cq.manifoldLvl)
					{
						// possible contact! - here the real stuff begins
						
					/*	vctr.set(0, -50).alignOut(cq.manifoldNrml).add(cq.framePos);
						Main.vs.useMarkerRef(cq.framePos).setLineToMarker(vctr, cq.framePos, 0x00FF00, 1, 1.0);
					*/
						
						/// stop here if object is more than its own radius away off a side 
						if (rpos.x >  (cq.manifoldRngR+obj.baseRadius)) continue;
					    if (rpos.x < -(cq.manifoldRngL+obj.baseRadius)) continue;
						
						
						/** this is to check for the edge cases, where the object may be intersecting the vertices between surface sections*/
						
						if (rpos.x > cq.manifoldRngR) /// possibly hits the right end
						{
							ctpt.set(cq.manifoldRngR,  cq.manifoldLvl).alignOut(cq.manifoldNrml).add(cq.framePos);
							vctr.sub2(obj.pos, ctpt);
							if ( vctr.getMagSQ() > obj.sqRadius ) continue; // no hit
							
							
							vctr.norm(); // normal is separation axis around object center
						/*	surfCtNrm.add(vctr);
						*/	
							
						} else
						if (rpos.x < -cq.manifoldRngL) /// possibly hits the left end 
						{
							ctpt.set(-cq.manifoldRngL,  cq.manifoldLvl).alignOut(cq.manifoldNrml).add(cq.framePos);
							vctr.sub2(obj.pos, ctpt);
							if ( vctr.getMagSQ() > obj.sqRadius ) continue; // nothing to see here... go away
							
							
							
							vctr.norm();
						/*	surfCtNrm.add(vctr);
						*/	
						} else
						{
						
							
							//  or..... 
							/// object is right between both ends
							//
							ctpt.set(rpos.x,  cq.manifoldLvl).alignOut(cq.manifoldNrml).add(cq.framePos);
							
						/*	surfCtNrm.add(cq.manifoldNrml); // use surface normal
						*/  vctr.cpy(cq.manifoldNrml);
						}
						
						/// add contacts up - scale their relevance in inverse proportion to their distance to the "from" position
						//
						var d:Float = ctpt.sub(dpos).getInvMag(); // the closer, the better
						//
						surfCtPos.add(ctpt.mult(d));
					/*	surfCtVel.add(rvel.mult2(dvel, d));
					*/	surfCtNrm.add(vctr.mult(d));
						
						ctc += d;  /// now we hope it works....
						
							
					} 
					
				}
				
				if (cq.stump) continue; //...
				
				// not there yet... refine as needed
				if (cq.tl.block > 0) qStack.add(cq.tl);
				if (cq.tr.block > 0) qStack.add(cq.tr);
				if (cq.bl.block > 0) qStack.add(cq.bl);
				if (cq.br.block > 0) qStack.add(cq.br);
				 
			}
			
		}
		
		
		//
		if (ctc != 0.0)
		{
			// here we finish up by averaging out the weighed contact points
			//
			ctc = 1.0 / ctc;
			surfCtPos.mult(ctc).add(dpos);
		/*	surfCtVel.mult(ctc);
		*/	
			surfCtNrm.norm(); // normal is easier....
			//
			
			/// postion of object at contact, projected from surface normal over object radius
			surfCtSep.mult2(surfCtNrm, obj.baseRadius).add(surfCtPos); 	
			surfCtSep.sub(obj.pos); // subtract actual position for separation delta
			
			surfCtVel.mult2(dvel, surfCtSep.dot(dvel) / dvel.getMagSQ() ).add(obj.vel);
			
			//
			fn(obj, refQuad, t); /// call it!
			
			return true;
		} 
		
		
		
		return false;
	}
	
	
	
}


/**
 * ClosePhase is how we define ways to detect object-vs-object contacts after they are located in sim-space
 * 	calculations here are done in relative-space - we scan each object's local quadtree (object-space) against the opposing objects quadtree - 
 *  this is how we may easily define complex shapes up to a max resolution....
 * 
 */
class SimClosePhase
{
	//
	public static function checkQuadShapeOverlap()
	{
		
		
	}
	
	
	
}



