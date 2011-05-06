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
	import base.data.DataClassesFactory;
	import base.view.screen.ScreenManager;

	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Abstract base class for setup registry classes.
	 */
	public class SetupRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _screenManager:ScreenManager;
		private var _entitySystemManager:EntitySystemManager;
		private var _dataClassesFactory:DataClassesFactory;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function SetupRegistry()
		{
			_screenManager = Main.instance.screenManager;
			_entitySystemManager = Main.instance.entitySystemManager;
			_dataClassesFactory = DataClassesFactory.instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Internal Methods
		//-----------------------------------------------------------------------------------------
		
		public function execute():void
		{
			registerScreens();
			registerDataTypes();
			registerComplexTypes();
			registerEntitySystems();
			registerEntityComponents();
		}
		
		
		public function registerScreens():void
		{
			/* Abstract method! */
		}
		
		
		public function registerDataTypes():void
		{
			/* Abstract method! */
		}
		
		
		public function registerComplexTypes():void
		{
			/* Abstract method! */
		}
		
		
		public function registerEntitySystems():void
		{
			/* Abstract method! */
		}
		
		
		public function registerEntityComponents():void
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
			return getQualifiedClassName(this).match("[^:]*$")[0] + ":";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
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
		
		
		/**
		 * @private
		 * 
		 * @param dataTypeID
		 * @param dataTypeParserClass
		 */
		protected function registerDataType(dataTypeID:String, dataTypeParserClass:Class):void
		{
			_dataClassesFactory.mapDataType(dataTypeID, dataTypeParserClass);
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
			_dataClassesFactory.mapComponentClass(classID, componentClass);
			Log.debug("Registered entity component class for ID \"" + classID + "\".", this);
		}
	}
}
