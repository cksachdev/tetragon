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
	import com.hexagonstar.util.EnvUtil;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;


	
	
	/**
	 * Contains initialization code that the ResourceManager uses briefly after
	 * application startup.
	 */
	public class ResourceManagerHelper
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _resourceManager:ResourceManager;
		/** @private */
		private var _indexLoader:ResourceIndexLoader;
		/** @private */
		private var _packedResourceProviderCount:int;
		/** @private */
		internal var _usePackages:Boolean;
		/** @private */
		internal var _resourceProviders:Dictionary;
		/** @private */
		internal var _resourceIndex:ResourceIndex;
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after the resource index file has been loaded (or failed loading). This
		 * handler is also called if no resource index file should be loaded (i.e if no
		 * filename for it was found in the config).
		 * 
		 * @private
		 */
		private function onResourceIndexFileProcessed(e:Event):void
		{
			if (_indexLoader)
			{
				_indexLoader.removeEventListener(Event.COMPLETE, onResourceIndexFileProcessed);
				_indexLoader.removeEventListener(ErrorEvent.ERROR, onResourceIndexFileProcessed);
				_indexLoader.dispose();
				_indexLoader = null;
			}
			if (e.type == ErrorEvent.ERROR)
			{
				Log.error("Could not load resource index file! (" + ErrorEvent(e).text + ")", this);
				_resourceManager.failInitialization();
			}
			else
			{
				/* If we're on an AIR application we want to use packed resources! */
				if (EnvUtil.isAIRApplication) preparePackageFiles();
				else _resourceManager.completeInitialization();
			}
		}
		
		
		/**
		 * Invoked after a PackedResourceProvider has been prepared for a resource pack.
		 * 
		 * @private
		 */
		private function onPackedResourceProviderEvent(e:Event):void
		{
			CONFIG::IS_AIR_BUILD
			{
				if (e)
				{
					var p:PackedResourceProvider = PackedResourceProvider(e.target);
					p.removeEventListener(Event.OPEN, onPackedResourceProviderEvent);
					p.removeEventListener(IOErrorEvent.IO_ERROR, onPackedResourceProviderEvent);
					/* Map the PackedResourceProvider by ID. */
					_resourceProviders[p.id] = p;
				}
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
		 */
		internal function init(main:Main, resourceManager:ResourceManager,
			resourceBundleClass:Class = null):void
		{
			_main = main;
			_resourceManager = resourceManager;
			
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
		 * @private
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
					p = new EmbeddedResourceProvider(_main, _resourceManager);
					p.init(resourceBundle);
					_resourceProviders[EmbeddedResourceProvider.ID] = p;
				}
			}
		}
		
		
		/**
		 * This method loads the resource index file (resources.xml or resources.tem) and
		 * haves all resources listed in the index file being registered so they can be
		 * loaded with the Resource Manager.
		 * 
		 * @private
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
				p = new LoadedResourceProvider(_main, _resourceManager);
				p.init();
				_resourceProviders[LoadedResourceProvider.ID] = p;
				
				_indexLoader = new ResourceIndexLoader(_main, _resourceIndex);
				_indexLoader.addEventListener(Event.COMPLETE, onResourceIndexFileProcessed);
				_indexLoader.addEventListener(ErrorEvent.ERROR, onResourceIndexFileProcessed);
				_indexLoader.load();
			}
			else
			{
				Log.debug("Resource index file not loaded!", this);
				onResourceIndexFileProcessed(new Event(Event.COMPLETE));
			}
		}
		
		
		/**
		 * Creates a PackedResourceProvider for every resource package file and opens the
		 * associated resource package file so that resources can be loaded from it.
		 * 
		 * @private
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
					var p:PackedResourceProvider = new PackedResourceProvider(_main,
						_resourceManager, packageID);
					if (p.init(name))
					{
						p.addEventListener(Event.OPEN, onPackedResourceProviderEvent);
						p.addEventListener(IOErrorEvent.IO_ERROR, onPackedResourceProviderEvent);
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
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		private function toString():String
		{
			return "[ResourceManagerHelper]";
		}
	}
}
