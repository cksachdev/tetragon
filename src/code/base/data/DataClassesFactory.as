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
	import base.core.entity.IEntityBuilder;
	import base.core.entity.IEntityComponent;
	import base.data.parsers.IDataParser;
	import base.data.parsers.NullDataParser;
	import base.data.parsers.TextDataParser;
	import base.io.resource.ResourceGroup;

	import com.hexagonstar.exception.SingletonException;

	
	/**
	 * A singleton factory that acts as an index for parser, builder and component
	 * classes by mapping data parser classes and entity builder classes to datatype
	 * IDs and entity component classes to component class IDs.
	 */
	public class DataClassesFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:DataClassesFactory;
		/** @private */
		private static var _singletonLock:Boolean = false;
		
		/**
		 * Maps class definitions of type IResourceParser.
		 * @private
		 */
		private var _parserMap:Object;
		
		/**
		 * Maps class definitions of type IEntityBuilder.
		 * @private
		 */
		private var _builderMap:Object;
		
		/**
		 * Maps class definitions of type IEntityComponent.
		 * @private
		 */
		private var _componentMap:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function DataClassesFactory()
		{
			if (!_singletonLock) throw new SingletonException(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the factory.
		 */
		public function init():void
		{
			_parserMap = {};
			_builderMap = {};
			_componentMap = {};
			
			/* Add default data types. */
			mapDataType(ResourceGroup.NONE, NullDataParser);
			mapDataType(ResourceGroup.TEXT, TextDataParser);
			//addDataType("XML", XMLDataParser); // TODO
		}
		
		
		/**
		 * Maps the specified parser class and optionally the specified builder class under
		 * the given dataTypeID. The parser class must implement IResourceParser and the
		 * builder class must implement IEntityBuilder.
		 * 
		 * @param dataTypeID The ID of the data type.
		 * @param parserClass The parser class to map.
		 * @param builderClass The builder class to map.
		 */
		public function mapDataType(dataTypeID:String, parserClass:Class,
			builderClass:Class = null):void
		{
			_parserMap[dataTypeID] = parserClass;
			if (builderClass) _builderMap[dataTypeID] = builderClass;
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
			_componentMap[classID] = componentClass;
		}
		
		
		/**
		 * Returns a parser class definition that is mapped under the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID with that the parser class is mapped.
		 * @return A parser class of type IResourceParser or null if the ID is not mapped.
		 */
		public function getParserClass(dataTypeID:String):Class
		{
			return _parserMap[dataTypeID];
		}
		
		
		/**
		 * Returns a builder class definition that is mapped under the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID with that the builder class is mapped.
		 * @return A builder class of type IEntityBuilder or null if the ID is not mapped.
		 */
		public function getBuilderClass(dataTypeID:String):Class
		{
			return _builderMap[dataTypeID];
		}
		
		
		/**
		 * Returns a component class definition that is mapped under the specified classID.
		 * 
		 * @param classID The ID with that the class is mapped.
		 * @return A component class of type IEntityComponent or null if the ID is not mapped.
		 */
		public function getComponentClass(classID:String):Class
		{
			return _componentMap[classID];
		}
		
		
		/**
		 * Creates a new data parser that is associated with the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID of the data type for which to create a parser.
		 * @return A parser of type IDataParser.
		 */
		public function createParser(dataTypeID:String):IDataParser
		{
			var clazz:* = _parserMap[dataTypeID];
			var parser:IDataParser;
			if (!clazz)
			{
				Log.error(toString() + " Failed to create parser class! No parser class has been"
					+ " mapped for dataTypeID \"" + dataTypeID + "\".");
				return null;
			}
			try
			{
				parser = new clazz();
			}
			catch (err:Error)
			{
				Log.error(toString() + " Failed to create parser class! The parser class mapped"
					+ " for dataTypeID \"" + dataTypeID + "\" is not of type IResourceParser.");
				return null;
			}
			return parser;
		}
		
		
		/**
		 * Creates a new entity builder that is associated with the specified dataTypeID.
		 * 
		 * @param dataTypeID The ID of the data type for which to create a builder.
		 * @return A builder of type IEntityBuilder.
		 */
		public function createBuilder(dataTypeID:String):IEntityBuilder
		{
			var clazz:* = _builderMap[dataTypeID];
			var builder:IEntityBuilder;
			if (!clazz)
			{
				Log.error(toString() + " Failed to create builder class! No builder class has been"
					+ " mapped for dataTypeID \"" + dataTypeID + "\".");
				return null;
			}
			try
			{
				builder = new clazz();
			}
			catch (err:Error)
			{
				Log.error(toString() + " Failed to create builder class! The builder class mapped"
					+ " for dataTypeID \"" + dataTypeID + "\" is not of type IEntityBuilder.");
				return null;
			}
			return builder;
		}
		
		
		/**
		 * Creates a new entity component that is associated with the specified classID.
		 * 
		 * @param classID The ID of the component class from which to create an instance.
		 * @return A component of type IEntityComponent.
		 */
		public function createComponent(classID:String):IEntityComponent
		{
			var clazz:* = _componentMap[classID];
			var component:IEntityComponent;
			if (!clazz)
			{
				Log.error(toString() + " Failed to create component class! No component class has"
					+ " been mapped for classID \"" + classID + "\".");
				return null;
			}
			try
			{
				component = new clazz();
			}
			catch (err:Error)
			{
				Log.error(toString() + " Failed to create component class! The component class"
					+ " mapped for classID \"" + classID + "\" is not of type IEntityComponent.");
				return null;
			}
			return component;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[DataClassesFactory]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the singleton instance of the class.
		 */
		public static function get instance():DataClassesFactory
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new DataClassesFactory();
				_singletonLock = false;
			}
			return _instance;
		}
	}
}
