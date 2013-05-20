/**
 * ...
 * @author Moach
 */

package gen;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.TypedDictionary;

using StringTools;

class CFG
{
	
	public var vars:TypedDictionary<String, String>;
	
	
	public function new() 
	{
		
		vars = new TypedDictionary<String, String>(false);
	}
	

	public function load(file:String)
	{
		var rq:URLRequest = new URLRequest(file);
		var ldr:URLLoader = new URLLoader();
		var hndlr:Event->Void = function (e:Event)
		{
			ldr.removeEventListener(Event.COMPLETE, hndlr);
			//
			
			var cfgStr:String = cast e.target.data;
			parse(cfgStr);
		}
		
		ldr.addEventListener(Event.COMPLETE, hndlr);
		ldr.load(rq);
	}
		
	
	public function dump()
	{
		for (k in vars.keys()) { vars.delete(k); }
		vars = null;
	}
	
	function parse(cfgStr:String)
	{
		//
		var cfgLines:Array<String> = cfgStr.split('\n');
		for (line in cfgLines)
		{
			if (line.startsWith(';')) continue; // comment... don't even bother
			if (line.startsWith('[')) continue; // section tag... treat as comment
			//
			if (line.length < 2) continue; // what could there be in less chars than that?
			
			
			
			//
			var entry:String = line.split(';')[0]; // whatever else past that is just comment... ignore
			if (entry.length < 1) continue; // nothing to see here...
			
			var entryData:Array<String> = entry.split('=');
			
			var entryKey:String = entryData[0].trim();
			var entryVal:String = entryData[1].trim();
			
		}
		
	}
	
	
}