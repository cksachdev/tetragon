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
	import base.Main;
	import base.core.debug.Log;
	import base.data.Registry;
	import base.io.file.loaders.ResourceIndexLoader;

	import com.hexagonstar.exception.IllegalArgumentException;
	import com.hexagonstar.util.env.isAIRApplication;

	import flash.utils.Dictionary;
	
	
	/**
	 * Contains initialization code that the ResourceManager uses briefly after
	 * application startup.
	 */
	public final class ResourceManagerHelper
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _resourceManager:ResourceManager;
		private var _indexLoader:ResourceIndexLoader;
		private var _packedResourceProviderCount:int;
		internal var _usePackages:Boolean;
		internal var _resourceProviders:Dictionary;
		internal var _resourceIndex:ResourceIndex;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ResourceManagerHelper";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after the resource index file has been loaded (or failed loading). This
		 * handler is also called if no resource index file should be loaded (i.e if no
		 * filename for it was found in the config).
		 */
		private function onResourceIndexFileProcessed():void
		{
			if (_indexLoader)
			{
				_indexLoader.completeSignal.remove(onResourceIndexFileProcessed);
				_indexLoader.errorSignal.remove(onResourceIndexFileError);
				_indexLoader.dispose();
				_indexLoader = null;
			}
			/* If we're on an AIR application we want to use packed resources! */
			if (isAIRApplication()) preparePackageFiles();
			else _resourceManager.completeInitialization();
		}
		
		
		private function onResourceIndexFileError(message:String):void
		{
			if (_indexLoader)
			{
				_indexLoader.completeSignal.remove(onResourceIndexFileProcessed);
				_indexLoader.errorSignal.remove(onResourceIndexFileError);
				_indexLoader.dispose();
				_indexLoader = null;
			}
			Log.error("Could not load resource index file! (" + message + ")", this);
			_resourceManager.failInitialization();
		}
		
		
		/**
		 * Invoked after a PackedResourceProvider has been prepared for a resource pack.
		 */
		private function onResourceProviderOpened(p:ResourceProvider):void
		{
			CONFIG::IS_AIR_BUILD
			{
				var pp:PackedResourceProvider = PackedResourceProvider(p);
				pp.openSignal.remove(onResourceProviderOpened);
				pp.errorSignal.remove(onResourceProviderOpened);
				/* Map the PackedResourceProvider by ID. */
				_resourceProviders[pp.id] = pp;
				_packedResourceProviderCount--;
				if (_packedResourceProviderCount < 1)
				{
					_resourceManager.completeInitialization();
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes and starts the ResourceManagerHelper.
		 * 
		 * @param resourceBundleClass
		 */
		internal function init(resourceBundleClass:Class = null):void
		{
			_resourceManager = Main.instance.resourceManager;
			
			_resourceIndex = new ResourceIndex();
			_resourceProviders = new Dictionary();
			_usePackages = false;
			
			processResourceBundle(resourceBundleClass);
			loadResourceIndex();
		}
		
		
		/**
		 * If a resource bundle class was specified when initializing the resource manager
		 * and if the compile time constant USE_EMBEDDED_RESOURCES is set to true this
		 * method will process the resource bundle and register all resources that are
		 * embedded with the Embed meta tag so they can easily be loaded with the resource
		 * manager.
		 * 
		 * @param resourceBundleClass
		 */
		private function processResourceBundle(resourceBundleClass:Class):void
		{
			if (!resourceBundleClass) return;
			CONFIG::USE_EMBEDDED_RESOURCES
			{
				var resourceBundle:ResourceBundle;
				try
				{
					resourceBundle = new resourceBundleClass();
				}
				catch (err:Error)
				{
					throw new IllegalArgumentException(toString()
						+ " The specified resource bundle " + resourceBundleClass
						+ " is not of type Resource. Please ensure that your embedded resource"
						+ " bundle class extends Resource.");
					return;
				}
				resourceBundle.init(_resourceIndex);
				var p:IResourceProvider = _resourceProviders[EmbeddedResourceProvider.ID];
				/* Dispose if provider exists already (e.g. after app init call). */
				if (p)
				{
					p.dispose();
					p = null;
					delete _resourceProviders[EmbeddedResourceProvider.ID];
				}
				/* If we got any embedded resources, create the embedded resource provider. */
				if (resourceBundle.resourceCount > 0)
				{
					p = new EmbeddedResourceProvider();
					p.init(resourceBundle);
					_resourceProviders[EmbeddedResourceProvider.ID] = p;
				}
			}
		}
		
		
		/**
		 * This method loads the resource index file (resources.xml or resources.tem) and
		 * haves all resources listed in the index file being registered so they can be
		 * loaded with the Resource Manager.
		 */
		private function loadResourceIndex():void
		{
			var p:IResourceProvider = _resourceProviders[LoadedResourceProvider.ID];
			/* Dispose if provider exists already (e.g. after app init call). */
			if (p)
			{
				p.dispose();
				p = null;
				delete _resourceProviders[LoadedResourceProvider.ID];
			}
			/* Only load the resource index file if the index filename is defined. */
			if (Registry.config.resourceIndexFile && Registry.config.resourceIndexFile.length > 0)
			{
				/* Create resource provider for loaded resources. */
				p = new LoadedResourceProvider();
				p.init();
				_resourceProviders[LoadedResourceProvider.ID] = p;
				
				_indexLoader = new ResourceIndexLoader(_resourceIndex);
				_indexLoader.completeSignal.addOnce(onResourceIndexFileProcessed);
				_indexLoader.errorSignal.add(onResourceIndexFileError);
				_indexLoader.load();
			}
			else
			{
				Log.debug("Resource index file not loaded!", this);
				onResourceIndexFileProcessed();
			}
		}
		
		
		/**
		 * Creates a PackedResourceProvider for every resource package file and opens the
		 * associated resource package file so that resources can be loaded from it.
		 */
		private function preparePackageFiles():void
		{
			CONFIG::IS_AIR_BUILD
			{
				_packedResourceProviderCount = 0;
				_usePackages = true;
				var d:Object = _resourceIndex._packageFiles;
				for (var packageID:String in d)
				{
					var name:String = d[packageID];
					var p:PackedResourceProvider = new PackedResourceProvider(packageID);
					if (p.init(name))
					{
						p.openSignal.addOnce(onResourceProviderOpened);
						p.errorSignal.addOnce(onResourceProviderOpened);
						p.open();
						_packedResourceProviderCount++;
					}
				}
				/* No PackedResourceProviders were opened, we are finished! */
				if (_packedResourceProviderCount < 1)
				{
					_usePackages = false;
					_resourceManager.completeInitialization();
				}
			}
		}
	}
}
