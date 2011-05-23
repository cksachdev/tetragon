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

	import com.hexagonstar.types.IDisposable;

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
		
		/**
		 * Maps objects of type Dictionary, mapped by entityID which in turn contain
		 * objects of type IEntityComponent, mapped by their componentClass, e.g.
		 * 
		 * _components[entityID] = Dictionary[componentClass] = IEntityComponent
		 * 
		 * @private
		 */
		private var _components:Object;
		
		private var _families:Dictionary;
		private var _componentFamilyMap:Dictionary;
		private var _idCount:int;
		
		
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
			_idCount = 0;
			Entity.entityManager = this;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new entity with the ID provided. If no ID is provided a unique ID will
		 * be auto-generated. If an ID is provided but the entityManager already has an entity
		 * with the same ID, no entity will be created and <code>null</code> is returned.
		 * 
		 * @param id ID of the new created entity.
		 * @return The new entity or <code>null</code>.
		 */
		public function createEntity(type:String, entityID:String = null):IEntity
		{
			if (!entityID || entityID == "")
			{
				_idCount++;
				entityID = "entity" + _idCount;
			}
			else if (_components[entityID])
			{
				Log.warn("Tried to create an entity whose ID already exists.", this);
				return null;
			}
			
			var entity:IEntity = new Entity(entityID, type);
			_components[entityID] = new Dictionary();
			return entity;
		}
		
		
		/**
		 * Determines whether the entity manager has an entity mapped with the specified ID.
		 * 
		 * @param entityID The ID to check.
		 * @return true if an entity with the provided ID exists.
		 */
		public function hasEntity(entityID:String):Boolean
		{
			return _components[entityID] != null;
		}
		
		
		/**
		 * Removes an entity from the entity manager.
		 * 
		 * @param id ID of entity to remove.
		 */
		public function removeEntity(id:String):void
		{
			for each (var c:IEntityComponent in _components[id])
			{
				removeEntityFromFamilies(id, getClass(c));
			}
			delete _components[id];
		}
		
		
		/**
		 * Removes all entities and resets the entity manager.
		 */
		public function removeAll():void
		{
			for (var id:String in _components)
			{
				removeEntity(id);
			}
			_idCount = 0;
		}
		
		
		/**
		 * Registers a component with an entity.
		 * 
		 * @param entityID ID of the entity the component is to be registered with.
		 * @param component Component to be registered.
		 * @return true if the component was added.
		 */
		public function addComponent(entityID:String, entityType:String, component:IEntityComponent):Boolean
		{
			var componentClass:Class = getClass(component);
			if (!hasEntity(entityID))
			{
				return false;
			}
			_components[entityID][componentClass] = component;
			addEntityToFamilies(entityID, entityType, componentClass);
			return true;
		}
		
		
		/**
		 * Retrieves a component.
		 *  
		 * @param entityID the ID that the component is registered with.
		 * @param componentClass Component to be retrieved.
		 * @return component.
		 */
		public function getComponent(entityID:String, componentClass:Class):IEntityComponent
		{
			var entityComponents:Dictionary = _components[entityID];
			if (!entityComponents)
			{
				Log.error("Entity with ID \"" + entityID + "\" not found in entity manager.", this);
				return null;
			}
			return entityComponents[componentClass];
		}
		
		
		/**
		 * Retrieves all of an entities components.
		 *  
		 * @param id Entity ID the components are registered with.
		 * @return a dictionary of the entites components with the component Class as the key.
		 */
		public function getComponents(entityID:String):Dictionary
		{
			var entityComponents:Dictionary = _components[entityID];
			if (!entityComponents)
			{
				Log.error("Entity with ID \"" + entityID + "\" not found in entity manager.", this);
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
			for each (var f:EntityFamily in _families)
			{
				f.dispose();
			}
			_families = null;
			_componentFamilyMap = null;
			_idCount = 0;
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
					// TODO type!
					entityList.push(new Entity(id, null));
				}
			}
			return entityList;
		}
		
		
		/**
		 * Checks if a entity has a set of components.
		 * @private
		 */
		private function hasAllComponents(entityID:String, components:Array):Boolean
		{
			for each (var c:Class in components)
			{
				if (!_components[entityID][c]) return false;
			}
			return true;
		}
		
		
		/**
		 * Updates families when a component is added to an entity.
		 * @private
		 */
		private function addEntityToFamilies(entityID:String, entityType:String, componentClass:Class):void
		{
			var families:Vector.<Array> = getFamiliesWithComponent(componentClass);
			for each (var a:Array in families)
			{
				if (hasAllComponents(entityID, a))
				{
					var family:EntityFamily = getFamily(a);
					var newEntity:Entity = new Entity(entityID, entityType);
					family.entities.push(newEntity);
					family.entityAdded.dispatch(newEntity);
				}
			}
		}
		
		
		/**
		 * Updates families when a component is removed from an entity.
		 * @private
		 */
		private function removeEntityFromFamilies(entityID:String, componentClass:Class):void
		{
			for each (var a:Array in getFamiliesWithComponent(componentClass))
			{
				var family:EntityFamily = getFamily(a);
				var len:uint = family.entities.length;
				for (var i:uint = 0; i < len; i++)
				{
					var e:IEntity = family.entities[i];
					if (e.id == entityID)
					{
						family.entities.splice(i, 1);
						family.entityRemoved.dispatch(e);
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
				var len:uint = familyRefList.length;
				for (var i:uint = 0; i < len; i++)
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
		 * Retrieves a list of families with components or creates a new one.
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
