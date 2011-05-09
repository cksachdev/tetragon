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
	import base.event.ResourceEvent;

	import com.hexagonstar.file.FileIOEvent;

	
	/**
	 * Provider for resources that are embedded in the SWF file via [Embed] metatag.
	 */
	public class EmbeddedResourceProvider extends ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public static const ID:String = "embeddedResourceProvider";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _resourceBundle:ResourceBundle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EmbeddedResourceProvider(id:String = null)
		{
			super(id);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init(arg:* = null):Boolean
		{
			_resourceBundle = arg;
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function loadResourceBulk(bulk:ResourceBulk):void
		{
			if (!_resourceBundle) return;
			super.loadResourceBulk(bulk);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_resourceBundle = null;
			super.dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String
		{
			return "EmbeddedResourceProvider";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function onBulkFileLoaded(e:FileIOEvent):void
		{
			/* Not used for EmbeddedResourceProvider! */
		}
		
		
		/**
		 * @private
		 */
		override protected function onBulkFileError(e:FileIOEvent):void
		{
			/* Not used for EmbeddedResourceProvider! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function addBulkFile(bulkFile:ResourceBulkFile):void
		{
			super.addBulkFile(bulkFile);
			bulkFile.wrapper.addEventListener(ResourceEvent.INIT_SUCCESS, onResourceInit);
			bulkFile.wrapper.addEventListener(ResourceEvent.INIT_FAILED, onResourceInit);
			bulkFile.wrapper.initialize(_resourceBundle.getResourceData(bulkFile.path));
		}
	}
}
