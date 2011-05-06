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
	import com.hexagonstar.util.reflection.describeTypeProperties;

	import flash.utils.Dictionary;
	
	
	/**
	 * Entity class
	 */
	public class Entity implements IEntity
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public static var entityManager:EntityManager;
		
		private var _id:String;
		private var _type:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Entity(id:String, type:String)
		{
			_id = id;
			_type = type;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function addComponent(component:IEntityComponent):Boolean
		{
			return entityManager.addComponent(_id, _type, component);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getComponent(componentClass:Class):*
		{
			return entityManager.getComponent(_id, componentClass);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getComponents():Dictionary
		{
			return entityManager.getComponents(_id);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeComponent(componentClass:Class):void
		{
			entityManager.removeComponent(_id, componentClass);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			entityManager.removeEntity(_id);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "[Entity type=" + _type + ", id=" + _id + "]";
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function dump():String
		{
			var s:String = "\n" + toString();
			var d:Dictionary = getComponents();
			for each (var c:IEntityComponent in d)
			{
				s += "\n\t" + c;
				var obj:Object = describeTypeProperties(c);
				for (var k:String in obj)
				{
					s += "\n\t\t" + k + ": " + c[k];
				}
			}
			return s;
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
