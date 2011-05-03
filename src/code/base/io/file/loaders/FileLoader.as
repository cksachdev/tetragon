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
package base.io.file.loaders
{
	import base.core.debug.Log;
	import base.data.Registry;

	import com.hexagonstar.file.BulkLoader;
	import com.hexagonstar.file.FileIOEvent;
	import com.hexagonstar.file.IFileIOEventListener;
	import com.hexagonstar.file.types.XMLFile;
	import com.hexagonstar.structures.queues.Queue;

	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	
	
	/**
	 * Abstract base class for file loaders. Provides common implementation for concrete
	 * loader classes.
	 */
	public class FileLoader extends EventDispatcher implements IFileIOEventListener
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _loader:BulkLoader;
		protected var _files:Queue;
		protected var _preventNotify:Boolean;
		protected var _useAbsoluteFilePath:Boolean;
		protected var _preventFileCaching:Boolean;

		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AbstractLoader instance.
		 */
		public function FileLoader()
		{
			super();
			
			_preventNotify = false;
			_loader = new BulkLoader(Registry.config.ioLoadConnections, Registry.config.ioLoadRetries,
				Registry.config.ioUseAbsoluteFilePath, Registry.config.ioPreventFileCaching);
			_loader.addEventListenersFor(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function addFile(filePath:String, fileID:String = null):void
		{
			if (!_files) _files = new Queue();
			_files.add(new XMLFile(filePath, fileID));
		}
		
		
		/**
		 * Starts the load process.
		 */
		public function load():void
		{
			if (_loader.loading) return;
			_loader.addFileQueue(_files);
			_loader.load();
		}
		
		
		/**
		 * abort
		 */
		public function abort():void
		{
			_loader.abort();
		}
		
		
		/**
		 * Disposes the loader.
		 */
		public function dispose():void
		{
			_loader.removeEventListenersFor(this);
			_loader.dispose();
			_loader = null;
			_files = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Abstract Method.
		 */
		public function onFileOpen(e:FileIOEvent):void
		{
			//Debug.trace(toString() + " Opened: " + e.file.path);
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileProgress(e:FileIOEvent):void
		{
			//Debug.trace(toString() + " Load Progress: " + e.file.path);
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileComplete(e:FileIOEvent):void
		{
			Log.debug("Loaded \"" + e.file.path + "\".", this);
		}
		
		/**
		 * Abstract Method.
		 */
		public function onAllFilesComplete(e:FileIOEvent):void
		{
			//Debug.trace(toString() + " onComplete");
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileAbort(e:FileIOEvent):void
		{
			Log.debug("Aborted after \"" + e.file.path + "\".", this);
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileHTTPStatus(e:FileIOEvent):void
		{
			var code:int = e.httpStatus;
			if (code > 0)
			{
				var status:String = e.httpStatusInfo;
				if (code > 399 && code < 600)
					Log.warn("HTTPStatus: " + status, this);
				else
					Log.debug("HTTPStatus: " + status, this);
			}
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileIOError(e:FileIOEvent):void
		{
			notifyLoadError(e);
		}
		
		/**
		 * Abstract Method.
		 */
		public function onFileSecurityError(e:FileIOEvent):void
		{
			notifyLoadError(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function notifyLoadError(e:FileIOEvent):void
		{
			if (!Capabilities.isDebugger)
			{
				notifyError("Could not load " + e.file.path + " (" + e.text + ").");
			}
			else
			{
				notifyError(e.text);
			}
		}
		
		
		/**
		 * Notifies any listener that an error occured during loading/checking the config.
		 * @private
		 * 
		 * @param msg the error message.
		 */
		protected function notifyError(msg:String):void
		{
			if (!_preventNotify)
			{
				_preventNotify = true;
				
				var e:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
				e.text = toString() + " Error: " + msg;
				dispatchEvent(e);
			}
		}
		
		
		/**
		 * Trims whitespace from the start and end of the specified string.
		 * @private
		 */
		protected static function trim(s:String):String
		{
			return s.replace(/^[ \t]+|[ \t]+$/g, "");
		}
	}
}
