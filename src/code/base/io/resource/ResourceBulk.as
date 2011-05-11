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
	/**
	 * A resource bulk is a bulk of resources that are being loaded in the same
	 * call by the resource manager. It is created temporarily by the resource
	 * manager to load resources and contains a collection of files which in
	 * turn contain one or more resource items.
	 */
	public class ResourceBulk
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		internal var id:String;
		internal var bulkFiles:Object;
		internal var provider:IResourceProvider;
		internal var loadedHandler:Function;
		internal var failedHandler:Function;
		internal var completeHandler:Function;
		internal var progressHandler:Function;
		
		private var _fileCount:int;
		private var _completeCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceBulk(id:String, p:IResourceProvider, lh:Function, fh:Function,
			ch:Function, ph:Function)
		{
			this.id = id;
			provider = p;
			loadedHandler = lh;
			failedHandler = fh;
			completeHandler = ch;
			progressHandler = ph;
			bulkFiles = {};
			_fileCount = 0;
			_completeCount = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a resource bulk item for loading to the bulk.
		 */
		internal function addItem(item:ResourceBulkItem):void
		{
			/* Get file ID for resource file. If it's a data file it has a dedicated ID,
			 * otherwise for media files we use the path as it's ID. */
			var fileID:String = item.resource.dataFileID;
			if (fileID == null || fileID.length < 1) fileID = item.resource.path;
			
			/* Check if a file object has already been created for the data file this item
			 * is in and if not create one. */
			var f:ResourceBulkFile = bulkFiles[fileID];
			if (f == null)
			{
				f = bulkFiles[fileID] = new ResourceBulkFile(fileID, this);
				_fileCount++;
			}
			
			/* Store the item in the file object. */
			f.addItem(item);
		}
		
		
		/**
		 * Loads the resource bulk via it's assigned resource provider.
		 */
		internal function load():void
		{
			provider.loadResourceBulk(this);
		}
		
		
		/**
		 * Increases the bulk's file complete count.
		 */
		internal function increaseCompleteCount():void
		{
			_completeCount++;
		}
		
		
		/**
		 * Decreases the bulk's file count. Used when bulk files failed to load.
		 */
		internal function decreaseFileCount():void
		{
			_fileCount--;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		internal function toString():String
		{
			return "[ResourceBulk, id=" + id + ", completeCount=" + _completeCount + ", fileCount=" + _fileCount + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get fileCount():int
		{
			return _fileCount;
		}
		public function get completeCount():int
		{
			return _completeCount + 1;
		}
		public function get isComplete():Boolean
		{
			return _completeCount == _fileCount;
		}
	}
}
