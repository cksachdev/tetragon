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
package base.core.entity
{
	import base.core.debug.Log;

	import com.hexagonstar.ioc.Injector;

	import flash.utils.Dictionary;
	
	
	/**
	 * EntityFactory class
	 */
	public class EntityFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _injector:Injector;
		/** @private */
		private var _builderMap:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param injector The DI injector used to instantiate builder classes.
		 */
		public function EntityFactory(injector:Injector)
		{
			_injector = injector;
			_builderMap = new Dictionary();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a builder in the factory.
		 * 
		 * @param builderClass The class of the builder to register. Must implement
		 *        IEntityBuilder!
		 */
		public function registerBuilder(builderClass:Class):void
		{
			var builder:IEntityBuilder = _injector.instantiate(builderClass);
			if (builder)
			{
				_builderMap[builderClass] = builder;
				Log.debug(toString() + " Registered entity builder: " + builder.toString());
			}
			else
			{
				Log.error(toString() + " Could not register entity builder of type: "
					+ builderClass);
			}
		}
		
		
		/**
		 * Creates an entity of the type that is built by the specified builderClass.
		 * 
		 * @param builderClass The builder class which should create an entity.
		 * @return An IEntity created by the specified builderClass or null.
		 */
		public function createEntity(builderClass:Class):IEntity
		{
			var builder:IEntityBuilder = _builderMap[builderClass];
			if (builder)
			{
				return builder.build();
			}
			
			Log.error(toString() + " Could not create entity from builder: " + builderClass);
			return null;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[EntityFactory]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
