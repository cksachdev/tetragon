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
	import base.data.DataSupportManager;
	import base.data.parsers.IDataParser;
	import base.event.ResourceEvent;
	import base.io.resource.wrappers.ResourceWrapper;
	import base.io.resource.wrappers.XMLResourceWrapper;

	import com.hexagonstar.file.FileIOEvent;

	import flash.events.EventDispatcher;
	
	
	/**
	 * Abstract super class for resource providers.
	 */
	public class ResourceProvider extends EventDispatcher implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _resourceManager:ResourceManager;
		
		/**
		 * @private
		 */
		protected var _dsm:DataSupportManager;
		
		/**
		 * ID of the resource provider, if necessary (PackedResourceProvider needs it!)
		 * @private
		 */
		protected var _id:String;
		
		/**
		 * A map that stores ResourceBulkFile objects temporarily for loading, used to
		 * keep track of them in event handlers. Bulk files are mapped by their ID.
		 * @private
		 */
		protected var _bulkFiles:Object;
		
		/**
		 * Determines if a loader has completed loading all files.
		 * @private
		 */
		protected var _loaderComplete:Boolean;
		
		/**
		 * Determines if a bulk has completed processing.
		 * @private
		 */
		protected var _bulkComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceProvider(id:String = null)
		{
			_resourceManager = Main.instance.resourceManager;
			_dsm = Main.instance.dataSupportManager;
			_id = id;
			_bulkFiles = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function init(arg:* = null):Boolean
		{
			/* Abstract method! */
			return false;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function loadResourceBulk(bulk:ResourceBulk):void
		{
			for each (var bf:ResourceBulkFile in bulk.bulkFiles)
			{
				createWrapperFor(bf);
				if (bf.wrapper) addBulkFile(bf);
			}
			loadFiles();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_bulkFiles = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			/* Abstract method! */
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to the resource manager.
		 * @private
		 */
		protected function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onBulkFileLoaded(e:FileIOEvent):void
		{
			var bf:ResourceBulkFile = _bulkFiles[e.file.id];
			bf.wrapper.addEventListener(ResourceEvent.INIT_SUCCESS, onResourceInit);
			bf.wrapper.addEventListener(ResourceEvent.INIT_FAILED, onResourceInit);
			bf.wrapper.initialize();
		}
		
		
		/**
		 * @private
		 */
		protected function onBulkFileError(e:FileIOEvent):void
		{
			var bf:ResourceBulkFile = _bulkFiles[e.file.id];
			fail(bf, e.text);
		}
		
		
		/**
		 * @private
		 */
		protected function onBulkFileProgress(e:FileIOEvent):void
		{
			dispatchEvent(new ResourceEvent(ResourceEvent.BULK_PROGRESS,
				_bulkFiles[e.file.id], null, e.bytesLoaded, e.bytesTotal, e.percentLoaded));
		}
		
		
		/**
		 * @private
		 */
		protected function onResourceInit(e:ResourceEvent):void
		{
			var bf:ResourceBulkFile = e.bulkFile;
			bf.wrapper.removeEventListener(ResourceEvent.INIT_SUCCESS, onResourceInit);
			bf.wrapper.removeEventListener(ResourceEvent.INIT_FAILED, onResourceInit);
			
			if (e.type == ResourceEvent.INIT_FAILED) fail(bf, e.text);
			else processBulkFile(bf);
		}
		
		
		/**
		 * @private
		 */
		protected function onLoaderComplete(e:FileIOEvent):void
		{
			_loaderComplete = true;
			if (_bulkComplete) reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Tries to instantiate the resource wrapper class for the resource in the specified
		 * bulk file.
		 * 
		 * @private
		 */
		protected function createWrapperFor(bulkFile:ResourceBulkFile):void
		{
			var w:ResourceWrapper;
			var item:ResourceBulkItem = bulkFile.item;
			var clazz:Class = item.resource.wrapperClass;
			try
			{
				w = new clazz();
			}
			catch (err:Error)
			{
				fail(bulkFile, "The specified resource wrapper class \"" + item.resource.wrapperClass
					+ "\" for resource with ID \"" + item.resource.id + "\" could not be"
					+ " instantiated because it is not of type ResourceFile (" + err.message + ").");
				return;
			}
			
			bulkFile.wrapper = w;
		}
		
		
		/**
		 * Adds a resource bulk file for loading.
		 * @private
		 */
		protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			/* Don't allow to re-add bulk files that are currently processed! */
			if (_bulkFiles[bulkFile.id] == null)
			{
				_bulkFiles[bulkFile.id] = bulkFile;
			}
		}
		
		
		/**
		 * Starts loading all resource files that were added with addLoadFile().
		 * @private
		 */
		protected function loadFiles():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * The processing of resources follows the same procedure regardless from which
		 * concrete resource provider it came.
		 * 
		 * @private
		 */
		protected function processBulkFile(bulkFile:ResourceBulkFile):void
		{
			if (bulkFile.wrapper is XMLResourceWrapper)
				parseXMLResource(bulkFile);
			else
				parseMediaResource(bulkFile);
		}
		
		
		/**
		 * @private
		 */
		protected function parseXMLResource(bulkFile:ResourceBulkFile):void
		{
			var w:XMLResourceWrapper = XMLResourceWrapper(bulkFile.wrapper);
			if (!w.valid)
			{
				fail(bulkFile, w.status);
				return;
			}
			
			var resourceType:String = bulkFile.resourceType;
			var resourceFamily:String = bulkFile.resourceFamily;
			var parser:IDataParser;
			
			if (resourceFamily == ResourceFamily.DATA || resourceFamily == ResourceFamily.ENTITY)
			{
				if (!resourceType || resourceType.length < 1)
				{
					fail(bulkFile, "Data resource has no type defined (ResourceBulkFile ID: "
						+ bulkFile.id + ").");
					return;
				}
				
				/* Resources of family ResourceFamily.DATA use a parser that is mapped
				 * with their data type. Other data resources (entities) are always mapped
				 * with their resource family name. */
				if (bulkFile.resourceFamily == ResourceFamily.DATA)
					parser = _dsm.createDataTypeParser(resourceType);
				else
					parser = _dsm.createDataTypeParser(bulkFile.resourceFamily);
				
				if (parser)
				{
					parser.parse(w, resourceManager.resourceIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing data resource! Data parser not created.");
					return;
				}
			}
			else if (resourceFamily == ResourceFamily.TEXT)
			{
				parser = _dsm.createDataTypeParser(resourceFamily);
				if (parser)
				{
					parser.parse(w, resourceManager.stringIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing text resource! Text parser not created.");
					return;
				}
			}
			
			/* Check for referenced resources. */
			if (parser.referencedIDs != null)
			{
				var refIDs:Object = parser.referencedIDs;
				var a:Array = [];
				for (var refID:String in refIDs)
				{
					var refType:String = refIDs[refID];
					a.push(refID);
					Log.debug(bulkFile.id + " requested referenced resource with ID \""
						+ refID + "\".", this);
				}
				resourceManager.load(a);
			}
			
			/* Mark all resources in the loaded bulk file as loaded. */
			for (var i:int = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.LOADED);
			}
			
			dispatchEvent(new ResourceEvent(ResourceEvent.FILE_LOADED, bulkFile));
			increaseCompleteCount(bulkFile);
			checkComplete(bulkFile);
		}
		
		
		/**
		 * @private
		 */
		protected function parseMediaResource(bulkFile:ResourceBulkFile):void
		{
			var r:Resource = bulkFile.item.resource;
			r.setContent(bulkFile.wrapper.content);
			r.setStatus(ResourceStatus.LOADED);
			dispatchEvent(new ResourceEvent(ResourceEvent.FILE_LOADED, bulkFile));
			increaseCompleteCount(bulkFile);
			checkComplete(bulkFile);
		}
		
		
		/**
		 * Checks whether all resources in the current bulk have been processed.
		 * @private
		 */
		protected function checkComplete(bulkFile:ResourceBulkFile):void
		{
			/* Finished files can be removed from temporary map now. */
			_bulkFiles[bulkFile.id] = null;
			delete _bulkFiles[bulkFile.id];
			
			var bulk:ResourceBulk = bulkFile._bulk;
			if (bulk._completeCount == bulk._fileCount)
			{
				_bulkComplete = true;
				if (_loaderComplete) reset();
				dispatchEvent(new ResourceEvent(ResourceEvent.BULK_LOADED, bulkFile));
			}
		}
		
		
		/**
		 * @private
		 */
		protected function fail(bulkFile:ResourceBulkFile, message:String = null):void
		{
			/* Mark all resources in the failed bulk file as failed. */
			for (var i:int = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.FAILED);
			}
			bulkFile._bulk._fileCount--;
			dispatchEvent(new ResourceEvent(ResourceEvent.FILE_FAILED, bulkFile, message));
			checkComplete(bulkFile);
		}
		
		
		/**
		 * @private
		 */
		protected function increaseCompleteCount(bulkFile:ResourceBulkFile):void
		{
			bulkFile._bulk._completeCount++;
		}
	}
}
