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
	import com.hexagonstar.signals.Signal;
	
	
	/**
	 * EntityFamily class
	 */
	public class EntityFamily
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private const ENTITY_ADDED:Signal = new Signal(IEntity);
		private const ENTITY_REMOVED:Signal = new Signal(IEntity);
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _entities:Vector.<IEntity>;
		private var _loopSignal:Signal;
		private var _currentEntity:IEntity;
		private var _components:Array;
		private var _canceled:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityFamily(components:Array)
		{
			_components = components;
			_loopSignal = new Signal();
			_loopSignal.valueClasses = _components;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Resets the count and starts iterating through entities.
		 */
		public function startIterator():void
		{
			_canceled = false;
			for each (var e:IEntity in _entities)
			{
				_currentEntity = e;
				_loopSignal.dispatch.apply(this, extractComponents(e));
				if (_canceled) break;
			}
		}
		
		
		/**
		 * Stop further iteration.
		 */
		public function stopIterator():void
		{
			_canceled = true;
		}
		
		
		/**
		 * Get the current entity from the iterator.
		 */
		private function extractComponents(entity:IEntity):Array
		{
			var components:Array = [];
			for each (var c:Class in _components)
			{
				components.push(entity.getComponent(c));
			}
			return components;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_entities = null;
			ENTITY_ADDED.removeAll();
			ENTITY_REMOVED.removeAll();
			_loopSignal.removeAll();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A vector of all entities in the family.
		 */
		public function get entities():Vector.<IEntity>
		{
			return _entities;
		}
		public function set entities(v:Vector.<IEntity>):void
		{
			_entities = v;
		}
		
		
		/**
		 * The signal that is dispatched when an entity is added to the family.
		 */
		public function get entityAdded():Signal
		{
			return ENTITY_ADDED;
		}
		
		
		/**
		 * The signal that is dispatched when an entity is removed from the family.
		 * The payload is the entity that was added.
		 */
		public function get entityRemoved():Signal
		{
			return ENTITY_REMOVED;
		}
		
		
		/**
		 * The signal that is dispatched when the iterator increments.
		 * The payload is the entity that was removed.
		 */
		public function get iterator():Signal
		{
			return _loopSignal;
		}
		
		
		/**
		 * The number of entities in the family. The payload is the families components.
		 */
		public function get size():uint
		{
			if (_entities == null) return 0;
			return _entities.length;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get currentEntity():IEntity
		{
			return _currentEntity;
		}
	}
}
