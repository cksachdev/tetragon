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
	import base.data.Registry;
	import base.util.Log;

	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.ZipLoader;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	
	/**
	 * Provider for resources that are loaded from a packed (zipped) resource container file.
	 */
	public class PackedResourceProvider extends ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _loader:ZipLoader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function PackedResourceProvider(main:Main, rm:ResourceManager, id:String = null)
		{
			super(main, rm, id);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init(arg:* = null):Boolean
		{
			var path:String = Registry.config.resourceFolder + "/" + arg;
			var zipFile:File = File.applicationDirectory.resolvePath(path);
			
			if (!zipFile.exists)
			{
				Log.error("The resource package file \"" + path + "\" could not be found!", this);
				return false;
			}
			
			_loader = new ZipLoader(zipFile);
			_loader.addEventListener(Event.OPEN, onLoaderOpen);
			_loader.addEventListener(Event.CLOSE, onLoaderClose);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			return true;
		}
		
		
		/**
		 * Opens the PackedResourceProvider.
		 */
		public function open():void
		{
			if (_loader) _loader.open();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function loadResourceBulk(bulk:ResourceBulk):void
		{
			if (!_loader || !_loader.opened) return;
			super.loadResourceBulk(bulk);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_loader.removeEventListener(Event.OPEN, onLoaderOpen);
			_loader.removeEventListener(Event.CLOSE, onLoaderClose);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loader.removeEventListener(FileIOEvent.IO_ERROR, onBulkFileError);
			_loader.removeEventListener(FileIOEvent.SECURITY_ERROR, onBulkFileError);
			_loader.removeEventListener(FileIOEvent.FILE_COMPLETE, onBulkFileLoaded);
			_loader.removeEventListener(FileIOEvent.COMPLETE, onLoaderComplete);
			_loader.dispose();
			_loader = null;
			super.dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "[PackedResourceProvider]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the PackedResourceProvider. This reflects the name of the resource
		 * package file that this provider is used for.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onLoaderOpen(e:Event):void
		{
			_loader.addEventListener(FileIOEvent.IO_ERROR, onBulkFileError);
			_loader.addEventListener(FileIOEvent.SECURITY_ERROR, onBulkFileError);
			_loader.addEventListener(FileIOEvent.FILE_COMPLETE, onBulkFileLoaded);
			_loader.addEventListener(FileIOEvent.COMPLETE, onLoaderComplete);
			Log.debug("Opened resource package \"" + _loader.filename + "\".", this);
			dispatchEvent(e.clone());
		}
		
		
		/**
		 * @private
		 */
		private function onLoaderClose(e:Event):void
		{
			dispatchEvent(e.clone());
		}
		
		
		/**
		 * @private
		 */
		private function onLoaderError(e:IOErrorEvent):void
		{
			dispatchEvent(e.clone());
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function reset():void
		{
			if (!_loader) return;
			if (_loader.loading) return;
			_loader.reset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			/* If we get false returned by the zip load it is probably because the
			 * path is wrong, so mark the resource as failed (Otherwise we'd get stuck
			 * after such a resource). */
			if (!_loader.addFile(bulkFile.wrapper.file))
			{
				fail(bulkFile, "Resource file with ID \"" + bulkFile.wrapper.file.id
					+ "\" was not added for loading to ZipLoader"
					+ " (possibly wrong path or unsupported compression format?).");
				return;
			}
			super.addBulkFile(bulkFile);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function loadFiles():void
		{
			_bulkComplete = false;
			_loaderComplete = false;
			_loader.load();
		}
	}
}
