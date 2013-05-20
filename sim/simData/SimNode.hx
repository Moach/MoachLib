/**
 * ...
 * @author Moach
 */

package sim.simData;
import flash.Vector;
import sim.simData.SimDefs;




class SimNodeIterator<T> 
{
	
	
	public var head:SimNode<T>;
	public var ct:SimNode<T>;
	
	public function new(?headNode:SimNode<T> = null)
	{
		ct = head = headNode;
		
	}
	
	//
	//
	
	public inline function clear()
	{
		ct = head = null;
	}
	
	public inline function toStart()
	{
		ct = head;
	}
	
	public inline function toHead(setHead:SimNode<T>)
	{
		ct = head = setHead;
	}
	
	
	
	public function next() : SimNode<T>
	{
		
		var rct:SimNode<T> = ct;
		ct = ct.next;
		return rct;
	}
	
	public function hasNext() : Bool
	{
		return (ct != null);
	}
	
}

/**
 * specialized version of the NodeLink class for work with the simulator's pooling system
 */
class SimNode<T>
{

	public var prev:SimNode<T>;
	public var next:SimNode<T>;
	
	public var ref:T;
	
	
	public function new(objRef:T)
	{
		ref = objRef;
		//
	}
	
	
	
	/** 
	 * attaches a node to the top of the "next" chain of "headnode" - overwriting the given headnode and returning the old one
	 * NOTE * usage of this function implies "next" as away from head and "prev" as back towards it
	 * 
	 * @param	_obj = null  an object to attach to the new node
	 * @param	_headNode = null  the node to replace as the head of the chain
	 * @return the new head node
	 */
	
	public static inline function attachHead<T>(_nd:SimNode<T>, _headNode:SimNode<T> = null) : SimNode<T>
	{
		_nd.next = _headNode;
		_headNode.prev = _nd;
		return _headNode = _nd;
	}
	
	
	/**
	 * opposite of the above, works the same, but for the other end of the line
	 * @param	_nd
	 * @param	_tailNode
	 * @return
	 */
	public static inline function attachTail<T>(_nd:SimNode<T>, _tailNode:SimNode<T>) : SimNode<T>
	{
		_nd.prev = _tailNode;
		_tailNode.next = _nd;
		return _tailNode = _nd;
	}
	
	
	
	/*
	public static inline function buildFromArray<t>( _nodes:Array )
	{
		//
		
		
		
	}
	
	*/
	
	
	
	
	/**
	 * use this to remove "collapse" a node from it's chain
	 * the two neighboring nodes will be linked directly, thus removing this one from the list
	 */
	public static inline function collapse<T>(_nd:SimNode<T>) : Void
	{
		if (_nd.prev != null) _nd.prev.next = _nd.next;
		if (_nd.next != null) _nd.next.prev = _nd.prev;
	}
	
	
	
	
	/**
	 * Collapse Extended REPLACE-SAFE :: same as "collapse" - removes a node from the chain... 
	 * 
	 * but can also check if the collapsing node is the same as one that is required to never be cleared (like the headnode or whatever...)
	 * after collapsing, if the victim and the safeNode are the same, this will return the node that shall replace it (next),
	 * otherwise, returs the same safeNode unchanged
	 * 
	 * use with assignment to the safeNode to ensure your reference is not lost :)
	 * 
	 * @param	_nd collapse this
	 * @param	_safeNode replace this if it gets collapsed
	 * @return the safe node, if unaffected, or it's replacement if otherwise
	 */
	public static inline function collapseXR<T>(_nd:SimNode<T>, ?_safeNode:SimNode<T> = null) : SimNode<T>
	{
		if (_nd.prev != null) _nd.prev.next = _nd.next;
		if (_nd.next != null) _nd.next.prev = _nd.prev;
		
		// if this was the safe node - return the node that should take it's place, otherwise, return it unchanged
		return (_nd == _safeNode)? _safeNode.next : _safeNode;
	}
	
	
	
	
	
	/*
	 * returns the first node to return true to the given function, starting from given stN
	 * will return null if nothing checks out...
	 *
	 * @param	stN the node to start searching from
	 * @param	fn the above mentioned function
		
	 * @return the first node to return true from the function, or null if none
	 *
	public static function getNodeByFn(stN:ISimNodeType, fn:ISimNodeType->Bool) : ISimNodeType
	{
		while (stN != null)
		{
			if (fn(stN)) return stN;
			stN = stN.next;
		}
		return null;
	}
	
	
	
	/**
	 * pushes every node that returns true to the given function into the (optionally) given Vector
	 * starting from stN... nodes are pushed in the order they appear - an empty vector will be returned if no nodes
	 * return true, or the unchanged provided vector, if available
	 *
	public static function gatherNodesByFn(stN:ISimNodeType, fn:ISimNodeType->Bool, outVec:Vector<ISimNodeType>) : Vector<ISimNodeType>
	{
		//if (rsVct == null) rsVct = new Vector<ISimNodeType>();
		//
		
		while (stN != null)
		{
			if ( fn(stN) ) outVec.push(stN);
			stN = stN.next;
		}
		
		return outVec;
	}
	
	
	
	/**
	 * iterates over all 'next' nodes from stN, running a function for each along the way --
	 * return RV_END_ITERATEFN to stop iterations from the given function
	 * @param	stN the node to start iterating from
	 * @param	fn the above mentioned function
	 *
	public static inline function iterateFn(stN:ISimNodeType, fn:ISimNodeType->Void) : Void
	{
		while (stN != null)
		{
			fn(stN);
			stN = stN.next;
		}
	}
	
	/*
	public static inline function iterate<FN>(stN:ISimNodeType)
	{
		while (stN != null)
		{
			FN(stN);
			stN = stN.next;
		}
	}
	*/
	
	
	/**
	 * deletes every node starting from stN
	 * @param	stN where to start hacking from
	 */
	public static inline function eraseAll<T>(stN:SimNode<T>)
	{
		
		var nxN:SimNode<T>;
		while (stN != null)
		{
			nxN = stN.next;
			collapse(stN);
			//
			stN = nxN;
		}
	}
	
	
}