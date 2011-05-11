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
	import base.core.debug.Log;
	import base.data.DataObject;

	import com.hexagonstar.util.string.TabularText;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	/**
	 * The ResourceIndex is the storage index for all resources that can be loaded.
	 */
	public class ResourceIndex
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map that stores all package file entries by their ID.
		 * @private
		 */
		internal var _packageFiles:Object;
		
		/**
		 * A map that stores all settings file entries.
		 * @private
		 */
		private var _settingsFiles:Object;
		
		/**
		 * A map that stores all data file entries. Contains ResourceDataFileEntry objects.
		 * @private
		 */
		private var _dataFiles:Object;
		
		/**
		 * A map that stores all resources. Contains Resource objects.
		 * @private
		 */
		private var _resources:Object;
		
		/**
		 * @private
		 */
		private var _size:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ResourceIndex()
		{
			clear();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Clears all resource entries from the resource index.
		 */
		public function clear():void
		{
			_packageFiles = {};
			_settingsFiles = {};
			_dataFiles = {};
			_resources = {};
			_size = 0;
		}
		
		
		/**
		 * Adds a package file entry.
		 * 
		 * @param id The ID of the package file entry.
		 * @param path The path of the package file entry.
		 */
		public function addPackageFileEntry(id:String, path:String):void
		{
			_packageFiles[id] = path;
		}
		
		
		/**
		 * Adds a data file entry.
		 * 
		 * @param id The ID of the data file entry.
		 * @param path The path of the data file entry.
		 * @param packageID The package ID of the data file entry.
		 */
		public function addDataFileEntry(id:String, path:String, packageID:String):void
		{
			_dataFiles[id] = new ResourceDataFileEntry(path, packageID);
		}
		
		
		/**
		 * Returns the package path (filename) that is stored under the specified package ID.
		 * 
		 * @param id The ID of the package file entry.
		 * @return The path (file name) of the package file entry.
		 */
		public function getPackagePath(id:String):String
		{
			return _packageFiles[id];
		}
		
		
		/**
		 * Returns the path of the data file entry that is mapped under the specified ID.
		 * 
		 * @param id The ID of the data file entry for which to return the path.
		 * @return The path of the data file entry.
		 */
		public function getDataFilePath(id:String):String
		{
			if (_dataFiles[id])
			{
				return ResourceDataFileEntry(_dataFiles[id]).path;
			}
			Log.error("No dataFilePath mapped for dataFileID \"" + id + "\".", this);
			return null;
		}
		
		
		/**
		 * Returns the package ID of the data file entry that is mapped under the specified ID.
		 * 
		 * @param id The ID of the data file entry for which to return the package ID.
		 * @return The package ID of the data file entry.
		 */
		public function getDataFilePackageID(id:String):String
		{
			if (_dataFiles[id])
			{
				return ResourceDataFileEntry(_dataFiles[id]).packageID;
			}
			Log.error("No packageID mapped for dataFileID \"" + id + "\".", this);
			return null;
		}
		
		
		/**
		 * Returns an array that contains the IDs of all settings file resources.
		 * Used to load settings during application init.
		 */
		public function getSettingsFileIDs():Array
		{
			var a:Array = [];
			var type:String = ResourceFamily.SETTINGS.toLowerCase();
			for each (var e:Resource in _resources)
			{
				if (e.dataType == null) continue;
				if (e.dataType.toLowerCase() == type)
				{
					a.push(e.id);
				}
			}
			return a;
		}
		
		
		/**
		 * Adds a resource to the resource index. Note that a resource is not a concrete
		 * file resource but a data object that contains information about where to
		 * find the resource file, it's data type, whether it's embedded or not, etc. and
		 * the actual file data, once it has been loaded.
		 * 
		 * @param id The unique ID of the resource.
		 * @param path The path of the resource file, either on the filesystem or inside
		 *        a resource package file.
		 * @param packageID The package ID if the resource is packed into a package.
		 * @param dataFileID The ID of the datafile in which this resource can be found.
		 *        Media and textdata resources have no dataFileID.
		 * @param resourceFileClass The resource class of the resource.
		 * @param family The resource family of the resource.
		 * @param type The data type of the resource (if it's a data or entity resource).
		 * @param embedded Whether the resource is embedded or not.
		 */
		public function addResource(id:String, path:String, packageID:String, dataFileID:String,
			resourceFileClass:Class, family:String, type:String, embedded:Boolean = false):void
		{
			if (_resources[id] == null) _size++;
			else delete _resources[id];
			_resources[id] = new Resource(id, path, packageID, dataFileID, resourceFileClass,
				family, type, embedded);
		}
		
		
		/**
		 * Adds loaded/parsed data to a resource in the index. called by data parsers.
		 */
		public function addDataResource(content:*):void
		{
			var r:Resource;
			if (content is DataObject)
			{
				var o:DataObject = DataObject(content);
				if (o.id == null)
				{
					Log.error("Tried to add a resource whose ID is null.", this);
					return;
				}
				r = _resources[o.id];
				r.setContent(o);
			}
		}
		
		
		/**
		 * Returns the resource that is mapped under the specified ID.
		 * 
		 * @param id The ID of the resource.
		 * @return An object of type Resource.
		 */
		public function getResource(id:String):Resource
		{
			return _resources[id];
		}
		
		
		/**
		 * Returns the data type of the resource that is mapped under the specified ID.
		 * 
		 * @param id The ID of the resource.
		 * @return A string describing the data type of the resource.
		 */
		public function getResourceDataType(id:String):String
		{
			var r:Resource = _resources[id];
			if (r) return r.dataType;
			return null;
		}
		
		
		/**
		 * @private
		 */
		public function getResourceContent(id:String):*
		{
			var r:Resource = _resources[id];
			if (r) return r.content;
			return null;
		}
		
		
		/**
		 * Removes the resource that is mapped under the specified ID.
		 * 
		 * @param id The ID of the resource.
		 */
		public function removeResource(id:String):void
		{
			if (_resources[id])
			{
				delete _resources[id];
				_size--;
			}
		}
		
		
		/**
		 * Resets the resource that is mapped under the specified ID. The resource's
		 * data will be removed, it's refCount is set to 0 and it's status is set to
		 * ResourceStatus.INIT.
		 * 
		 * @param id The ID of the resource.
		 */
		public function resetResource(id:String):void
		{
			var r:Resource = _resources[id];
			if (r)
			{
				if (r.content)
				{
					/* Dispose any BitmapData before removing it. */
					if (r.content is Bitmap)
					{
						var b:Bitmap = r.content;
						if (b.bitmapData) b.bitmapData.dispose();
					}
					else if (r.content is BitmapData)
					{
						BitmapData(r.content).dispose();
					}
				}
			}
			r.reset();
		}
		
		
		/**
		 * Resets all resources.
		 */
		public function resetAll():void
		{
			for each (var r:Resource in _resources)
			{
				resetResource(r.id);
			}
		}
		
		
		/**
		 * Checks whether the resource of the specified ID is loaded or not.
		 */
		public function isResourceLoaded(id:String):Boolean
		{
			return (_resources[id] && Resource(_resources[id]).referenceCount > 0);
		}
		
		
		/**
		 * Returns a string dump of the resource list.
		 */
		public function dump(filter:String = "all"):String
		{
			var t:TabularText = new TabularText(8, true, "  ", null, "  ", 0,
				["ID", "FAMILY", "FTYPE", "TYPE", "PACKAGE", "PATH", "EMBEDDED", "REFCOUNT"]);
			
			for each (var e:Resource in _resources)
			{
				/* Apply filters. */
				if (filter == "loaded" && e.referenceCount < 1) continue;
				else if (filter == "unloaded" && e.referenceCount > 0) continue;
				
				/* Remove class part from class name. */
				var rclass:String = String(e.wrapperClass);
				if (rclass && rclass.indexOf("[class ") != -1)
				{
					rclass = rclass.substr(7, rclass.length - 8);
					var li:int = rclass.lastIndexOf("ResourceWrapper");
					if (li != -1) rclass = rclass.substr(0, li);
				}
				
				var type:String = e.dataType != null ? e.dataType : "";
				var pack:String = getPackagePath(e.packageID);
				if (pack == null) pack = "";
				
				t.add([e.id, e.family, rclass, type, pack, e.path, e.embedded, e.referenceCount]);
			}
			return toString() + " (size: " + _size + ", unloaded: " + unloadedResourceCount
				+ ", loaded: " + loadedResourceCount + ", totalRefs: " + totalRefs + ")\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "ResourceIndex";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the total amount of resources that are currently not loaded.
		 */
		public function get unloadedResourceCount():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				if (r.status != ResourceStatus.LOADED)
				{
					c++;
				}
			}
			return c;
		}
		
		
		/**
		 * Returns the total amount of resources that are currently loaded.
		 */
		public function get loadedResourceCount():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				if (r.status == ResourceStatus.LOADED)
				{
					c++;
				}
			}
			return c;
		}
		
		
		/**
		 * Returns the total amount of resource reference counts.
		 */
		public function get totalRefs():uint
		{
			var c:uint = 0;
			for each (var r:Resource in _resources)
			{
				c += r.referenceCount;
			}
			return c;
		}
	}
}
