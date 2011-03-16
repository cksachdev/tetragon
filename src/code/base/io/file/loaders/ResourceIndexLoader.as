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
package base.io.file.loaders
{
	import base.Main;
	import base.data.Registry;
	import base.io.resource.ResourceGroup;
	import base.io.resource.ResourceIndex;
	import base.io.resource.resourceTypeMap;
	import base.util.Log;

	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.IFile;
	import com.hexagonstar.io.file.types.XMLFile;
	import com.hexagonstar.io.file.types.ZipFile;

	import flash.events.Event;
	import flash.system.System;

	
	/**
	 * The ResourceIndexLoader loads the resource index file and parses it into the
	 * ResourceIndex.
	 */
	public class ResourceIndexLoader extends FileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _locale:String;
		/** @private */
		private var _state:int;
		/** @private */
		private var _resCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceIndexLoader(main:Main, resourceIndex:ResourceIndex)
		{
			super(main);
			
			_resourceIndex = resourceIndex;
			_locale = Registry.config.currentLocale;
			_state = 0;
			_resCount = 0;
			
			/* Create resource index file path */
			var path:String = Registry.config.resourceFolder;
			if (path == null) path = "";
			if (path.length > 0) path += "/";
			path += Registry.config.resourceIndexFile;
			
			addFile(path, "resourceIndexFile");
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Disposes the loader.
		 */
		override public function dispose():void
		{
			super.dispose();
			_main = null;
			_resourceIndex = null;
		}
		
		
		/**
		 * Returns a string representation of ResourceIndexLoader.
		 * 
		 * @return A string representation of ResourceIndexLoader.
		 */
		override public function toString():String
		{
			return "[ResourceIndexLoader]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Called everytime after a file load has been completed.
		 * @private
		 */
		override public function onFileComplete(e:FileIOEvent):void
		{
			super.onFileComplete(e);
		}
		
		
		/**
		 * Called after all file loads have been completed.
		 * @private
		 */
		override public function onAllFilesComplete(e:FileIOEvent):void
		{
			switch (_state)
			{
				case 0:
				case 2:
					/* Non-packed or packed file was loaded successfully! */
					parse(e.file);
					return;
				case 1:
					/* Non-packed index file could not be found so
					 * try loading the packed version. */
					_state = 2;
					loadPacked();
					return;
				case 3:
					/* Neither packed or nonpacked could be loaded! */
			}
			
			super.onAllFilesComplete(e);
		}
		
		
		/**
		 * Abstract Method.
		 */
		override public function onFileIOError(e:FileIOEvent):void
		{
			if (_state == 0)
			{
				_state = 1;
				return;
			}
			else if (_state == 2)
			{
				_state = 3;
				notifyLoadError(e);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Loads the packed version of the resource index file in case the non-packed
		 * version was not found.
		 * 
		 * @private
		 */
		private function loadPacked():void
		{
			_loader.reset();
			
			/* Change file path to use the packed version. */
			var f:IFile = _files.dequeue();
			var path:String = f.path.substring(0, f.path.lastIndexOf(".")) + ".tem";
			
			Log.debug("\"" + f.path + "\" not found, trying to load \"" + path + "\" instead ...",
				this);
			
			_files.enqueue(new ZipFile(path, "resourceIndexFile"));
			_loader.addFileQueue(_files);
			_loader.load();
		}
		
		
		/**
		 * Initiates parsing of different resource index entries.
		 * 
		 * @private
		 */
		private function parse(file:IFile):void
		{
			if (!file.valid)
			{
				Log.error("Error parsing file: data structure of resource index file is invalid. ("
					+ file.status + ")", this);
				return;
			}
			
			var xmlFile:XMLFile;
			if (file is ZipFile)
			{
				xmlFile = XMLFile(ZipFile(file).getFile(Registry.config.resourceIndexFile));
			}
			else
			{
				xmlFile = XMLFile(file);
			}
			
			var xml:XML = xmlFile.contentAsXML;
			parseReferences(xml);
			parseMedia(xml);
			parseData(xml);
			parseText(xml);
			
			CONFIG::IS_AIR
			{
				System.disposeXML(xml);
			}
			
			Log.debug("Parsed " + _resCount + " resource entries.", this);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * Parses the package file and data file reference entries.
		 * 
		 * @private
		 */
		private function parseReferences(xml:XML):void
		{
			var x:XML;
			/* Parse package file entries. */
			for each (x in xml.packageFiles.file)
			{
				_resourceIndex.addPackageFileEntry(x.@id, x.@path);
			}
			/* Parse data file entries. */
			for each (x in xml.dataFiles.file)
			{
				_resourceIndex.addDataFileEntry(x.@id, x.@path, x.@packageID);
			}
		}
		
		
		/**
		 * Parses media resource entries.
		 * 
		 * @private
		 */
		private function parseMedia(xml:XML):void
		{
			for each (var x:XML in xml.media.*)
			{
				var topNodeName:String = x.name();
				var resourceClassID:String = topNodeName;
				
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource")
					{
						resourceClassID = topNodeName + "-" + s.name();
						for each (var c:XML in s.children())
						{
							addResourceEntry(c, resourceClassID, ResourceGroup.MEDIA);
						}
					}
					else
					{
						addResourceEntry(s, resourceClassID, ResourceGroup.MEDIA);
					}
				}
			}
		}
		
		
		/**
		 * Parses data resource entries.
		 * 
		 * @private
		 */
		private function parseData(xml:XML):void
		{
			for each (var x:XML in xml.data.group)
			{
				var type:String = x.@type;
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					var dfp:String = _resourceIndex.getDataFilePath(s.@fileID);
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(s.@fileID);
					addResourceEntry(s, ResourceGroup.DATA, type);
				}
			}
		}
		
		
		/**
		 * Parses text resource entries.
		 * 
		 * @private
		 */
		private function parseText(xml:XML):void
		{
			for each (var x:XML in xml.elements("text").resource)
			{
				var id:String = x.@id;
				
				for each (var s:XML in x.locale)
				{
					var lang:String = s.@lang;
					if (lang != _locale) continue;
					var path:String = s.@path;
					
					/* If text entry for current locale is not available, use default locale! */
					if (!path || path.length < 1)
					{
						s = x.locale.(@lang == _main.config.defaultLocale)[0];
					}
					
					s.@id = id;
					addResourceEntry(s, ResourceGroup.TEXT, ResourceGroup.TEXT);
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function addResourceEntry(r:XML, resourceClassID:String, type:String = null):void
		{
			var id:String = r.@id;
			var path:String = r.@path;
			var packageID:String = r.@packageID;
			var dataFileID:String = r.@fileID;
			var rc:Class = resourceTypeMap[resourceClassID];
			
			if (!rc)
			{
				Log.warn("No resource class found for resource with ID \"" + id
					+ "\" (resourceClassID: " + resourceClassID + ").", this);
			}
			
			_resourceIndex.addResource(id, path, packageID, dataFileID, rc, type);
			_resCount++;
		}
	}
}
