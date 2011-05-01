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
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Entity class
	 */
	public class Entity implements IEntity
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _entityManger:EntityManager;
		private var _id:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Entity(entityManger:EntityManager, id:String)
		{
			_entityManger = entityManger;
			_id = id;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function addComponent(component:IEntityComponent):Boolean
		{
			return _entityManger.addComponent(_id, component);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getComponent(componentClass:Class):*
		{
			return _entityManger.getComponent(_id, componentClass);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getComponents():Dictionary
		{
			return _entityManger.getComponents(_id);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeComponent(componentClass:Class):void
		{
			_entityManger.removeComponent(_id, componentClass);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_entityManger.removeEntity(_id);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString(...args):String
		{
			var s:String = "";
			for each (var i:String in args) s += ", " + i;
			return "[" + getQualifiedClassName(this).match("[^:]*$")[0] + s + "]";
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
	}
}
