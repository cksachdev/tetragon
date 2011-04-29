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
	import base.core.IDisposable;

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Manages the relations between components and entites and keeps entity families
	 * up to date.
	 */
	public class EntityManager implements IDisposable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _components:Object;
		private var _families:Dictionary;
		private var _componentFamilyMap:Dictionary;
		private var _keyCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityManager()
		{
			_components = {};
			_families = new Dictionary();
			_componentFamilyMap = new Dictionary();
			_keyCount = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new entity with the id provided. If no id is provided a unique id will
		 * be auto generated. If an id is provided but the entityManager already has an entity
		 * with the same id, no entity will be created and null is returned.
		 * 
		 * @param id ID of the entity.
		 * @return The new entity or null.
		 */
		public function createEntity(id:String = null):IEntity
		{
			if (id == null || id == "")
			{
				_keyCount++;
				id = "entity" + _keyCount;
			}
			else if (_components[id])
			{
				return null;
			}
			
			var entity:IEntity = new Entity(this, id);
			_components[id] = new Dictionary();
			return entity;
		}
		
		
		/**
		 * @param id
		 * @return true if an entity with the provided id exists.
		 */
		public function hasEntity(id:String):Boolean
		{
			return _components[id] != null;
		}
		
		
		/**
		 * Unregisters an entity.
		 * 
		 * @param id
		 */
		public function removeEntity(id:String):void
		{
			for each (var c:Object in _components[id])
			{
				removeEntityFromFamilies(id, getClass(c));
			}
			delete _components[id];
		}
		
		
		/**
		 * Unregisters all entities and resets the entity manager.
		 */
		public function removeAll():void
		{
			for (var id:String in _components)
			{
				removeEntity(id);
			}
			_keyCount = 0;
		}
		
		
		/**
		 * Registers a component with an entity.
		 * 
		 * @param id The component is to be registered with.
		 * @param component Component to be registered.
		 * 
		 * @return true if the component was added.
		 */
		public function addComponent(id:String, component:Object):Boolean
		{
			var componentClass:Class = getClass(component);
			if (!hasEntity(id))
			{
				return false;
			}
			_components[id][componentClass] = component;
			addEntityToFamilies(id, componentClass);
			return true;
		}
		
		
		/**
		 * Retrieves a component.
		 *  
		 * @param id the component is registered with.
		 * @param componentClass Component to be retrieved.
		 * @return component.
		 */
		public function getComponent(id:String, componentClass:Class):*
		{
			var entityComponents:Dictionary = _components[id];
			if (entityComponents == null)
			{
				throw new Error("Entity with ID \"" + id + "\" not found in entity manager.");
			}
			try
			{
				return entityComponents[componentClass];
			}
			catch (err:Error)
			{
				throw new Error("Component " + componentClass + " not found on entity " + id);
			}
		}
		
		
		/**
		 * Retrieves all of an entities components.
		 *  
		 * @param id Entity ID the components are registered with.
		 * @return a dictionary of the entites components with the component Class as the key.
		 */
		public function getComponents(id:String):Dictionary
		{
			var entityComponents:Dictionary = _components[id];
			if (entityComponents == null)
			{
				throw new Error("Entity " + id + " not found in Entity Manager.");
			}
			return entityComponents;
		}
		
		
		/**
		 * Unregisters a component from an entity.
		 *  
		 * @param id Entity ID the component is registered with.
		 * @param componentClass to be unregistered.
		 */
		public function removeComponent(id:String, componentClass:Class):void
		{
			removeEntityFromFamilies(id, componentClass);
			delete _components[id][componentClass];
		}
		
		
		/**
		 * Returns a reference to a list of entities that have a specified set of components.
		 */
		public function getEntityFamily(...components):EntityFamily
		{
			return getFamily(components);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_components = null;
			for each (var family:EntityFamily in _families)
			{
				family.dispose();
			}
			_families = null;
			_componentFamilyMap = null;
			_keyCount = 0;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[EntityManager]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Gets class definition from instance.
		 * @private
		 */
		private function getClass(obj:Object):Class
		{
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
		
		
		/**
		 * Gets all Entities with specifed Components.
		 * @private
		 */
		private function getEntitiesAllComposingOf(components:Array):Vector.<IEntity>
		{
			var entityList:Vector.<IEntity> = new Vector.<IEntity>();
			for (var id:String in _components)
			{
				if (hasAllComponents(id, components))
				{
					entityList.push(new Entity(this, id));
				}
			}
			return entityList;
		}
		
		
		/**
		 * Checks if a entity has a set of Components.
		 * @private
		 */
		private function hasAllComponents(id:String, components:Array):Boolean
		{
			for each (var c:Class in components)
			{
				if (!_components[id][c])
				{
					return false;
				}
			}
			return true;
		}
		
		
		/**
		 * Updates families when a component is added to an entity.
		 * @private
		 */
		private function addEntityToFamilies(id:String, componentClass:Class):void
		{
			var families:Vector.<Array> = getFamiliesWithComponent(componentClass);
			for each (var a:Array in getFamiliesWithComponent(componentClass))
			{
				if (hasAllComponents(id, a))
				{
					var family:EntityFamily = getFamily(a);
					var newEntity:Entity = new Entity(this, id);
					family.entities.push(newEntity);
					family.entityAdded.dispatch(newEntity);
				}
			}
		}
		
		
		/**
		 * Updates families when a component is removed from an entity.
		 * @private
		 */
		private function removeEntityFromFamilies(id:String, componentClass:Class):void
		{
			for each (var a:Array in getFamiliesWithComponent(componentClass))
			{
				var family:EntityFamily = getFamily(a);
				for (var i:int = 0; i < family.entities.length; i++)
				{
					var entity:IEntity = family.entities[i] as IEntity;
					if (entity.id == id)
					{
						family.entities.splice(i, 1);
						family.entityRemoved.dispatch(entity);
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function removeFamily(components:Array):void
		{
			IDisposable(_families[components]).dispose();
			delete _families[components];

			for each (var familyRefList:Vector.<Array> in _componentFamilyMap)
			{
				for (var i:int = 0; i < familyRefList.length; i++)
				{
					if (familyRefList[i] == components)
					{
						familyRefList.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		
		/**
		 * Retrieves a list of Families with Component or creates a new one.
		 * @private
		 */
		private function getFamiliesWithComponent(componentClass:Class):Vector.<Array>
		{
			return _componentFamilyMap[componentClass] ||= new Vector.<Array>();
		}
		
		
		/**
		 * Retrieves an existing Family with set of Components or creates a new one.
		 * @private
		 */
		private function getFamily(components:Array):EntityFamily
		{
			return _families[components] ||= newFamily(components);
		}
		
		
		/**
		 * Creates a new family and updates references.
		 * @private
		 */
		private function newFamily(components:Array):EntityFamily
		{
			for each (var c:Class in components)
			{
				getFamiliesWithComponent(c).push(components);
			}
			var family:EntityFamily = new EntityFamily(components);
			family.entities = getEntitiesAllComposingOf(components);
			return family;
		}
	}
}
