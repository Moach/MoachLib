/**
 * ...
 * @author Moach
 */

package sim.simDynamix.utilitix;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.utils.TypedDictionary;
import flash.Vector;
import sim.simData.SimNode;
import sim.simData.Vec2D;

class VTrace 
{

	public var mClip:MovieClip;
	public var rndr:Graphics;
	
	public static var def:VTrace;
	
	
	private var mkrs:Vector<TraceMarker>;
	
	
	private var keyRefs:TypedDictionary<Dynamic, TraceMarker>;
	private var preLoadedMkr:TraceMarker;
	
	//
	public function new(_tgt:MovieClip) 
	{
		mClip = _tgt;
		rndr  = _tgt.graphics;
		//
		
		mkrs = new Vector<TraceMarker>();
		keyRefs = new TypedDictionary<Dynamic, TraceMarker>(true);
	}
	
	public function dump()
	{
		preLoadedMkr = null;
		keyRefs  = null;
		mkrs  = null;
		mClip = null;
		rndr  = null;
	}
	
	
	

	
	public function renderFrame()
	{
		rndr.clear();
		
		//
		var i:UInt = 0;
		while (i < mkrs.length)
		{
			var mkr:TraceMarker = mkrs[i];
			//
			mkr.draw(rndr); // draw it!
			
			mkr.mkrTime++;
			mkr.mkrAlpha = Math.min( 1.0, 1.0 - ((mkr.mkrTime-mkr.mkrFade) / (mkr.mkrTmax - mkr.mkrFade)) );
			//
			if (mkr.mkrAlpha <= 0.0)
			{
				// clear marker
				mkrs.splice(i, 1);
				keyRefs.delete(mkr.keyRef);
				mkr.keyRef = null; // just in case...
				//
			} else ++i;
		}
	}
	
	
	
	/**
	 *  the following horrible kludge is to workaround not having function overloads.... 
	 *   so instead of calling the same function with a different set of arguments, this ungodlyness can be chained in before the actuall function
	 *   providing a rather uncanny manner of flexible-arguments functionality....
	*/
	
	public function useMarkerRef(key:Dynamic) : VTrace // returns self to allow chaining syntax
	{
		if (keyRefs.exists(key))
		{
			preLoadedMkr = keyRefs.get(key);
		}
		else
		{
			preLoadedMkr = new TraceMarker(Vec2D.scratch(0,0));
			preLoadedMkr.keyRef = key;
			keyRefs.set(key, preLoadedMkr);
			mkrs.push(preLoadedMkr);
		}
		
		usePreloadMkr = true;
		
		//
		return this;
	}
	//
	
	private var usePreloadMkr:Bool;
	//	
	private inline function setMarker(pos:Vec2D, ?type:UInt = 0, ?size:Float = 25.0) : TraceMarker
	{
		var newMkr:TraceMarker;
		if (usePreloadMkr)
		{ 
			newMkr = preLoadedMkr;
			preLoadedMkr = null; 
			newMkr.mkrTime = 0.0; // reset time and reuse exsiting markers....
			newMkr.mkrPosX = pos.x;
			newMkr.mkrPosY = pos.y;
			newMkr.mkrSize = size;
			newMkr.mkrType = type;
		} else
		{
			newMkr = new TraceMarker(pos, type, size);
			mkrs.push(newMkr); // or, just use new ones...
		}
		
		usePreloadMkr = false;
		return newMkr;
	}
	
	
	
	
	
	public function setPointMarker(vPos:Vec2D, ?clr:UInt = 0xFF0000, ?size:UInt = 5, ?px:Float = 1.0)
	{
		var mkr:TraceMarker = setMarker(vPos, 0, size);
			mkr.mkrColor = clr;
			mkr.mkrThick = px;
	}
	
	
	
	public function setLineToMarker(vPos:Vec2D, vTgt:Vec2D, ?clr:UInt = 0x00FF00, ?size:UInt = 5, ?px:Float = 1.0)
	{
		var mkr:TraceMarker = setMarker(vPos, 1, size);
			mkr.mkrDirX = vTgt.x;
			mkr.mkrDirY = vTgt.y;
			mkr.mkrColor = clr;
			mkr.mkrThick = px;
	}
	
