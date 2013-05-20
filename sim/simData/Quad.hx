/**
 * ...
 * @author Moach
 */

package sim.simData;
import flash.Vector;
import haxe.FastList;
import haxe.xml.Fast;
import sim.simElements.SimBlock;
import sim.simElements.SimObject;
import sim.simData.SimDefs;
import sim.simData.SimNode;
import sim.simElements.SimRig;


//typedef QuadSector = UInt;


class Quad
{
	
	public var up:Quad;
	
	public var tl:Quad;
	public var tr:Quad;
	public var bl:Quad;
	public var br:Quad;
	
	// flash is processor-heavy - and memory is cheap, so it's probably best to store quad info rather than calculate it when needed...
	//  however simple doing that may be... i'd expect any simulation will most likely abuse quad-traversing routines quite heavily, so why not?...
	
	
	// ... noteworty is that whenever i refer to quads as "frames", we're assuming a center-of-quad reference point, rather than a top-left
	//    thus, the naming of "frame" is more about the partitioning of the quad space than the "quad" hierarchy itself
	
	
	public var stump:Bool; // if i'm found on, then this is the bottomost node in this branch of the quadtree
	
	public var framePos:Vec2D; // position of the quad's center in global space
	public var frameRng:Float; // half-size of quad in global scale at current depth
	
	public var block:Int;     // 0 = nothing, 1 = some quads have things, 2 = fully blocked 
	public var manifold:UInt; // 0 = no manifold whatsoever, 1~16 binary flags mark manifold-loaded sectors - all flags up means we have a surface here!
	//
	//public var manifoldXFrm:RotMatrix; // rot matrix for surface coords at this quad
	//public var manifoldSurf:Float;     // manifold surface height (along transformed "up" axis) 
	public var manifoldFrom:Vec2D;       // manifold surface "from" vector
	public var manifoldTo:Vec2D;         // manifold surface "to" vector
	
	public var manifoldLvl:Float;        // manifold surface distance from frame pos
	public var manifoldNrml:Vec2D;       // manifold surface normal vector
	public var manifoldRngL:Float;       // manifold surface range left of normal
	public var manifoldRngR:Float;       // manifold surface range right of normal
	
	//
	public var boundObjects:SimNode<SimObject>; // sim-objects registered at this quad...
	public var boundRigs:SimNode<SimRig>;       // sim-rigs with proxy registered at this quad...
	public var boundBlocks:SimNode<SimBlock>;   // sim-blocks registered at this quad...
	
	//
	public var userData:Dynamic; // whatever suits your fancy
	
	
	
	public var stackLevel:Int; // stack depth level for this quad...
	public var stackIndex:Int; // marker for this quad's location in the parents frame
	//
	public var stackControl:Int; // for general purpose stack traversal usage... 
	
	
	
	public var idx:UInt; // general quad ID (always unique)
	public var ids:UInt; // surface section id (used on save/load - can be repeated for coplanar quads)
	//
	
	var loaded:Bool;
	
	//
	public static function load() : Quad
	{
		//
		var loadQuad:Quad = SimDataPools.quadPool.load();
		//if (loadQuad.loaded) trace ("FUCK");
		
		// set stuffs on load...
		//
		loadQuad.stump    = true;
		loadQuad.framePos = Vec2D.load();
		loadQuad.manifold = 0;
		loadQuad.frameRng = 0;
		loadQuad.block    = 0;
		loadQuad.idx      = 0;
		loadQuad.ids      = 0;
		loadQuad.loaded   = true;
		
		return loadQuad;
	}
	 
	public inline function dump()
	{
		//if (manifoldXFrm != null) manifoldXFrm.dump();
		framePos.dump();
		userData = null;
		
		if (manifold > 0)
		{
			manifoldFrom.dump();
			  manifoldTo.dump();
			manifoldNrml.dump();
		}
		
		loaded = false;
		//
		SimDataPools.quadPool.unload(this);
	}
	
	
	
	
	/**
	 * returns the quad at the sector containing "pos" - if this is a stump, reticulation will ensue - use "select" to avoid that
	 * @param	pos
	 */
	public inline function refine(pos:Vec2D) : Quad
	{
		
		if (stump) reticulate(); // make more quads if needed
		
		
		// upper / lower
		if (pos.y < framePos.y)
		{
			// left / right
			if (pos.x < framePos.x)
			{
				return tl;
			} else
			{
				return tr;
				
			}
		} else
		{
			if (pos.x < framePos.x)
			{
				return bl;
			} else
			{
				return br;
			}
		}
	}
	
