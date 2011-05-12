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
	 * A Resource is a data object used to store loaded resources in the resource
	 * index. Once the resource file for a Resource has been loaded (and parsed)
	 * the Resource object will also contain it's loaded data.
	 */
	public class Resource
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _id:String;
		private var _path:String;
		private var _packageID:String;
		private var _dataFileID:String;
		private var _family:String;
		private var _dataType:String;
		private var _embedded:Boolean;
		private var _referenceCount:int;
		private var _status:String;
		private var _content:*;
		private var _wrapperClass:Class;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of Resource.
		 * 
		 * @param i ID
		 * @param p Path
		 * @param k Package ID
		 * @param d Data File ID
		 * @param c Resource wrapper class
		 * @param f Resource Family
		 * @param t Resource Type (Parser ID)
		 * @param e Embedded
		 */
		public function Resource(i:String, p:String, k:String, d:String, c:Class, f:String,
			t:String, e:Boolean)
		{
			_id = i;
			_path = p;
			_packageID = k;
			_dataFileID = d;
			_family = f;
			_dataType = t;
			_embedded = e;
			_referenceCount = 0;
			_wrapperClass = c;
			_status = ResourceStatus.INIT;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the resource.
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * The path of the resource file, either on the filesystem, inside a resource
		 * package file or that of an embedded resource file.
		 */
		public function get path():String
		{
			return _path;
		}
		
		
		/**
		 * The package ID if the resource is packed into a resource package file.
		 */
		public function get packageID():String
		{
			return _packageID;
		}
		
		
		/**
		 * The resource file wrapper class that is used to load the file for this resource.
		 */
		public function get wrapperClass():Class
		{
			return _wrapperClass;
		}
		
		
		/**
		 * For data resources, the ID of the datafile in which the resource can be found.
		 * Media and text resources have no dataFileID.
		 */
		public function get dataFileID():String
		{
			return _dataFileID;
		}
		
		
		/**
		 * The resource family that the resource is part of.
		 */
		public function get family():String
		{
			return _family;
		}
		
		
		/**
		 * The data type of the resource, only used for data and entity resources.
		 */
		public function get dataType():String
		{
			return _dataType;
		}
		
		
		/**
		 * If the resource is an embedded file this property is true, otherwise false.
		 */
		public function get embedded():Boolean
		{
			return _embedded;
		}
		
		
		/**
		 * Contains the actual content of the resource once it has been loaded. The object
		 * type of the content depends on what resource it is associated with, it can be a
		 * BitmapData, a Sound, an XML etc. or any other custom media or data object class.
		 */
		public function get content():*
		{
			return _content;
		}
		
		
		/**
		 * The reference count of the resource. Anytime a class requests this resource from
		 * the resource manager, it's reference count increases by one and everytime a class
		 * requests the resource manager to unload this resource, it's reference count
		 * decreases by one. If the value reaches 0 after an unload the resource manager
		 * will remove the resource from memory.
		 */
		public function get referenceCount():int
		{
			return _referenceCount;
		}
		
		
		/**
		 * A string that determines in what state the resource currently is. See
		 * ResourceStatus.INIT.
		 */
		public function get status():String
		{
			return _status;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the resource.
		 */
		internal function reset():void
		{
			_content = null;
			_referenceCount = 0;
			_status = ResourceStatus.INIT;
		}
		
		
		/**
		 * Sets the status of the resource.
		 */
		internal function setStatus(status:String):void
		{
			_status = status;
		}
		
		
		/**
		 * Sets the content of the resource.
		 */
		internal function setContent(content:*):void
		{
			_content = content;
		}
		
		
		/**
		 * Increases the resource's reference count by one.
		 */
		internal function increaseReferenceCount():void
		{
			_referenceCount++;
		}
		
		
		/**
		 * Decreases the resource's reference count by one.
		 */
		internal function decreaseReferenceCount():void
		{
			if (_referenceCount == 0) return;
			_referenceCount--;
		}
	}
}
