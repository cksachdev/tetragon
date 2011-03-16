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
package base.data.entity
{
	import base.util.Log;

	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * EntityComponent class
	 */
	public class EntityComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _id:String;
		/** @private */
		protected var _owner:IEntity;
		/** @private */
		protected var _registered:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityComponent()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function register(owner:IEntity, id:String):void
		{
			if (_registered)
			{
				Log.warn("Component is already registered with " + _owner.toString() + ".", this);
				return;
			}
			
			_owner = owner;
			_id = id;
			onAdd();
			_registered = true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function unregister():void
		{
			if (!_registered)
			{
				Log.warn("Component is not registered with " + _owner.toString() + ".", this);
				return;
			}
			
			_registered = false;
			onRemove();
			_owner = null;
			_id = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function reset():void
		{
			onReset();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "[" + getQualifiedClassName(this).match("[^:]*$")[0] + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get id():String
		{
			return _id;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get owner():IEntity
		{
			return _owner;
		}
		public function set owner(v:IEntity):void
		{
			_owner = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get registered():Boolean
		{
			return _registered;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * This is called when the component is added to an entity. Any initialization,
		 * event registration, or object lookups should happen here. Component lookups on
		 * the owner entity should NOT happen here. Use onReset instead.
		 * 
		 * @see #onReset()
		 */
		protected function onAdd():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * This is called when the component is removed from an entity. It should reverse
		 * anything that happened in onAdd or onReset (like removing event listeners or
		 * nulling object references).
		 */
		protected function onRemove():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * This is called anytime a component is added or removed from the owner entity.
		 * Lookups of other components on the owner entity should happen here.
		 * 
		 * <p>This can potentially be called multiple times, so make sure previous lookups
		 * are properly cleaned up each time.</p>
		 */
		protected function onReset():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
