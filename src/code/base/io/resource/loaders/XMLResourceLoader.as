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
package base.io.resource.loaders
{
	import base.io.resource.ResourceBulkFile;
	import base.io.resource.ResourceBulkItem;

	import com.hexagonstar.file.types.BinaryFile;

	import flash.utils.ByteArray;
	
	
	/**
	 * A resource loader for XML data.
	 */
	public class XMLResourceLoader extends ResourceLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _xml:XML;
		protected var _valid:Boolean;
		protected var _items:Vector.<ResourceBulkItem>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function setup(bulkFile:ResourceBulkFile):void
		{
			super.setup(bulkFile);
			_items = bulkFile.items;
			_file = new BinaryFile(bulkFile.path, bulkFile.id);
		}
		
		
		/**
		 * Checks if the bulk file that is wrapped by this loader contains the
		 * resource with the specified ID. This can be used to filter out unwanted
		 * resources that are in the same resource file while parsing.
		 */
		public function hasResourceID(id:String):Boolean
		{
			for each (var i:ResourceBulkItem in _items)
			{
				if (i.resourceID == id) return true;
			}
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The loaded data. This will be null until loading of the resource has completed.
		 */
		public function get xml():XML
		{
			return _xml;
		}
		
		
		/**
		 * Indicates whether the loaded XML data is valid or not.
		 */
		public function get valid():Boolean
		{
			return _valid;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onContentReady(content:*):Boolean
		{
			return _valid;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromLoaded():void
		{
			initializeFromEmbedded(_file.contentAsBytes);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function initializeFromEmbedded(embeddedData:*):void
		{
			/* Convert ByteArray data to a string. */
			if (embeddedData is ByteArray)
			{
				embeddedData = ByteArray(embeddedData).readUTFBytes(ByteArray(embeddedData).length);
			}
			try
			{
				_xml = new XML(embeddedData);
				_valid = true;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = "XML check failed: " + err.message;
			}
			onLoadComplete();
		}
	}
}
