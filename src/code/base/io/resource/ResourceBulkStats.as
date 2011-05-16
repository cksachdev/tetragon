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
	 * ResourceBulkStats class
	 */
	public class ResourceBulkStats
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _bulk:ResourceBulk;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceBulkStats(bulk:ResourceBulk)
		{
			_bulk = bulk;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The currently loaded files of the resource bulk.
		 */
		public function get filesLoaded():uint
		{
			return _bulk.filesLoaded;
		}
		
		
		/**
		 * The total files of the resource bulk.
		 */
		public function get filesTotal():uint
		{
			return _bulk.filesTotal;
		}
		
		
		/**
		 * The currently loaded bytes of the resource bulk.
		 */
		public function get bytesLoaded():uint
		{
			return _bulk.bytesLoaded;
		}
		
		
		/**
		 * The total bytes of the resource bulk.
		 */
		public function get bytesTotal():uint
		{
			return _bulk.bytesTotal;
		}
		
		
		/**
		 * The total loaded percentage.
		 */
		public function get percentage():uint
		{
			return _bulk.percentage;
		}
		
		
		public function get currentFilePath():String
		{
			if (!_bulk.currentBulkFile) return null;
			return _bulk.currentBulkFile.path;
		}
		
		
		public function get currentFileBytesLoaded():uint
		{
			if (!_bulk.currentBulkFile) return 0;
			return _bulk.currentBulkFile.bytesLoaded;
		}
		
		
		public function get currentFileBytesTotal():uint
		{
			if (!_bulk.currentBulkFile) return 0;
			return _bulk.currentBulkFile.bytesTotal;
		}
		
		
		public function get currentFilePercentage():uint
		{
			return (currentFileBytesLoaded / currentFileBytesTotal * 100);
		}
		
		
		/**
		 * Determines whether the bulk has fully completed loading all bulk files
		 * that are part of it.
		 */
		public function get isComplete():Boolean
		{
			return filesLoaded == filesTotal;
		}
		
		
		/**
		 * The currently loading bulk file.
		 */
		internal function get currentBulkFile():ResourceBulkFile
		{
			return _bulk.currentBulkFile;
		}
		
		
		/**
		 * The resource bulk to which these stats belong.
		 */
		internal function get bulk():ResourceBulk
		{
			return _bulk;
		}
	}
}
