/**
 * ...
 * @author Moach
 */

package gen;


class Pool<T>
{
	
	
	private var _typeClass:Class<T>;
	
	private var _initSize:Int;
	private var _currSize:Int;
	//private var _usageCount:Int;
	
	private var _useCount:Int;
	private var _rdyCount:Int;
	
	private var _grow:Bool;
	/*
	private var _poolHead:ObjNode<T>;
	private var _poolTail:ObjNode<T>;
	
	private var _returnNode:ObjNode<T>;
	private var _allocNode:ObjNode<T>;
	*/
	//
	//
	
	private var  _inPool:ObjNode<T>; // nodes in pool, and ready for picking
	private var _outPool:ObjNode<T>; // nodes out of pool and in use...
	
	
	/**
	 * Creates a new object pool.
	 * 
	 * @param grow If true, the pool grows the first time it becomes empty.
	 */
	public function new(type:Class<T>, ?grow:Bool = true)
	{
		_typeClass = type;
		_grow = grow;
		
		patchSizeFixed = true;
	}
	
	
	
	/**
	 * The pool size.
	 */
	public inline function getSize():UInt
	{
		return _currSize;
	}
	
	/**
	 * The total number of 'checked out' objects currently in use.
	 */
	public inline function getUseCount():UInt
	{
		return _useCount;
	}
	
	/**
	 * The total number of unused thus wasted objects. Use the purge()
	 * method to compact the pool.
	 * 
	 * @see #purge
	 */
	public inline function getReadyCount():UInt
	{
		return _rdyCount;	
	}
	
	
	
	public var patchSize:Int; // the amount to increase upon each load..... defaults to size of initial alloc
	public var patchSizeFixed:Bool; // defines whether patchSize is to be used on grows, or if pool grows exponentially (defaults true)
	
	
	
	/**
	 * Allocate the pool by creating all objects from the given class.
	 * 
	 * @param C    The class to instantiate for each object in the pool.
	 * @param size The number of objects to create.
	 */
	public function allocate(size:UInt):Void
	{
		_currSize = 1;
		_initSize = patchSize = size;
		
		
		_inPool = new ObjNode<T>();
		_inPool.data = Type.createEmptyInstance(_typeClass);
		
		
		var newNode:ObjNode<T>;
		//
		while (++_currSize < _initSize)
		{
			newNode = new ObjNode<T>();
			newNode.data = Type.createEmptyInstance(_typeClass);
			
			newNode.next = _inPool;
			_inPool = newNode;
		}
		
		_rdyCount = size;
		_useCount = 0;
		
		
		/*clear();
		_initSize = _currSize = size;
		
		_poolHead = _poolTail = new ObjNode<T>();
		_poolHead.data = Type.createEmptyInstance(_typeClass);
		
		var n:ObjNode<T>;
		var i:Int = 1;
		while( ++i < _initSize)
		{
			n = new ObjNode<T>();
			n.data = Type.createEmptyInstance(_typeClass);
			n.next = _poolHead;
			_poolHead = n;
		}
		
		_returnNode = _allocNode = _poolHead;
		_poolTail.next = _poolHead;*/
	}
	
	
	/**
	 * Helper method for applying a function to all objects in the pool.
	 * 
	 * @param func The function's name.
	 * @param args The function's arguments.
	 */
	public function initialize(fn:Dynamic, args:Array<Dynamic>):Void
	{
		var n:ObjNode<T> = _inPool;
		while (n != null)
		{
			Reflect.callMethod(n.data, fn, args);
			if (n == _inPool) break;
			n = n.next;	
		}
	}
	
	
	
	
	
	/**
	 * Unlock all ressources for the garbage collector.
	 */
	/*
	public function clear():Void
	{
		var node:ObjNode<T> = _inPool;
		
		/*
		
		var t:ObjNode<T>;
		while (node != null)
		{
			t = node.next;
			node.next = null;
			node.data = null;
			node = t;
		}
		
		_poolHead = _poolTail = _returnNode = _allocNode = null;
	}
	
	*/
	
	
	
	
	
