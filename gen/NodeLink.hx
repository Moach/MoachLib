/**
 * ...
 * @author Moach
 */

package gen;
import flash.Vector;

class NodeLink<T>
{
	//
	
	
	public var prev:NodeLink; // node above (towards head)
	public var next:NodeLink; // node below (away from head)
	
	
	public var obj:T;
	
	
	/**
	 * A rather minimalistic linked-list implementation consisting only of nodes...
	 * all operations, such as push, shift, splice must be done "manually"
	 * any object may be tied to a node via the 'obj' prop
	 * @param	_obj an object to bind to this node - for use with own logic
	 * @param	_p reference to the previous node in the chain
	 * @param	_n reference to the next node in the chain
	 * @param   _headNode -optional-  node to mark in headNodeDC as the head for this one's chain - default null to ignore
	 */
	public function new(_obj:T = null, _p:NodeLink = null, _n:NodeLink = null) 
	{
		//
		prev = _p; next = _n;
		
		if (_p != null) _p.next = this;
		if (_n != null) _n.prev = this;
		
		obj = _obj; 
	}
	
	//
	//
	//
	
	/** 
	 * attaches a node to the top of the "next" chain of "headnode" - overwriting the given headnode and returning the old one
	 * NOTE * usage of this function implies "next" as away from head and "prev" as back towards it
	 * 
	 * @param	_obj = null  an object to attach to the new node
	 * @param	_headNode = null  the node to replace as the head of the chain
	 * @return the new head node
	 */
	public static function attachHead(_obj = null, _headNode:NodeLink = null) : NodeLink
	{
		return _headNode = new NodeLink(_obj, null, _headNode);
	}
	
	
	
	
	/**
	 * use this to remove "collapse" a node from it's chain
	 * the two neighboring nodes will be linked directly, thus removing this one from the list
	 * optionally, use 'KillRef false' to preserve the obj prop (?)
	 */
	public function collapse(killRef:Bool=true)
	{
		if (prev != null) prev.next = next;
		if (next != null) next.prev = prev;
		
		if (killRef) obj = null;
		
		//
		// we're done here!
	}
	
	
	
	
	
	/**
	 * returns the first node to return true to the given function, starting from given stN
	 * will return null if nothing checks out...
	 *
	 * @param	stN the node to start searching from
	 * @param	fn the above mentioned function
		
	 * @return the first node to return true from the function, or null if none
	 */
	public static function getNodeByFn(stN:NodeLink, fn:T->Bool) : NodeLink
	{
		while (stN != null)
		{
			if (fn(stN)) return stN;
			stN = stN.next;
		}
		return null;
	}
	public static function getNodeByFn_obj(stN:NodeLink, fn:T->Bool) : NodeLink
	{
		while (stN != null)
		{
			if (fn(stN.obj)) return stN;
			stN = stN.next;
		}
		return null;
	}
	
	public static function getObjByFn(stN:NodeLink, fn:T->Bool) : T
	{
		while (stN != null)
		{
			if (fn(stN.obj)) return stN.obj;
			stN = stN.next;
		}
		return null;
	}
	
	
	/**
	 * pushes every node that returns true to the given function into the (optionally) given Vector
	 * starting from stN... nodes are pushed in the order they appear - an empty vector will be returned if no nodes
	 * return true, or the unchanged provided vector, if available
	 */
	public static function gatherNodesByFn(stN:NodeLink, fn:T->Bool, rsVct:Vector.<NodeLink> = null) : Vector.<NodeLink>
	{
		if (rsVct == null) rsVct = new Vector.<NodeLink>();
		//
		
		while (stN != null)
		{
			if ( fn(stN) ) rsVct.push(stN);
			stN = stN.next;
		}
		
		return rsVct;
	}
	
	public static function gatherNodesByFn_obj(stN:NodeLink, fn:T->Bool, rsVct:Vector.<NodeLink> = null) : Vector.<NodeLink>
	{
		if (rsVct == null) rsVct = new Vector.<NodeLink>();
		//
		
		while (stN != null)
		{
			if ( fn(stN.obj) ) rsVct.push(stN);
			stN = stN.next;
		}
		
		return rsVct;
	}
	
	
	/**
	 * iterates over all 'next' nodes from stN, running a function for each along the way --
	 * return RV_END_ITERATEFN to stop iterations from the given function
	 * @param	stN the node to start iterating from
	 * @param	fn the above mentioned function
	 */
	public static function iterateFn(stN:NodeLink, fn:T->Bool) : Void
	{
		while (stN != null)
		{
			if ( fn(stN) == RV_END_ITERATEFN ) return;
			stN = stN.next;
		}
	}
	
	public static function iterateFn_obj(stN:NodeLink, fn:T->Bool) : Void
	{
		while (stN != null)
		{
			if ( fn(stN.obj) == RV_END_ITERATEFN) return;
			stN = stN.next;
		}
	}
	
	public static inline var RV_END_ITERATEFN:Int = 0x01;
	
	/**
	 * deletes every node starting from stN
	 * @param	stN where to start hacking from
	 */
	public static function eraseAll(stN:NodeLink)
	{
		
		var nxN:NodeLink
		while (stN != null)
		{
			nxN = stN.next;
			stN.collapse();
			//
			stN = nxN;
		}
	}
	
	
}

