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
package base.data
{
	import base.core.debug.Log;
	import base.core.entity.IEntityComponent;
	import base.data.parsers.EntityDataParser;
	import base.data.parsers.IDataParser;
	import base.data.parsers.NullDataParser;
	import base.data.parsers.SettingsDataParser;
	import base.data.parsers.TextDataParser;
	import base.data.parsers.XMLDataParser;
	import base.io.resource.ResourceFamily;
	import base.io.resource.wrappers.*;

	import com.hexagonstar.types.*;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	/**
	 * An odd multi-role class that manages the mapping and creation of several objects
	 * used by the resource management and the entity system. It acts as an index for
	 * parser-, entity component- and complex type classes by mapping data parser classes
	 * to datatype IDs and entity component classes to component class IDs.
	 */
	public class DataSupportManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Maps resource file type wrapper class definitions by string key.
		 * @private
		 */
		private var _resourceFileTypeMap:Object;
		
		/**
		 * Maps resource file type wrapper class definitions by string file extensions.
		 * @private
		 */
		private var _fileTypeExtensionMap:Object;
		
		/**
		 * Maps class definitions of complex types that are used in entity component
		 * definitions by a string key.
		 * @private
		 */
		private var _complexTypeMap:Object;
		
		/**
		 * Maps class definitions of type IResourceParser by datatype string keys.
		 * @private
		 */
		private var _dataTypeMap:Object;
		
		/**
		 * Maps class definitions of type IEntityComponent by class ID string keys.
		 * @private
		 */
		private var _componentMap:Object;
		
		/**
		 * Counter used to create unique entity component IDs.
		 * @private
		 */
		private var _componentIDCount:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function DataSupportManager()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the factory.
		 */
		public function init():void
		{
			_resourceFileTypeMap = {};
			_fileTypeExtensionMap = {};
			_complexTypeMap = {};
			_dataTypeMap = {};
			_componentMap = {};
			_componentIDCount = 0;
			
			/* Map default resource file types. */
			mapResourceFileType(ImageResourceWrapper, ["image", "image-opaque"], ["jpg", "jpeg", "gif"]);
			mapResourceFileType(Image32ResourceWrapper, ["image-transparent", "image-vector"], ["png", "svg", "svgz"]);
			mapResourceFileType(SWFResourceWrapper, ["swf"], ["swf"]);
			mapResourceFileType(XMLResourceWrapper, ["data", "text"], ["xml", "txt", "ini", "css", "htm", "html"]);
			mapResourceFileType(BinaryResourceWrapper, ["binary", "shader"], ["obj", "pbj", "bin"]);
			mapResourceFileType(SoundResourceWrapper, ["audio-stream"], ["mp3"]);
			mapResourceFileType(null, ["audio-module"], ["mod"]); // TODO
			
			/* Map default complex types. */
			mapComplexType("array", Array);
			mapComplexType("rectangle", Rectangle);
			mapComplexType("point", Point);
			mapComplexType("point2d", Point2D);
			mapComplexType("point3d", Point3D);
			mapComplexType("vector2d", Vector2D);
			
			/* Map default data types. */
			mapDataType(ResourceFamily.NONE, NullDataParser);
			mapDataType(ResourceFamily.TEXT, TextDataParser);
			mapDataType(ResourceFamily.XML, XMLDataParser);
			mapDataType(ResourceFamily.ENTITY, EntityDataParser);
			mapDataType(ResourceFamily.SETTINGS, SettingsDataParser);
		}
		
		
		/**
		 * Maps a resource file type wrapper class by one or more fileType ID strings.
		 * Optionally they are also mapped by file extensions, if specified. File
		 * extensions are only of importance for embedded resource files.
		 * 
		 * @param wrapperClass The class to map.
		 * @param fileTypeIDs An array of keys to map the class under.
		 * @param fileTypeExtensions An array of file extensions to map the class under.
		 */
		public function mapResourceFileType(wrapperClass:Class, fileTypeIDs:Array,
			fileTypeExtensions:Array = null):void
		{
			var key:String;
			for each (key in fileTypeIDs)
				_resourceFileTypeMap[key.toLowerCase()] = wrapperClass;
			for each (key in fileTypeExtensions)
				_fileTypeExtensionMap[key.toLowerCase()] = wrapperClass;
		}
		
		
		/**
		 * Maps complex data types by ID which are used in entity component definitions.
		 * 
		 * @param complexTypeID The ID of the compex data type.
		 * @param clazz The class to map.
		 */
		public function mapComplexType(complexTypeID:String, clazz:Class):void
		{
			if (complexTypeID == null || clazz == null) return;
			_complexTypeMap[complexTypeID.toLowerCase()] = clazz;
		}
		
		
		/**
		 * Maps the specified parser class and optionally the specified builder class under
		 * the given dataTypeID. The parser class must implement IResourceParser and the
		 * builder class must implement IEntityBuilder.
		 * 
		 * @param dataTypeID The ID of the data type.
		 * @param parserClass The parser class to map.
		 */
		public function mapDataType(dataTypeID:String, parserClass:Class):void
		{
			if (dataTypeID == null || parserClass == null) return;
			_dataTypeMap[dataTypeID.toLowerCase()] = parserClass;
		}
		
		
		/**
		 * Maps the specified component class ID to the specified component class.
		 * The component class must implement IEntityComponent.
		 * 
		 * @param classID The ID of the component class.
		 * @param componentClass The component class to map.
		 */
		public function mapComponentClass(classID:String, componentClass:Class):void
		{
			if (classID == null || componentClass == null) return;
			_componentMap[classID.toLowerCase()] = componentClass;
		}
		
		
		/**
		 * Returns a resource file type wrapper class that is mapped by the given ID.
		 * 
		 * @param fileTypeID
		 * @return A resource wrapper class.
		 */
		public function getResourceWrapperClassByID(fileTypeID:String):Class
		{
			if (fileTypeID == null) return null;
			return _resourceFileTypeMap[fileTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a resource file type wrapper class that is mapped by the given file
		 * type extension.
		 * 
		 * @param fileExtension
		 * @return A resource wrapper class.
		 */
		public function getResourceWrapperClassByExtension(fileExtension:String):Class
		{
			if (fileExtension == null) return null;
			return _fileTypeExtensionMap[fileExtension.toLowerCase()];
		}
		
		
		/**
		 * Returns a complex type class definition that is mapped under the specified
		 * complexTypeID.
		 * 
		 * @param complexTypeID The ID with that the complex type class is mapped.
		 * @return A class or null if the ID is not mapped.
		 */
		public function getComplexTypeClass(complexTypeID:String):Class
		{
			if (complexTypeID == null) return null;
			return _complexTypeMap[complexTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a parser class definition that is mapped under the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID with that the parser class is mapped.
		 * @return A parser class of type IResourceParser or null if the ID is not mapped.
		 */
		public function getDataTypeParserClass(dataTypeID:String):Class
		{
			if (dataTypeID == null) return null;
			return _dataTypeMap[dataTypeID.toLowerCase()];
		}
		
		
		/**
		 * Returns a component class definition that is mapped under the specified classID.
		 * 
		 * @param classID The ID with that the class is mapped.
		 * @return A component class of type IEntityComponent or null if the ID is not mapped.
		 */
		public function getEntityComponentClass(classID:String):Class
		{
			if (classID == null) return null;
			return _componentMap[classID.toLowerCase()];
		}
		
		
		/**
		 * Creates a new data parser that is associated with the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID of the data type for which to create a parser.
		 * @return A parser of type IDataParser.
		 */
		public function createDataTypeParser(dataTypeID:String):IDataParser
		{
			if (dataTypeID == null) return null;
			var clazz:* = _dataTypeMap[dataTypeID.toLowerCase()];
			var parser:IDataParser;
			if (!clazz)
			{
				fail("Failed to create parser class! No parser class has been mapped for"
					+ " dataTypeID \"" + dataTypeID + "\".");
				return null;
			}
			try
			{
				parser = new clazz();
			}
			catch (err:Error)
			{
				fail("Failed to create parser class! The parser class mapped for dataTypeID \""
					+ dataTypeID + "\" is not of type IResourceParser.");
				return null;
			}
			return parser;
		}
		
		
		/**
		 * Creates a new entity component that is associated with the specified classID.
		 * 
		 * @param classID The ID of the component class from which to create an instance.
		 * @return A component of type IEntityComponent.
		 */
		public function createEntityComponent(classID:String):IEntityComponent
		{
			if (classID == null) return null;
			var clazz:* = _componentMap[classID.toLowerCase()];
			var component:IEntityComponent;
			
			if (!clazz)
			{
				fail("Failed to create component class! No component class has been mapped for"
				+ " classID \"" + classID + "\".");
				return null;
			}
			try
			{
				component = new clazz();
			}
			catch (err:Error)
			{
				fail("Failed to create component class! The component class mapped for classID \""
					+ classID + "\" is not of type IEntityComponent.");
				return null;
			}
			component.id = "component" + _componentIDCount;
			_componentIDCount++;
			return component;
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "DataSupportManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