	/**
	 * Get the next available object from the pool or put it back for the
	 * next use. If the pool is empty and resizable, an error is thrown.
	 */
	public function load():T
	{	
		
		if (_inPool != null) /// ready to load...
		{
			--_rdyCount; // one out
			++_useCount;
			
			var loadNode:ObjNode<T> = _inPool; // pick.... 
			var loadObj:T = loadNode.data;
			
			_inPool = _inPool.next; // remove from stack / put next one up...
			
			loadNode.data = null; // clear obj reference... objects need not be returned to their same node
			loadNode.next = _outPool; // put this one atop the outPool stack		
			_outPool = loadNode;
			return loadObj; // it's out
			
		} else
		{
			if (!_grow) throw "POOL FAULT -- LOAD OBJECTS DEPLETED";
			
			/// we need more nodes, cap'n!!
			var newNode:ObjNode<T>;
			//
			
			if (patchSizeFixed)
			{
				_rdyCount += patchSize;
				_initSize += patchSize;
				
			} else
			{
				_rdyCount += _initSize; 
				_initSize += _initSize; // double up!
			}
			
			//trace (" EXPANDING POOL :: " + _typeClass + " | from: " + _currSize + ", to: " + _initSize);
			
			while (++_currSize < _initSize)
			{
				newNode = new ObjNode<T>();
				newNode.data = Type.createEmptyInstance(_typeClass);
				
				//
				newNode.next = _inPool;
				_inPool = newNode;
			}
			
			// alright, load up now
			return load();
			
		}
		
		/*if (_usageCount >= _currSize)
		{
			if (_grow)
			{
				_currSize += _initSize;
				
				trace("expanding pool :: " + _typeClass + " new size: " + _currSize);
				
				var oldTail:ObjNode<T> = _poolTail;
				var newTail:ObjNode<T> = _poolTail;
				
				var node:ObjNode<T>;
				var i:Int = 0;
				
				while ( ++i <= _initSize )
				{
					node = new ObjNode<T>();
					node.data = Type.createEmptyInstance(_typeClass);
					
					newTail.next = node;
					newTail = node; 
				}
				
				_poolTail = newTail;
				_poolTail.next = _poolHead;
				
				
				_allocNode = oldTail.next;
				
				
				return load();
				/*
				var o:T = _allocNode.data;
				//_allocNode.data = null;
				_allocNode = _allocNode.next;
				_usageCount++;
				return o;
			}
			else
			{
				trace(_typeClass + " :: pool exhausted!");
				throw "object pool exhausted";
				//
			}
		}
		else
		{
			var o:T = _allocNode.data;
			//_allocNode.data = null;
			_allocNode = _allocNode.next;
			_usageCount++;
			return o;
		}*/
	}
	
	//
	//
	public function unload(o:T):Void
	{
		if (o == null) throw "POOL FAULT -- UNLOADED NULL REFERENCE";
		if (_useCount <= 0) throw "POOL FAULT -- EXCESS OBJECTS UNLOADED";
		
		--_useCount;
		++_rdyCount;
		
		var rtNode:ObjNode<T> = _outPool; // pick from outted objects.... 
		_outPool = _outPool.next; // move up the line..
	
		rtNode.data = o; // return
		rtNode.next = _inPool;
		_inPool = rtNode;  
		
		// and it's back...
		
		/*if (_usageCount > 0)
		{
			_usageCount--;
			_returnNode.data = o;
			_returnNode = _returnNode.next;
		}*/
	}
	
	
	/**
	 * Remove all unused objects from the pool. If the number of remaining
	 * used objects is smaller than the initial capacity defined by the
	 * allocate() method, new objects are created to refill the pool. 
	 *//*
	
	public function trim( maxSize:Int ):Void
	{
		
		var i:Int = 0;
		var node:ObjNode<T>;
		
		if (_usageCount == 0)
		{
			if (_currSize == _initSize)
				return;
				
			if (_currSize > _initSize)
			{
				i = 0; 
				node = _poolHead;
				while (++i < _initSize)
					node = node.next;	
				
				_poolTail = node;
				_allocNode = _returnNode = _poolHead;
				
				_currSize = _initSize;
				return;	
			}
		}
		else
		{
			var a:Array<ObjNode<T>> = [];
			node =_poolHead;
			while (node != null)
			{
				if (node.data == null) a[++i] = node;
				if (node == _poolTail) break;
				node = node.next;	
			}
			
			_currSize = a.length;
			_usageCount = _currSize;
			
			_poolHead = _poolTail = a[0];
			
			i = 1;
			while ( ++i < _currSize)
			{
				node = a[i];
				node.next = _poolHead;
				_poolHead = node;
			}
			
			_returnNode = _allocNode = _poolHead;
			_poolTail.next = _poolHead;
			
			if (_usageCount < _initSize)
			{
				_currSize = _initSize;
				
				var n:ObjNode<T> = _poolTail;
				var t:ObjNode<T> = _poolTail;
				var k:Int = _initSize - _usageCount;
				
				i = 0;
				while ( ++i < k)
				{
					node = new ObjNode<T>();
					node.data = Type.createEmptyInstance(_typeClass);
					t.next = node;
					t = node; 
				}
				
				_poolTail = t;
				
				_poolTail.next = _returnNode = _poolHead;
				_allocNode = n.next;
				
			}
		
		}
	}
	*/
	
	
}


private class ObjNode<T>
{
	public function new() { }
	public var next:ObjNode<T>;
	
	public var data:T;
}



