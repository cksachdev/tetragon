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
	import base.io.resource.wrappers.ResourceWrapper;
	
	
	/**
	 * A value object used by the resource manager to load resource files.
	 */
	public class ResourceBulkFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _id:String;
		private var _path:String;
		private var _resourceFamily:String;
		private var _resourceType:String;
		private var _bulk:ResourceBulk;
		private var _wrapper:ResourceWrapper;
		private var _items:Vector.<ResourceBulkItem>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id ID of the data file.
		 */
		public function ResourceBulkFile(id:String, bulk:ResourceBulk)
		{
			_id = id;
			_bulk = bulk;
			_items = new Vector.<ResourceBulkItem>();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a resource bulk item for loading to the bulk.
		 */
		internal function addItem(item:ResourceBulkItem):void
		{
			if (_path == null) _path = item.resource.path;
			if (_resourceFamily == null) _resourceFamily = item.resource.family;
			if (_resourceType == null) _resourceType = item.resource.dataType;
			
			item.setBulkFile(this);
			_items.push(item);
		}
		
		
		/**
		 * @private
		 */
//		internal function updateProgress(e:BulkFileIOEvent):void
//		{
//			_bytesLoaded = e.currentFileBytesLoaded;
//			_bytesTotal = e.currentFileBytesTotal;
//			_bulk.updateProgress(e);
//		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		internal function toString():String
		{
			return "[ResourceBulkFile, id=" + id + ", items=" + items.length + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the resource bulk file.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * The path of the resource bulk file.
		 */
		public function get path():String
		{
			return _path;
		}
		
		
		/**
		 * Returns the resource bulk item of the bulk file. If this bulk file contains
		 * more than one item, the first item is returned.
		 */
		public function get item():ResourceBulkItem
		{
			return items[0];
		}
		
		
		/**
		 * The resource bulk that this bulk item is part of.
		 */
		public function get bulk():ResourceBulk
		{
			return _bulk;
		}
		
		
		/**
		 * A vector with the ResourceBulkItems of the bulk file.
		 */
		public function get items():Vector.<ResourceBulkItem>
		{
			return _items;
		}
		
		
		internal function get wrapper():ResourceWrapper
		{
			return _wrapper;
		}
		internal function set wrapper(v:ResourceWrapper):void
		{
			_wrapper = v;
			_wrapper.setup(this);
		}
		
		
		public function get resourceFamily():String
		{
			return _resourceFamily;
		}
		
		
		public function get resourceType():String
		{
			return _resourceType;
		}
	}
}
