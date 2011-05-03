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
	import base.data.DataClassesFactory;
	import base.io.resource.Resource;
	import base.io.resource.ResourceManager;
	
	
	/**
	 * EntityFactory class
	 */
	public class EntityFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _builderCache:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityFactory()
		{
			_builderCache = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates an entity from the entity template of the specified id.
		 * 
		 * @param id The ID of the data resource from which to create an entity.
		 * @return An object of type IEntity or null.
		 */
		public function createEntity(id:String):IEntity
		{
			var resource:Resource = ResourceManager.resourceIndex.getResource(id);
			var dataTypeID:String = resource.dataType;
			var builder:IEntityBuilder;
			
			if (!_builderCache[dataTypeID])
			{
				var builderClass:Class = DataClassesFactory.instance.getBuilderClass(dataTypeID);
				builder = new builderClass();
				if (builder)
				{
					_builderCache[dataTypeID] = builder;
					Log.debug(toString() + " Cached entity builder: " + builder.toString());
				}
				else
				{
					Log.error(toString() + " Could not create entity builder of type: "
						+ builderClass, this);
					return null;
				}
			}
			else
			{
				builder = _builderCache[dataTypeID];
			}
			
			return builder.build(resource.content);
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
