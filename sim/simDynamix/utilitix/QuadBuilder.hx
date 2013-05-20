/**
 * ...
 * @author Moach
 */

package sim.simDynamix.utilitix;
import flash.display.MovieClip;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;
import flash.Vector;
import haxe.FastList;
import sim.simData.Quad;
import sim.simData.RotMatrix;
import sim.simData.SimDefs;
import sim.simData.Vec2D;
import sim.simDynamix.SimSpace;

class QuadBuilder 
{
	//
	//

	/*
	private static var _maxRes:Int; // max-res currently at use
	private static var _from:Vec2D;  // from postion in use
	private static var _to:Vec2D;    // from postion in use
	private static var _slope:Float; // x/y slope
	
	*/
	
	public static var quadIdx:UInt = 0;
	public static var surfIdx:UInt = 0;
	
	//
	/**
	 * fills the quadtree downwards (assuming 2d x/y representation)
	 * @param	from
	 * @param	to
	 * @param	maxRes
	 * @param	main
	 */
	public static function quadSurf(from:Vec2D, to:Vec2D, main:Quad, maxRes:Int)
	{
		//var slope:Float = (from.y - to.y) / (from.x - to.x);
		
		
		var stack:FastList<Quad> = new FastList<Quad>();
		
		var q:Quad;
		//
		
		stack.add(main); // load up...
		
		var qMin:Vec2D = Vec2D.load();
		var qMax:Vec2D = Vec2D.load();
		var surfRef:Vec2D = Vec2D.load();
		var surfRot:RotMatrix = RotMatrix.load();
				
		++surfIdx;
		
		
		
		//try{
		//let's roll!
		
		 while ((q = stack.pop()) != null)
		 {
			
			//if (!q.inUse) trace("crap!");
			qMin.add2(q.framePos, Vec2D.scratch( -q.frameRng, -q.frameRng)); // quad min
			qMax.add2(q.framePos, Vec2D.scratch(  q.frameRng,  q.frameRng)); // quad max
			
			
			if (q.stackLevel >= maxRes) // maximum resolution reached!
			{
				//
				// we should probably do something with this...
				
				if (q.block != 0)
				{
					/*
					//
					Main.map.graphics.lineStyle(0, 0x000000, 0);
					Main.map.graphics.beginFill( 0xFF0000, 1); // paint green where we reach full depth
					Main.map.graphics.drawRect(q.framePos.x - q.frameRng, q.framePos.y - q.frameRng, 
											   q.frameRng  +  q.frameRng, q.frameRng  +  q.frameRng);*/
					//
					continue;
				}
				
				
				// check for intersection...
				//
				if (SimSpace.getSegVsRectOverlap(qMin, qMax, from, to))
				{
					q.manifoldFrom = Vec2D.loadCpy(from);
					q.manifoldTo   = Vec2D.loadCpy(to);
					
					

					q.manifoldNrml = Vec2D.load().sub2(from, to).perp().norm();
				//	q.manifoldNrml.y = -q.manifoldNrml.y;
					//
					
					
					
					
					SimSpace.getClosestSegPoint( surfRef, q.framePos, q.manifoldTo, q.manifoldFrom );
					
					surfRef.sub(q.framePos).alignIn(q.manifoldNrml);
					q.manifoldLvl = surfRef.y;
					
					Main.ptc.p2.x = q.manifoldNrml.x * 10; Main.ptc.p2.y = q.manifoldNrml.y * 10;
					//Main.ptc.plane.y = q.manifoldLvl;
					//Main.ptc.plane.rotation = 90+Math.atan2(q.manifoldNrml.y, q.manifoldNrml.x) * SimDefs._DEG;
					
					//
					//
					q.block = 1;
					//

					q.idx = quadIdx;
					q.ids = surfIdx;
					
					++quadIdx;
				}				
				else {
					/*
					Main.map.graphics.lineStyle(0, 0, 0);
					Main.map.graphics.beginFill( 0x00CCFF, .3); // paint half-cyan where we reach full depth but there's no line
					Main.map.graphics.drawRect(q.framePos.x - q.frameRng, q.framePos.y - q.frameRng, 
											   q.frameRng  +  q.frameRng, q.frameRng  +  q.frameRng);
					//
					Main.map.graphics.endFill();*/
				}
				
				//
				//
				
				continue;
			} 
			
			//
			
			// check for intersections...
			if (SimSpace.getSegVsRectOverlap(qMin, qMax, from, to))
			{
				// got one! let's look into it
				//
				//
											  
				if (q.stump)
				{
					/*
					Main.map.graphics.lineStyle(1, 0xFFFFFF, .1);
					Main.map.graphics.moveTo(q.framePos.x, q.framePos.y - q.frameRng);
					Main.map.graphics.lineTo(q.framePos.x, q.framePos.y + q.frameRng);
					Main.map.graphics.moveTo(q.framePos.x - q.frameRng, q.framePos.y);
					Main.map.graphics.lineTo(q.framePos.x + q.frameRng, q.framePos.y);
					*/
					//Main.map.graphics.drawRect(q.framePos.x - q.frameRng, q.framePos.y - q.frameRng, 
					//						   q.frameRng  +  q.frameRng, q.frameRng  +  q.frameRng);
					
					q.reticulate(); // worth-checking! go!
				}
				
				
				stack.add(q.tl);
				stack.add(q.tr);
				stack.add(q.bl);
				stack.add(q.br);
				
				continue;
			}
			
			
			// no intersect... lose it, it's empty
			
		}
		
		
		Main.map.graphics.lineStyle(2, 0xFF0000, 1);
		Main.map.graphics.moveTo(from.x, from.y);
		Main.map.graphics.lineTo(to.x,   to.y);
		
		
		
		surfRef.dump();
		surfRot.dump();
		qMin.dump();
		qMax.dump();
		
		if (!stack.isEmpty()) while (stack.pop() != null) { };
		

	}
	
	
	
	
	//
	//
	public static function quadWrite(main:Quad, output:ByteArray)
	{
		
		var stack:FastList<Quad> = new FastList<Quad>();
		var q:Quad = stack.first();
		
		//
		stack.add(main); // load up...
		
		
		output.clear(); // clear up!
		output.position = 0;
		
		// here's how we store the surface info - quads found with manifold info are listed here
		// so that after the serializing is done, their vector data can follow in the same order they were found
		// this should allow us to reverse the process later on without having to store location pointers....
		//
		var surfaceQuads:FastList<Quad> = new FastList<Quad>(); 
		
		
		
		while ((q = stack.pop()) != null)
		{
			
			//
			//
			
			
			if (q.stump)  // stump - we might have surface vectors!
			{
				//
				//
				
				if (q.block == 1) /// we have surface!
				{
					//
					
					output.writeByte(2);
					surfaceQuads.add(q);
					
					
				} else ///  just a plain dull quad... nothing to see here...
				{ 
					//
					
					
					output.writeByte(0); // dead end
					
				}
				
				
				
				
			} else   // not stump! - we have quad references to store
			{
				//
				
				output.writeByte(1);
				
				// stack up for recursion...
				// 
				stack.add(q.tl);
				stack.add(q.tr);
				stack.add(q.bl);
				stack.add(q.br);
			}
		} 
		
		// and now that all the quads are in, we can write down their vectors
		//
		 while ((q=surfaceQuads.pop()) != null)
		 {
			
			//
			output.writeDouble(q.manifoldFrom.x);
			output.writeDouble(q.manifoldFrom.y);
			
			output.writeDouble(q.manifoldTo.x);
			output.writeDouble(q.manifoldTo.y);
			
			output.writeDouble(q.manifoldNrml.x);
			output.writeDouble(q.manifoldNrml.y);
			output.writeDouble(q.manifoldLvl);
			
			output.writeUnsignedInt(q.idx);
			output.writeUnsignedInt(q.ids);
			//
			
			
		}
		
		//
		//output.position = 0; // reset pos...
		
	   if (!stack.isEmpty()) while (stack.pop() != null) { };
	   if (!surfaceQuads.isEmpty()) while (surfaceQuads.pop() != null) { };
		
		
		output.compress(); // this is so awesome! 10x size reduction  O.o
		
	}
	
	
	
