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
	import com.hexagonstar.file.IFileIOSignalListener;
	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.file.types.XMLFile;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.structures.queues.Queue;
	import com.hexagonstar.util.reflection.getClassName;

	import flash.system.Capabilities;
	
	
	/**
	 * Abstract base class for file loaders. Provides common implementation for concrete
	 * loader classes.
	 */
	public class FileLoader implements IFileIOSignalListener
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
		// Signals
		//-----------------------------------------------------------------------------------------
		
		protected var _errorSignal:Signal;
		protected var _completeSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AbstractLoader instance.
		 */
		public function FileLoader()
		{
			_preventNotify = false;
			_loader = new BulkLoader(Registry.config.ioLoadConnections, Registry.config.ioLoadRetries,
				Registry.config.ioUseAbsoluteFilePath, Registry.config.ioPreventFileCaching);
			_loader.addListenersFor(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a file to the loader.
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
		 * Aborts the loader.
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
			_loader.removeListenersFor(this);
			_loader.dispose();
			_loader = null;
			_files = null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		public function get completeSignal():Signal
		{
			if (!_completeSignal) _completeSignal = new Signal();
			return _completeSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Abstract Method.
		 */
		public function onFileOpen(file:IFile):void
		{
			//Debug.trace(toString() + " Opened: " + file.path);
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileProgress(file:IFile):void
		{
			//Debug.trace(toString() + " Load Progress: " + file.path);
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileComplete(file:IFile):void
		{
			Log.debug("Loaded \"" + file.path + "\".", this);
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onAllFilesComplete(file:IFile):void
		{
			//Log.debug(toString() + " onComplete");
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileAbort(file:IFile):void
		{
			Log.debug("Aborted after \"" + file.path + "\".", this);
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileHTTPStatus(file:IFile):void
		{
			var code:int = file.httpStatus;
			if (code > 0)
			{
				var status:String = file.httpStatusInfo;
				if (code > 399 && code < 600)
					Log.warn("HTTPStatus: " + status, this);
				else
					Log.debug("HTTPStatus: " + status, this);
			}
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileIOError(file:IFile):void
		{
			notifyLoadError(file);
		}
		
		
		/**
		 * Abstract Method.
		 */
		public function onFileSecurityError(file:IFile):void
		{
			notifyLoadError(file);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param e
		 */
		protected function notifyLoadError(file:IFile):void
		{
			if (!Capabilities.isDebugger)
			{
				notifyError("Could not load " + file.path + " (" + file.errorMessage + ").");
			}
			else
			{
				notifyError(file.errorMessage);
			}
		}
		
		
		/**
		 * Notifies any listener that an error occured during loading/checking the config.
		 * 
		 * @param msg the error message.
		 */
		protected function notifyError(msg:String):void
		{
			if (!_preventNotify)
			{
				_preventNotify = true;
				var message:String = toString() + " Error: " + msg;
				if (_errorSignal) _errorSignal.dispatch(message);
			}
		}
		
		
		/**
		 * Trims whitespace from the start and end of the specified string.
		 * 
		 * @param s
		 */
		protected static function trim(s:String):String
		{
			return s.replace(/^[ \t]+|[ \t]+$/g, "");
		}
	}
}
