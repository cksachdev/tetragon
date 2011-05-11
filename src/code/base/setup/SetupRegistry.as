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
package base.setup
{
	import base.Main;
	import base.core.debug.Log;
	import base.core.entity.EntitySystemManager;
	import base.data.DataSupportManager;
	import base.state.StateManager;
	import base.view.screen.ScreenManager;

	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Abstract base class for setup registry classes.
	 */
	public class SetupRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stateManager:StateManager;
		private var _screenManager:ScreenManager;
		private var _entitySystemManager:EntitySystemManager;
		private var _dsm:DataSupportManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SetupRegistry()
		{
			_stateManager = Main.instance.stateManager;
			_screenManager = Main.instance.screenManager;
			_entitySystemManager = Main.instance.entitySystemManager;
			_dsm = Main.instance.dataSupportManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Executes the setup registry.
		 */
		public function execute():void
		{
			registerResourceFileTypes();
			registerComplexTypes();
			registerDataTypes();
			registerEntitySystems();
			registerEntityComponents();
			registerStates();
			registerScreens();
		}
		
		
		/**
		 * Used to register any resource file types to resource file type wrapper classes
		 * for the extra package that this setup is part of. Use the
		 * <code>registerFileType()</code> method inside this method to register any file
		 * types.
		 * 
		 * <p>The engine already maps standard resource file types for image files, data
		 * files, audio files etc. automatically but you can use this method to register
		 * any additional file types.</p>
		 * 
		 * @example
		 * <pre>
		 *    // Register CustomResourceWrapper class to ID "custom" and to file
		 *    // extensions "cst" and "cust" ...
		 *    registerFileType(CustomResourceWrapper, ["custom"], ["cst", "cust"]);
		 * </pre>
		 */
		public function registerResourceFileTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any complex data type classes that are used in entity
		 * component definitions. Complex data types are any data types other than the
		 * basic types like String, Number, Boolean etc. For example Rectangle and Point
		 * would be complex data types. Use the <code>registerComplexType()</code> method
		 * inside this method to register any complex data types.
		 * 
		 * <p>The engine already maps standard complex data types such as Rectangle, Point
		 * Point2D, Point3D etc. automatically but you can use this method to register
		 * any additional types.</p>
		 * 
		 * @example
		 * <pre>
		 *    registerComplexType("customtype", CustomTypeClass);
		 * </pre>
		 */
		public function registerComplexTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register any resource data types that require a parser to parse their
		 * data into data objects for the engine. Registering data types is only relevant
		 * for resources defined in the resource index file under the 'data' resource
		 * family. Entity resources are all parsed by the <code>EntityDataParser</code>.
		 * Use the <code>registerDataType</code> method inside this method to register
		 * any custom data types.
		 * 
		 * @example
		 * <pre>
		 *    // Register a data resource type that is defined in the resource index
		 *    // file with group type="MyGameDataResource" ...
		 *    registerDataType("MyGameDataResource", MyGameDataResourceParser);
		 * </pre>
		 */
		public function registerDataTypes():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register entity systems.
		 */
		public function registerEntitySystems():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register entity components.
		 */
		public function registerEntityComponents():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register states.
		 */
		public function registerStates():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to register screens.
		 */
		public function registerScreens():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * @param wrapperClass
		 * @param fileTypeIDs
		 * @param fileTypeExtensions
		 */
		protected function registerFileType(wrapperClass:Class, fileTypeIDs:Array,
			fileTypeExtensions:Array = null):void
		{
			_dsm.mapResourceFileType(wrapperClass, fileTypeIDs, fileTypeExtensions);
			Log.debug("Registered resource file type for IDs \"" + fileTypeIDs + "\".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param complexTypeID
		 * @param clazz
		 */
		protected function registerComplexType(complexTypeID:String, clazz:Class):void
		{
			_dsm.mapComplexType(complexTypeID, clazz);
			Log.debug("Registered complex type for ID \"" + complexTypeID + "\".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param dataTypeID
		 * @param dataTypeParserClass
		 */
		protected function registerDataType(dataTypeID:String, dataTypeParserClass:Class):void
		{
			_dsm.mapDataType(dataTypeID, dataTypeParserClass);
			Log.debug("Registered datatype parser class for ID \"" + dataTypeID + "\".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param systemClass
		 */
		protected function registerEntitySystem(systemClass:Class):void
		{
			_entitySystemManager.registerSystem(systemClass);
			Log.debug("Registered entity system class: " + systemClass + ".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param classID
		 * @param componentClass
		 */
		protected function registerEntityComponent(classID:String, componentClass:Class):void
		{
			_dsm.mapComponentClass(classID, componentClass);
			Log.debug("Registered entity component class for ID \"" + classID + "\".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param stateID
		 * @param stateClass
		 */
		protected function registerState(stateID:String, stateClass:Class):void
		{
			_stateManager.registerState(stateID, stateClass);
			Log.debug("Registered state class for ID \"" + stateID + "\".", this);
		}
		
		
		/**
		 * @private
		 * 
		 * @param screenID
		 * @param screenClass
		 */
		protected function registerScreen(screenID:String, screenClass:Class):void
		{
			_screenManager.registerScreen(screenID, screenClass);
			Log.debug("Registered screen class for ID \"" + screenID + "\".", this);
		}
	}
}
