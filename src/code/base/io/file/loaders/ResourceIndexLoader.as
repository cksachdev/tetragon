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
	import base.core.debug.Log;
	import base.data.Registry;
	import base.io.resource.ResourceFamily;
	import base.io.resource.ResourceIndex;

	import com.hexagonstar.file.FileIOEvent;
	import com.hexagonstar.file.types.IFile;
	import com.hexagonstar.file.types.XMLFile;
	import com.hexagonstar.file.types.ZipFile;

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
		public function ResourceIndexLoader(resourceIndex:ResourceIndex)
		{
			super();
			
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
			_resourceIndex = null;
		}
		
		
		/**
		 * Returns a string representation of ResourceIndexLoader.
		 * 
		 * @return A string representation of ResourceIndexLoader.
		 */
		override public function toString():String
		{
			return "ResourceIndexLoader";
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
			var path:String = f.path.substring(0, f.path.lastIndexOf(".")) + ".rif";
			
			Log.debug("\"" + f.path + "\" not found, trying to load \"" + path + "\" instead ...",
				this);
			
			_files.enqueue(new ZipFile(path, "resourceIndexFile"));
			_loader.addFileQueue(_files);
			_loader.load();
		}
		
		
		/**
		 * Initiates parsing of different resource index entries.
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
			parseLists(xml);
			parseData(xml);
			parseEntities(xml);
			parseText(xml);
			
			CONFIG::IS_AIR_BUILD
			{
				System.disposeXML(xml);
			}
			
			Log.debug("Parsed " + _resCount + " resource entries.", this);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * Parses the package file and data file reference entries.
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
							addResourceEntry(c, resourceClassID, ResourceFamily.MEDIA, null);
						}
					}
					else
					{
						addResourceEntry(s, resourceClassID, ResourceFamily.MEDIA, null);
					}
				}
			}
		}
		
		
		/**
		 * Parses list resource entries.
		 * @private
		 */
		private function parseLists(xml:XML):void
		{
			for each (var x:XML in xml.lists.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					var fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					var dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.LIST, type);
				}
			}
		}
		
		
		/**
		 * Parses data resource entries.
		 * @private
		 */
		private function parseData(xml:XML):void
		{
			for each (var x:XML in xml.data.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					/* If all resources of the group are in the same data file, the
					 * data file ID can be specified globally for all resources instead
					 * of having any resource repeat the same data file ID so if we got
					 * a global data file ID use that one instead. */
					var fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					var dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.DATA, type);
				}
			}
		}
		
		
		/**
		 * Parses entity resource entries.
		 * @private
		 */
		private function parseEntities(xml:XML):void
		{
			for each (var x:XML in xml.entities.group)
			{
				var type:String = x.@type;
				var allFileID:String = "" + x.@fileID;
				for each (var s:XML in x.children())
				{
					if (s.name() != "resource") continue;
					
					var fileID:String = allFileID.length > 0 ? allFileID : s.@fileID;
					var dfp:String = _resourceIndex.getDataFilePath(fileID);
					
					if (!dfp || dfp.length < 1)
					{
						Log.error("No data file with ID \"" + s.@fileID
							+ "\" defined in resource index but the resource with ID \""
							+ s.@id + "\" requires it.", this);
						continue;
					}
					
					s.@path = dfp;
					s.@packageID = _resourceIndex.getDataFilePackageID(fileID);
					addResourceEntry(s, ResourceFamily.DATA, ResourceFamily.ENTITY, type);
				}
			}
		}
		
		
		/**
		 * Parses text resource entries.
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
					addResourceEntry(s, ResourceFamily.TEXT, ResourceFamily.TEXT, null);
				}
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param resourceXML
		 * @param wrapperClassID
		 * @param resourceFamily
		 * @param resourceType Only used for data and entity resource families.
		 */
		private function addResourceEntry(resourceXML:XML, wrapperClassID:String,
			resourceFamily:String, resourceType:String):void
		{
			var id:String = resourceXML.@id;
			var path:String = resourceXML.@path;
			var packageID:String = resourceXML.@packageID;
			var dataFileID:String = resourceXML.@fileID;
			var rc:Class = Main.instance.dataSupportManager.getResourceWrapperClassByID(wrapperClassID);
			
			if (!rc)
			{
				Log.warn("No resource file type wrapper class found for resource with ID \"" + id
					+ "\" (wrapperClassID: " + wrapperClassID + ").", this);
			}
			
			_resourceIndex.addResource(id, path, packageID, dataFileID, rc, resourceFamily, resourceType);
			_resCount++;
		}
	}
}
