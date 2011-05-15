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
package base.io.resource.wrappers
{
	import base.core.debug.Log;
	import base.event.ResourceEvent;
	import base.io.resource.ResourceBulkFile;

	import com.hexagonstar.constants.Status;
	import com.hexagonstar.exception.IllegalArgumentException;
	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.util.reflection.getClassName;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	
	/**
	 * The base class for resource wrappers. A resource wrapper is used by the resource
	 * manager and resource providers to temporarily wrap resource files that are being
	 * loaded. Depending on the loaded resource file the method how it is loaded differs.
	 * 
	 * <p>For example the implementation for loading a sound file is different than that for
	 * an image file. The resource wrappers take care that those files are loaded the way
	 * they need to be loaded. In other words: A resource wrapper essentially represents
	 * the resource file type.</p>
	 * 
	 * <p>Resource wrappers can load files from the filesystem as well as embedded files.</p>
	 */
	public class ResourceWrapper extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _bulkFile:ResourceBulkFile;
		protected var _status:String = Status.OK;
		protected var _file:IFile;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the resource wrapper.
		 */
		public function setup(bulkFile:ResourceBulkFile):void
		{
			_bulkFile = bulkFile;
		}
		
		
		/**
		 * Initializes the resource file with data either from a loaded or an embedded asset.
		 * The data argument is only required to provide embedded data.
		 * 
		 * @param embeddedData The resource data from an embedded asset.
		 */
		public function initialize(embeddedData:* = null):void
		{
			if (embeddedData == null) initializeFromLoaded();
			else initializeFromEmbedded(embeddedData);
		}
		
		
		/**
		 * This method will be used by a Resource Provider to indicate that this
		 * resource file has failed loading.
		 */
		public function fail(message:String):void
		{
			onFailed(message);        	
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		override public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the ID of the resource file (which is the same as it's wrapped resource).
		 */
		public function get id():String
		{
			return _bulkFile.id;
		}
		
		
		/**
		 * Returns the resource object that this resource file acts as a wrapper for.
		 */
		public function get bulkFile():ResourceBulkFile
		{
			return _bulkFile;
		}
		
		
		/**
		 * Returns the file that is wrapped by the ResourceFile. Used only by the resource
		 * provider to load the resource. Once the resource is loaded this object will be null.
		 * @private
		 */
		public function get file():IFile
		{
			return _file;
		}
		
		
		/**
		 * Returns the resource's loaded content data.
		 */
		public function get content():*
		{
			return null;
		}
		
		
		/**
		 * The status of the resource file. If the data was validated successfully,
		 * this is FileErrorStatus.OK, if the XML data was not validated successfully, for
		 * example because it contains malformed XML syntax, the errorStatus will contain
		 * the error message returned by the parser.
		 */
		public function get status():String
		{
			return _status;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * This is called when the resource data has been fully loaded and conditioned.
		 * Returning true from this method means the load was successful. False indicates
		 * failure. Subclasses must implement this method.
		 * 
		 * @param content The fully conditioned data for this resource.
		 * @return true if content contains valid data, false otherwise.
		 */
		protected function onContentReady(content:*):Boolean
		{
			return false;
		}
		
		
		/**
		 * Called when loading and conditioning of the resource data is complete. This
		 * must be called by, and only by, subclasses that override the initialize
		 * method.
		 * 
		 * @param event This can be ignored by subclasses.
		 */
		protected function onLoadComplete(e:Event = null):void
		{
			try
			{
				if (onContentReady(e ? e.target["content"] : null))
				{
					_file = null;
					dispatchEvent(new ResourceEvent(ResourceEvent.INIT_SUCCESS, _bulkFile));
					return;
				}
				else
				{
					onFailed(_status);
					return;
				}
			}
			catch(err:Error)
			{
				Log.error("Failed to load - " + err.message, this);
			}
			
			_status = "The resource type does not match the loaded content.";
			onFailed(_status);
		}
		
		
		/**
		 * @param message
		 */
		protected function onFailed(message:String):void
		{
			_file = null;
			dispatchEvent(new ResourceEvent(ResourceEvent.INIT_FAILED, _bulkFile, message));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the resource file with data from a loaded file.
		 */
		protected function initializeFromLoaded():void
		{
			dispatchEvent(new ResourceEvent(ResourceEvent.INIT_SUCCESS, _bulkFile));
		}
		
		
		/**
		 * Initializes the resource file with data from an embedded file.
		 */
		protected function initializeFromEmbedded(embeddedData:*):void
		{
			if (!(embeddedData is ByteArray))
			{
				throw new IllegalArgumentException(toString()
					+ " Base ResourceFile can only process ByteArrays as embedded data!");
			}
		}
	}
}