	public static function quadLoad(main:Quad, input:ByteArray, surf:Vector<Quad>)
	{
		//
		var stack:FastList<Quad> = new FastList<Quad>();
		var q:Quad;
		
		
		
		if (!main.stump) main.collapse(); // just in case...
		
		
		//
		stack.add(main); // load up...
		
		//
		var surfaceQuads:FastList<Quad> = new FastList<Quad>(); 
		
		
		input.uncompress();
		input.position = 0;
		//
		
		
		
		
		while ((q = stack.pop()) != null) 
		{
			
			
			
			switch ( input.readByte() )
			{
				
				case 0: // dull quad, nothing to see here
						// don't need to do anything
					
				case 1:
					
					// loaded quad - we now reticulate!
					q.reticulate();
					/*
					
					// paint up so we can see what we're doing...
					Main.map.graphics.lineStyle(1, 0xFFFFFF, .1);
					Main.map.graphics.moveTo(q.framePos.x, q.framePos.y - q.frameRng);
					Main.map.graphics.lineTo(q.framePos.x, q.framePos.y + q.frameRng);
					Main.map.graphics.moveTo(q.framePos.x - q.frameRng, q.framePos.y);
					Main.map.graphics.lineTo(q.framePos.x + q.frameRng, q.framePos.y);
					
					*/
					//
					stack.add(q.tl);
					stack.add(q.tr);
					stack.add(q.bl);
					stack.add(q.br);
					q.block = 1;
				
				case 2:
				
					// surface quad, store for surface reconstruction
					surfaceQuads.add(q);
					q.block = 2;
				
			}
			
		}
		
		
		// alright, we're done setting up the quadtree, now we just gotta redefine their surface vectors...

		
		while ((q = surfaceQuads.pop()) != null) 
		{
			

			q.manifoldFrom = Vec2D.load();
			q.manifoldFrom.x = input.readDouble();
			q.manifoldFrom.y = input.readDouble();
			//
			
			q.manifoldTo = Vec2D.load();
			q.manifoldTo.x = input.readDouble();
			q.manifoldTo.y = input.readDouble();
			
			q.manifoldNrml = Vec2D.load();
			q.manifoldNrml.x = input.readDouble();
			q.manifoldNrml.y = input.readDouble();
			q.manifoldLvl    = input.readDouble();
			
			q.idx = input.readInt();
			q.ids = input.readInt();
			//
			
			surf.push(q);
			
		};
		
		
		surf.sort(function(q1:Quad, q2:Quad) 
		{ 
			return (q1.idx - q2.idx); 
		});
		
		
		if (!stack.isEmpty()) while (stack.pop() != null) { };
	    if (!surfaceQuads.isEmpty()) while (surfaceQuads.pop() != null) { };
		
	}
	
	
	
	
	
	public static inline function quadSurfaceClip(q:Quad)
	{
		/// here we do line clipping on the surfaces inside quads... 
		
		
		SimSpace.frameLineClip(q.manifoldFrom, q.manifoldTo, q.framePos, q.frameRng); // snip, snip, hurray!...
		//
		
		SimSpace.getClosestSegPoint(nrmlXsurf, q.framePos, q.manifoldFrom, q.manifoldTo);
		//
	
		q.manifoldRngL = Vec2D._getDistance(nrmlXsurf, q.manifoldFrom);
		q.manifoldRngR = Vec2D._getDistance(nrmlXsurf, q.manifoldTo);
		
		
		
		
	}
	//
	private static var nrmlXsurf:Vec2D = Type.createEmptyInstance(Vec2D);
	
}




