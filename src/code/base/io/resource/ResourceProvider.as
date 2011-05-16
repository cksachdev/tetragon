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
	import base.data.parsers.DataObjectParser;
	import base.data.parsers.IDataParser;
	import base.event.ResourceEvent;
	import base.io.resource.wrappers.ResourceWrapper;
	import base.io.resource.wrappers.XMLResourceWrapper;

	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Abstract base class for resource providers.
	 */
	public class ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _dsm:DataSupportManager;
		private var _resourceManager:ResourceManager;
		private var _isNextFileOpened:Boolean;
		
		/**
		 * ID of the resource provider, if necessary (PackedResourceProvider needs it!)
		 */
		protected var _id:String;
		
		/**
		 * A map that stores ResourceBulkFile objects temporarily for loading, used to
		 * keep track of them in event handlers. Bulk files are mapped by their ID.
		 */
		protected var _bulkFiles:Object;
		
		/**
		 * Determines if a loader has completed loading all files.
		 */
		protected var _loaderComplete:Boolean;
		
		/**
		 * Determines if a bulk has completed processing.
		 */
		protected var _isBulkComplete:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Signal
		//-----------------------------------------------------------------------------------------
		
		protected var _openSignal:Signal;
		protected var _closeSignal:Signal;
		protected var _errorSignal:Signal;
		protected var _fileLoadedSignal:Signal;
		protected var _fileFailedSignal:Signal;
		protected var _bulkProgressSignal:Signal;
		protected var _bulkLoadedSignal:Signal;
		
		
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
			_isNextFileOpened = false;
			
			_bulkProgressSignal = new Signal();
			_fileLoadedSignal = new Signal();
			_fileFailedSignal = new Signal();
			_bulkLoadedSignal = new Signal();
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
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get bulkProgressSignal():Signal
		{
			return _bulkProgressSignal;
		}
		
		
		public function get fileLoadedSignal():Signal
		{
			return _fileLoadedSignal;
		}
		
		
		public function get fileFailedSignal():Signal
		{
			return _fileFailedSignal;
		}
		
		
		public function get bulkLoadedSignal():Signal
		{
			return _bulkLoadedSignal;
		}
		
		
		internal function get openSignal():Signal
		{
			if (!_openSignal) _openSignal = new Signal();
			return _openSignal;
		}
		
		
		internal function get closeSignal():Signal
		{
			if (!_closeSignal) _closeSignal = new Signal();
			return _closeSignal;
		}
		
		
		internal function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		/**
		 * A reference to the resource manager.
		 */
		protected function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		protected function onBulkFileOpen(file:IFile):void
		{
			_isNextFileOpened = true;
		}
		
		
		protected function onBulkFileProgress(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			//bf.updateProgress(e);
			
			if (_isNextFileOpened)
			{
				//Debug.trace(e.file.path + " percentage: " + e.percentage);
				_isNextFileOpened = false;
				//bf.bulk.setCurrentFile(bf);
			}
			
			_bulkProgressSignal.dispatch(bf);
			//_progressSignal.dispatch(bf.bulk.stats);
		}
		
		
		protected function onBulkFileLoaded(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			//bf.updateProgress(e);
			bf.wrapper.addEventListener(ResourceEvent.INIT_SUCCESS, onResourceInit);
			bf.wrapper.addEventListener(ResourceEvent.INIT_FAILED, onResourceInit);
			bf.wrapper.initialize();
		}
		
		
		protected function onResourceInit(e:ResourceEvent):void
		{
			var bf:ResourceBulkFile = e.bulkFile;
			bf.wrapper.removeEventListener(ResourceEvent.INIT_SUCCESS, onResourceInit);
			bf.wrapper.removeEventListener(ResourceEvent.INIT_FAILED, onResourceInit);
			
			if (e.type == ResourceEvent.INIT_FAILED)
				fail(bf, e.text);
			else
				processBulkFile(bf);
		}
		
		
		protected function onBulkFileError(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			fail(bf, file.errorMessage);
		}
		
		
		protected function onLoaderComplete(file:IFile):void
		{
			var bf:ResourceBulkFile = _bulkFiles[file.id];
			//bf.updateProgress(e);
			_loaderComplete = true;
			if (_isBulkComplete) reset();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the resource provider.
		 */
		protected function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Tries to instantiate the resource wrapper class for the resource in the specified
		 * bulk file.
		 * 
		 * @param bulkFile
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
		 * 
		 * @param bulkFile
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
		 */
		protected function loadFiles():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * The processing of resources follows the same procedure regardless from which
		 * concrete resource provider it came.
		 * 
		 * @param bulkFile
		 */
		protected function processBulkFile(bulkFile:ResourceBulkFile):void
		{
			if (bulkFile.wrapper is XMLResourceWrapper)
				parseXMLResource(bulkFile);
			else
				parseMediaResource(bulkFile);
		}
		
		
		/**
		 * @param bulkFile
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
			
			if (resourceFamily == ResourceFamily.TEXT)
			{
				parser = _dsm.createDataTypeParser(resourceFamily);
				if (parser)
				{
					parser.parse(w, resourceManager.stringIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing text resource from " + bulkFile.id
						+ "! Text parser not created.");
					return;
				}
			}
			else
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
				{
					parser = _dsm.createDataTypeParser(resourceType);
				}
				else
				{
					parser = _dsm.createDataTypeParser(bulkFile.resourceFamily);
				}
				
				if (parser)
				{
					parser.parse(w, resourceManager.resourceIndex);
				}
				else
				{
					fail(bulkFile, "Failed parsing data resource from " + bulkFile.id
						+ "! Data parser not created.");
					return;
				}
			}
			
			/* Check if referenced resources need to be loaded. */
			if (parser is DataObjectParser)
			{
				loadReferencedResources(DataObjectParser(parser).referencedIDs, bulkFile);
			}
			
			/* Mark all resources in the loaded bulk file as loaded. */
			for (var i:uint = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.LOADED);
			}
			
			_fileLoadedSignal.dispatch(bulkFile);
			bulkFile.bulk.increaseLoadedCount();
			checkComplete(bulkFile);
		}
		
		
		/**
		 * @param bulkFile
		 */
		protected function parseMediaResource(bulkFile:ResourceBulkFile):void
		{
			var r:Resource = bulkFile.item.resource;
			r.setContent(bulkFile.wrapper.content);
			r.setStatus(ResourceStatus.LOADED);
			_fileLoadedSignal.dispatch(bulkFile);
			bulkFile.bulk.increaseLoadedCount();
			checkComplete(bulkFile);
		}
		
		
		/**
		 * @param referencedIDs
		 * @param bf
		 */
		protected function loadReferencedResources(referencedIDs:Object, bf:ResourceBulkFile):void
		{
			if (!referencedIDs) return;
			var a:Array = [];
			for (var refID:String in referencedIDs)
			{
				var resID:String = referencedIDs[refID];
				a.push(refID);
				Log.debug(bf.id + " requested referenced resource with ID \"" + refID + "\".", this);
			}
			resourceManager.enqueueReferencedResources(a);
		}
		
		
		/**
		 * Checks whether all resources in the current bulk have been processed.
		 * 
		 * @param bulkFile
		 */
		protected function checkComplete(bulkFile:ResourceBulkFile):void
		{
			/* Finished files can be removed from temporary map now. */
			delete _bulkFiles[bulkFile.id];
			
			if (bulkFile.bulk.stats.isComplete)
			{
				_isBulkComplete = true;
				if (_loaderComplete) reset();
				_bulkLoadedSignal.dispatch(bulkFile);
			}
		}
		
		
		/**
		 * @param bulkFile
		 * @param message
		 */
		protected function fail(bulkFile:ResourceBulkFile, message:String = null):void
		{
			/* Mark all resources in the failed bulk file as failed. */
			for (var i:uint = 0; i < bulkFile.items.length; i++)
			{
				bulkFile.items[i].resource.setStatus(ResourceStatus.FAILED);
			}
			bulkFile.bulk.decreaseTotalCount();
			_fileFailedSignal.dispatch(bulkFile, message);
			checkComplete(bulkFile);
		}
	}
}