	/**
	 * same as above... but doesn't refine if quad not found... returns null instead (and leaves outRef unchanged)
	 **/
	public inline function select(pos:Vec2D) : Quad
	{
		if (stump) return null;
		
		
		// upper / lower
		if (pos.y < framePos.y)
		{
			// left / right
			if (pos.x < framePos.x)
			{
				return tl;
			} else
			{
				return tr;
				
			}
		} else
		{
			if (pos.x < framePos.x)
			{
				return bl;
			} else
			{
				return br;
			}
		}
		
	}
	
	
	/**
	 * makes a leaf quad into a branch, by allocating the four next quads under it - works very well with splines too, if you know what i mean ;)
	 * returns false if the quad is not a leaf, and therefore needs not be reticulated
	 */
	public function reticulate() : Bool
	{
		if (!stump) return false;
		

			// load up our quads...
			tl = Quad.load();
			tr = Quad.load();
			bl = Quad.load();
			br = Quad.load();
		
		
		
		// set their parents up straight
		tl.up = tr.up = bl.up = br.up = this;
		
		tl.stackLevel = tr.stackLevel = bl.stackLevel = br.stackLevel = (this.stackLevel + 1);
		
		tl.stackIndex = 1;
		tr.stackIndex = 2;
		bl.stackIndex = 4;
		br.stackIndex = 8;
		
		
		// assign the new frame-pos stuff to our four quads
		//
		var rtcFrameRange:Float = this.frameRng * .5; // half of current frame range
		

		Vec2D._add(tl.framePos, framePos, Vec2D.scratch( -rtcFrameRange, -rtcFrameRange));
		tl.frameRng = rtcFrameRange;
		
		
		Vec2D._add(tr.framePos, framePos, Vec2D.scratch(  rtcFrameRange, -rtcFrameRange));
		tr.frameRng = rtcFrameRange;
		

		Vec2D._add(bl.framePos, framePos, Vec2D.scratch( -rtcFrameRange,  rtcFrameRange));
		bl.frameRng = rtcFrameRange;
		

		Vec2D._add(br.framePos, framePos, Vec2D.scratch(  rtcFrameRange,  rtcFrameRange));
		br.frameRng = rtcFrameRange;
		
		
		stump = false; // a stump no more
		
		return true;
	}
	
	
	/**
	 * recursively deletes all quads below this one (doesn't affect this, though)
	 */
	public inline function collapse()
	{
		if (!stump)
		{
			//
			var killStack:FastList<Quad> = new FastList<Quad>();
			var killQuad:Quad;
			//
			
			killStack.add(tl);
			killStack.add(tr);
			killStack.add(bl);
			killStack.add(br);
			
			while ((killQuad = killStack.pop()) != null)
			{
				
				if (killQuad.stump)
				{
					killQuad.dump();
					continue;
				}
				
				
				killStack.add(killQuad.tl);
				killStack.add(killQuad.tr);
				killStack.add(killQuad.bl);
				killStack.add(killQuad.br);
				
				killQuad.stump = true;
				
				killQuad.tl = killQuad.tr = killQuad.bl = killQuad.br = killQuad.up = null;
				killQuad.dump();
			}
			
			
			
			tl = tr = bl = br = null; // be gone!
			
			stump = true;
		}
	}
	
	
	
	/**
	 * ruthlessly deletes everything below this quad, then the quad itself - also recycles the current object back to the pool
	 */
	public function rcDelete()
	{
		// often causes stack-overflow... flash stack is sooooo tiny...
		
		
		if (stump) {
			
			up = null;
			dump();
			return;
		}
		
		
		
		tl.rcDelete();
		tr.rcDelete();
		bl.rcDelete();
		br.rcDelete();
		
		tl.dump();
		tr.dump();
		bl.dump();
		br.dump();
		
		tl = tr = bl = br = up = null; // be dead - kill "up" as well!
		
		//
		dump(); // ...dump self
	}
	
}






