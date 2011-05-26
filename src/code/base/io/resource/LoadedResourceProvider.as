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
	import base.data.Config;
	import base.data.Registry;

	import com.hexagonstar.file.BulkLoader;
	import com.hexagonstar.file.types.IFile;
	
	
	/**
	 * Provider for resources that are loaded from the file system.
	 */
	public final class LoadedResourceProvider extends ResourceProvider implements IResourceProvider
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ID:String = "loadedResourceProvider";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _loader:BulkLoader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function LoadedResourceProvider(id:String = null)
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
			var cfg:Config = Registry.config;
			_loader = new BulkLoader(cfg.ioLoadConnections, cfg.ioLoadRetries,
				cfg.ioUseAbsoluteFilePath, cfg.ioPreventFileCaching);
			_loader.fileOpenSignal.add(onBulkFileOpen);
			_loader.fileProgressSignal.add(onBulkFileProgress);
			_loader.fileCompleteSignal.add(onBulkFileLoaded);
			_loader.fileIOErrorSignal.add(onBulkFileError);
			_loader.fileSecurityErrorSignal.add(onBulkFileError);
			_loader.allCompleteSignal.add(onLoaderComplete);
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function loadResourceBulk(bulk:ResourceBulk):void
		{
			if (!_loader) return;
			super.loadResourceBulk(bulk);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			_loader.fileOpenSignal.remove(onBulkFileOpen);
			_loader.fileProgressSignal.remove(onBulkFileProgress);
			_loader.fileCompleteSignal.remove(onBulkFileLoaded);
			_loader.fileIOErrorSignal.remove(onBulkFileError);
			_loader.fileSecurityErrorSignal.remove(onBulkFileError);
			_loader.allCompleteSignal.remove(onLoaderComplete);
			_loader.dispose();
			_loader = null;
			super.dispose();
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
			/* For files loaded from the filesystem we need to add the resourcefolder to the path. */
			var file:IFile = bulkFile.resourceLoader.file;
			file.path = Registry.config.resourceFolder + "/" + file.path;
			_loader.addFile(file);
			super.addBulkFile(bulkFile);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function loadFiles():void
		{
			_loader.load();
		}
	}
}
