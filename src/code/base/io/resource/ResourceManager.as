/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package base.io.resource
{
	import base.Main;
	import base.core.debug.Log;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.structures.IIterator;
	import com.hexagonstar.structures.queues.Queue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	
	public class ResourceManager extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		private var _helper:ResourceManagerHelper;
		private var _resourceProviders:Dictionary;
		private var _usePackages:Boolean;
		private var _bulkIDCount:uint;
		private var _waitingHandlers:Object;
		private var _referencedIDQueue:Queue;
		private var _resourceIndex:ResourceIndex;
		private var _stringIndex:StringIndex;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the Resource Manager. Called automatically in the InitApplicationCommand
		 * command.
		 * 
		 * @param main A reference to main.
		 * @param resourceBundle Optional class object that acts as a bundle of embedded resources.
		 */
		public function init(main:Main, resourceBundleClass:Class = null):void
		{
			dispose();
			
			_main = main;
			_bulkIDCount = 0;
			_waitingHandlers = {};
			_stringIndex = new StringIndex();
			_helper = new ResourceManagerHelper();
			_helper.init(resourceBundleClass);
		}
		
		
		/**
		 * Loads one or more resources either from the file system, from a packed resource
		 * file or from embedded files.
		 * 
		 * @param resourceIDs Can be one of the following: a string containing one resource
		 *        ID, an array with one or more resource IDs or a queue with one or more
		 *        resource IDs.
		 * @param completeHandler An optional callback handler that is called after all
		 *        resources have completed the load procedure, regardless if some or all
		 *        of them failed or succeeded to load.
		 * @param loadedHandler An optional callback handler that is called everytime a
		 *        resource has been loaded.
		 * @param failedHandler An optional callback handler that is called everytime a
		 *        resource failed to load.
		 * @param forceReload If true the resource manager will reload the resource
		 *        again from it's file, even if it already has been loaded or failed.
		 */
		public function load(resourceIDs:*, completeHandler:Function = null,
			loadedHandler:Function = null, failedHandler:Function = null,
			progressHandler:Function = null, forceReload:Boolean = false):void
		{
			if (resourceIDs == null) return;
			
			var items:Array = [];
			var n:int;
			
			if (resourceIDs is Queue)
			{
				var i:IIterator = Queue(resourceIDs).iterator;
				while (i.hasNext)
				{
					items.push(new ResourceBulkItem(i.next));
				}
			}
			else if (resourceIDs is Array)
			{
				var a:Array = resourceIDs;
				for (n = 0; n < a.length; n++)
				{
					items.push(new ResourceBulkItem(a[n]));
				}
			}
			else if (resourceIDs is String)
			{
				items.push(new ResourceBulkItem(resourceIDs));
			}
			else
			{
				return;
			}
			
			/* Create temporary bulks used to load one or more resources in one go. */
			var bulk1:ResourceBulk;
			var bulk2:ResourceBulk;
			var bulk3:ResourceBulk;
			
			var total:int = items.length;
			var done:int = 0;
			
			for (n = 0; n < total; n++)
			{
				var item:ResourceBulkItem = items[n];
				var r:Resource = _resourceIndex.getResource(item.resourceID);
				item.setResource(r);
				
				/* Check if a resource for the specified ID actually exists. */
				if (!r)
				{
					notifyFailed(item, failedHandler, "A resource with the ID \""
						+ item.resourceID + "\" does not exist in the resource index.");
					done++;
					continue;
				}
				
				/* If resource was loaded but we want to force a reload, reset the resource. */
				if (forceReload)
				{
					_resourceIndex.resetResource(r.id);
				}
				
				/* Resource has already been loaded. */
				if (r.status == ResourceStatus.LOADED)
				{
					Log.debug("Resource \"" + r.id + "\" has already been loaded.", this);
					r.increaseReferenceCount();
					notifyLoaded(item, loadedHandler);
					done++;
					continue;
				}
				
				/* Resource has failed to load before. Don't try again! */
				if (r.status == ResourceStatus.FAILED)
				{
					notifyFailed(item, failedHandler, "The resource with ID \"" + item.resourceID
						+ "\" has previously failed to load and is not being loaded again.");
					done++;
					continue;
				}
				
				/* Resource is currently loading, hook up to any listeners if we got them. */
				if (r.status == ResourceStatus.LOADING)
				{
					Log.debug("Resource \"" + r.id + "\" is already loading.", this);
					r.increaseReferenceCount();
					var vo:HandlerVO = new HandlerVO(completeHandler, loadedHandler, failedHandler,
						progressHandler);
					if (_waitingHandlers[r.id] == null) _waitingHandlers[r.id] = [];
					(_waitingHandlers[r.id] as Array).push(vo);
					continue;
				}
				
				/* Resource needs to be loaded so check from which provider we can get it. */
				if (r.status == ResourceStatus.INIT)
				{
					Log.debug("Loading resource \"" + r.id + "\".", this);
					r.setStatus(ResourceStatus.LOADING);
					if (r.embedded)
					{
						if (!bulk1)
						{
							bulk1 = new ResourceBulk(createBulkID(), getResourceProvider(
								EmbeddedResourceProvider.ID), loadedHandler, failedHandler,
								completeHandler, progressHandler);
						}
						bulk1.addItem(item);
					}
					else
					{
						if (_usePackages && r.packageID && r.packageID.length > 0)
						{
							if (!bulk2)
							{
								bulk2 = new ResourceBulk(createBulkID(), getResourceProvider(
									r.packageID), loadedHandler, failedHandler, completeHandler,
										progressHandler);
							}
							bulk2.addItem(item);
						}
						else
						{
							if (!bulk3)
							{
								bulk3 = new ResourceBulk(createBulkID(), getResourceProvider(
									LoadedResourceProvider.ID), loadedHandler, failedHandler,
									completeHandler, progressHandler);
							}
							bulk3.addItem(item);
						}
					}
				}
			}
			
			if (bulk1) bulk1.load();
			if (bulk2) bulk2.load();
			if (bulk3) bulk3.load();
			
			/* If all failed/already loaded it means none of them went through any resource
			 * provider but we still want the complete handler to be notified after that. */
			if (done == total)
			{
				notifyComplete(completeHandler);
			}
		}
		
		
		/**
		 * Unloads previously loaded resources. This does not necessarily mean the resource
		 * will be available for garbage collection. Resources are reference counted so if
		 * the specified resource has been loaded multiple times, its reference count will
		 * only decrease as a result of this.
		 * 
		 * @param resourceIDs IDs of the resources to unload.
		 * @return The resource's reference count.
		 */
		public function unload(resourceIDs:*):void
		{
			if (resourceIDs == null) return;
			
			var items:Array = [];
			var n:int;
			
			if (resourceIDs is Queue)
			{
				var i:IIterator = Queue(resourceIDs).iterator;
				while (i.hasNext)
				{
					items.push(i.next);
				}
			}
			else if (resourceIDs is Array)
			{
				items = resourceIDs;
			}
			else if (resourceIDs is String)
			{
				items.push(resourceIDs);
			}
			else
			{
				return;
			}
			
			for (n = 0; n < items.length; n++)
			{
				var id:String = items[n];
				var r:Resource = _resourceIndex.getResource(id);
				if (!r) continue;
				Log.debug("Unloading resource \"" + r.id + "\".", this);
				r.decreaseReferenceCount();
				if (r.referenceCount < 1)
				{
					/* If the to be removed resource is a text resource,
					 * also remove all of it's strings. */
					if (r.dataType == ResourceFamily.TEXT)
					{
						_stringIndex.removeStrings(r.content);
					}
					_resourceIndex.resetResource(id);
				}
			}
		}
		
		
		/**
		 * Forces an unload of all loaded resources.
		 */
		public function unloadAll():void
		{
			if (_stringIndex) _stringIndex.removeAll();
			if (_resourceIndex) _resourceIndex.resetAll();
		}
		
		
		/**
		 * Checks if a resource is loaded and ready to go.
		 * 
		 * @param resourceID
		 * @return true or false.
		 */
		public function isResourceLoaded(resourceID:String):Boolean
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return false;
			return r.status == ResourceStatus.LOADED;
		}
		
		
		/**
		 * Checks if a resource is currently in the process of being loaded.
		 * 
		 * @param resourceID
		 * @return true or false.
		 */
		public function isResourceLoading(resourceID:String):Boolean
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return false;
			return r.status == ResourceStatus.LOADING;
		}
		
		
		/**
		 * Returns the reference count of the resource with the specified ID.
		 * 
		 * @param resourceID
		 * @return reference count.
		 */
		public function getRefCountFor(resourceID:String):int
		{
			var r:Resource = _resourceIndex.getResource(resourceID);
			if (!r) return 0;
			return r.referenceCount;
		}
		
		
		/**
		 * Returns the resource provider that is used to provide the resource with the
		 * specified id. Embedded and loaded resources both use their own provider and
		 * are identified with either EmbeddedResourceProvider.ID or LoadedResourceProvider.ID
		 * but packed resources are identified by their package file ID since every package
		 * file needs to use it's own dedicated resource provider.
		 * 
		 * @param id
		 */
		public function getResourceProvider(id:String):IResourceProvider
		{
			return _resourceProviders[id];
		}
		
		
		/**
		 * dispose
		 */
		public function dispose():void 
		{
			unloadAll();
			_resourceIndex = null;
			_stringIndex = null;
		}
		
		
		/**
		 * Returns a String Representation of ResourceManager.
		 * 
		 * @return A String Representation of ResourceManager.
		 */
		override public function toString():String
		{
			return "ResourceManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The index of resources.
		 */
		public function get resourceIndex():ResourceIndex
		{
			return _resourceIndex;
		}
		
		
		/**
		 * The string index.
		 */
		public function get stringIndex():StringIndex
		{
			return _stringIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onResourceFileLoaded(bf:ResourceBulkFile):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				r.increaseReferenceCount();
				notifyLoaded(item, bf.bulk.loadedHandler);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyLoaded(item, HandlerVO(a[j]).loadedHandler);
					}
				}
			}
		}
		
		
		private function onResourceFileFailed(bf:ResourceBulkFile, message:String):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				notifyFailed(item, bf.bulk.failedHandler, message);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyFailed(item, HandlerVO(a[j]).failedHandler, message);
					}
				}
			}
		}
		
		
		private function onResourceBulkProgress(bf:ResourceBulkFile, progress:BulkProgress):void
		{
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				notifyProgress(bf.bulk.progressHandler, progress);
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					var a:Array = _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyProgress(HandlerVO(a[j]).progressHandler, progress);
					}
				}
			}
		}
		
		
		private function onResourceBulkLoaded(bf:ResourceBulkFile):void
		{
			var b:ResourceBulk = bf.bulk;
			var a:Array;
			
			/* We can decrease the bulk ID count anytime a bulk completed loading. */
			if (_bulkIDCount > 1) _bulkIDCount--;
			
			/* If we got queued referenced resources, load these before we finish. */
			if (_referencedIDQueue && _referencedIDQueue.size > 0)
			{
				a = [];
				while (_referencedIDQueue.size > 0)
				{
					a.push(_referencedIDQueue.dequeue());
				}
				Log.debug("Loading " + a.length + " referenced resources ...", this);
				load(a, b.completeHandler, b.loadedHandler, b.failedHandler, b.progressHandler);
				return;
			}
			
			_referencedIDQueue = null;
			notifyComplete(b.completeHandler);
			
			/* We still need to check if any of the bulk file's resource items has any
			 * waiting handlers assigned, call them and then remove the handlers. */
			for (var i:uint = 0; i < bf.items.length; i++)
			{
				var item:ResourceBulkItem = bf.items[i];
				var r:Resource = item.resource;
				
				/* Call any waiting handlers that might have been
				 * added while the resource was loading. */
				if (_waitingHandlers[r.id])
				{
					a = _waitingHandlers[r.id];
					_waitingHandlers[r.id] = null;
					delete _waitingHandlers[r.id];
					for (var j:uint = 0; j < a.length; j++)
					{
						notifyComplete(HandlerVO(a[j]).completeHandler);
					}
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param ids
		 */
		internal function enqueueReferencedResources(ids:Array):void
		{
			if (!_referencedIDQueue) _referencedIDQueue = new Queue();
			for (var i:uint = 0; i < ids.length; i++)
			{
				_referencedIDQueue.enqueue(ids[i]);
			}
		}
		
		
		/**
		 * Sends an event that the Resource Manager initialization has been completed.
		 */
		internal function completeInitialization():void
		{
			Log.debug("Ready!", this);
			completeInit();
		}
		
		
		/**
		 * Sends an event that the Resource Manager initialization has failed.
		 */
		internal function failInitialization():void
		{
			Log.error("Initialization failed!", this);
			completeInit();
		}
		
		
		private function completeInit():void
		{
			_usePackages = _helper._usePackages;
			_resourceProviders = _helper._resourceProviders;
			_resourceIndex = _helper._resourceIndex;
			_helper = null;
			for each (var p:IResourceProvider in _resourceProviders)
			{
				p.bulkProgressSignal.add(onResourceBulkProgress);
				p.fileFailedSignal.add(onResourceFileFailed);
				p.fileLoadedSignal.add(onResourceFileLoaded);
				p.bulkLoadedSignal.add(onResourceBulkLoaded);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function createBulkID():String
		{
			return "bulk" + (_bulkIDCount++);
		}
		
		
		/**
		 * @param progressHandler
		 * @param p
		 */
		private function notifyProgress(progressHandler:Function, p:BulkProgress):void
		{
			if (progressHandler != null) progressHandler(p);
		}
		
		
		/**
		 * @param item
		 * @param loadedHandler
		 */
		private function notifyLoaded(item:ResourceBulkItem, loadedHandler:Function):void
		{
			if (loadedHandler != null) loadedHandler(item.resource);
		}
		
		
		/**
		 * @param item
		 * @param failedHandler
		 */
		private function notifyFailed(item:ResourceBulkItem, failedHandler:Function,
			message:String):void
		{
			Log.error(message, this);
			if (failedHandler != null) failedHandler(item.resource);
		}
		
		
		/**
		 * @param completeHandler
		 */
		private function notifyComplete(completeHandler:Function):void
		{
			if (completeHandler != null) completeHandler();
		}
	}
}


/**
 * VO used for waiting handlers.
 */
final class HandlerVO
{
	public var completeHandler:Function;
	public var loadedHandler:Function;
	public var failedHandler:Function;
	public var progressHandler:Function;
	
	public function HandlerVO(ch:Function, lh:Function, fh:Function, ph:Function)
	{
		completeHandler = ch;
		loadedHandler = lh;
		failedHandler = fh;
		progressHandler = ph;
	}
}