	public function setRadiusMarker(vPos:Vec2D,  rad:Float, ?clr:UInt = 0xFF0000, ?px:Float = 1.0)
	{
		var mkr:TraceMarker = setMarker(vPos, 2, rad);
			mkr.mkrColor = clr;
			mkr.mkrThick = px;
	}
	
	public function setNrmlPlaneMarker(vPos:Vec2D,  nrml:Vec2D, ?size:Float = 25.0, ?clr:UInt = 0xFF0000, ?px:Float = 1.0)
	{
		var mkr:TraceMarker = setMarker(vPos, 3, size);
			mkr.mkrDirX = -nrml.y;
			mkr.mkrDirY =  nrml.x;
			mkr.mkrColor = clr;
			mkr.mkrThick = px;
	}
	
	public function setLineDirMarker(vPos:Vec2D, vDir:Vec2D, ?clr:UInt = 0x00FF00, ?size:UInt = 5, ?px:Float = 1.0)
	{
		var mkr:TraceMarker = setMarker(vPos, 4, size);
			mkr.mkrDirX = vDir.x;
			mkr.mkrDirY = vDir.y;
			mkr.mkrColor = clr;
			mkr.mkrThick = px;
	}
	
	
}

class TraceMarker
{
	
	public var mkrType:UInt;
	public var mkrTime:Float;
	public var mkrTmax:Float;
	public var mkrFade:Float;
	
	public var mkrColor:UInt;
	public var mkrThick:Float;
	public var mkrAlpha:Float;
	
	public var mkrSize:Float;
	public var mkrAngle:Float;
	
	public var mkrPosX:Float;
	public var mkrPosY:Float;
	public var mkrDirX:Float;
	public var mkrDirY:Float;
	
	public var keyRef:Dynamic;
	
	
	public function new(pos:Vec2D, ?type:UInt = 0, ?size:Float = 25.0)
	{	
		
		mkrType = type;
		mkrTime = 0.0;
		mkrTmax = 100.0;
		mkrFade = 35.0;
		
		mkrPosX = pos.x;
		mkrPosY = pos.y;
		
		mkrColor = 0xFF0000;
		mkrThick = 2.0;
		mkrAlpha = 1.0;
		
		mkrSize = size;
		
	}
	
	
	public function draw(rndr:Graphics)
	{
		//
		rndr.lineStyle(mkrThick, mkrColor, mkrAlpha); 
		
		switch (mkrType)
		{
			case 0:  /// default "crosshair" marker
			
			rndr.moveTo(mkrPosX - mkrSize, mkrPosY); rndr.lineTo(mkrPosX + mkrSize, mkrPosY);
			rndr.moveTo(mkrPosX, mkrPosY - mkrSize); rndr.lineTo(mkrPosX, mkrPosY + mkrSize);
			
			
			case 1: /// line pos-tgt marker
			
			rndr.moveTo(mkrPosX, mkrPosY); rndr.lineTo(mkrDirX, mkrDirY);
			rndr.drawCircle(mkrPosX, mkrPosY, mkrSize);
			
			
			case 2: /// radius circle marker

			rndr.drawCircle(mkrPosX, mkrPosY, mkrSize);
			
			
			case 3: /// normal surface plane (tangent line)
			
			rndr.moveTo(mkrPosX - mkrSize * mkrDirX, mkrPosY - mkrSize * mkrDirY); 
			rndr.lineTo(mkrPosX + mkrSize * mkrDirX, mkrPosY + mkrSize * mkrDirY); 
			
			case 4: /// point and directionn line
			
			rndr.moveTo(mkrPosX, mkrPosY); rndr.lineTo(mkrPosX + mkrDirX, mkrPosY + mkrDirY);
			rndr.drawCircle(mkrPosX, mkrPosY, mkrSize);
		}
		
		
	}
	
	
}