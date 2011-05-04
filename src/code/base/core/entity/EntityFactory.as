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
	import base.Main;
	import base.core.debug.Log;
	import base.data.DataClassesFactory;
	import base.io.resource.Resource;
	import base.io.resource.ResourceIndex;
	
	
	/**
	 * EntityFactory class
	 */
	public class EntityFactory
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _resourceIndex:ResourceIndex;
		/** @private */
		private var _dcFactory:DataClassesFactory;
		/** @private */
		private var _entityManager:EntityManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityFactory()
		{
			_dcFactory = DataClassesFactory.instance;
			_entityManager = Main.instance.entityManager;
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
			var resource:Resource = resourceIndex.getResource(id);
			if (!resource)
			{
				fail("Could not create entity. Resource with ID \"" + id + "\" was null.");
				return null;
			}
			else if (!(resource.content is EntityTemplate))
			{
				fail("Could not create entity. Resource content is not of type EntityTemplate.");
				return null;
			}
			
			var e:IEntity = _entityManager.createEntity(resource.dataType);
			if (!e)
			{
				fail("Could not create entity. EntityManager.createEntity() returned null.");
				return null;
			}
			
			var mappings:Object = EntityTemplate(resource.content).componentMappings;
			
			/* Create components on entity and assign properties to them. */
			for (var classID:String in mappings)
			{
				var c:IEntityComponent = _dcFactory.createComponent(classID);
				var m:Object = mappings[classID];
				for (var property:String in m)
				{
					if (Object(c).hasOwnProperty(property))
					{
						c[property] = m[property];
					}
					else
					{
						Log.warn("Tried to set a non-existing property <" + property
							+ "> in component " + c.toString() + " for template "
							+ EntityTemplate(resource.content).toString() + ".");
					}
				}
			}
			
			return e;
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "[EntityFactory]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Lazy getter.
		 * @private
		 */
		public function get resourceIndex():ResourceIndex
		{
			if (!_resourceIndex) _resourceIndex = Main.instance.resourceManager.resourceIndex;
			return _resourceIndex;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
