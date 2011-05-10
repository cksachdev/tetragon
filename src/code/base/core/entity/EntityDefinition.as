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
	import base.data.DataObject;
	
	
	/**
	 * Represents an entity definition. Entity instances are created from this class.
	 */
	public class EntityDefinition extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _componentMappings:Object;
		/** @private */
		protected var _componentCount:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function EntityDefinition(id:String)
		{
			_id = id;
			_componentMappings = {};
			_componentCount = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a component mapping.
		 * 
		 * @param classID The class ID of the component.
		 * @param map A map of key/value pairs with component parameters.
		 */
		public function addComponentMapping(classID:String, map:Object):void
		{
			_componentMappings[classID] = map;
			_componentCount++;
		}
		
		
		/**
		 * Gets a component mapping.
		 * 
		 * @param classID The class ID of the component.
		 * @return A map of key/value pairs with component parameters.
		 */
		public function getComponentMapping(classID:String):Object
		{
			return _componentMappings[classID];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function toString(...args):String
		{
			return super.toString("id=" + _id + ", componentCount=" + _componentCount);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get componentCount():int
		{
			return _componentCount;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get componentMappings():Object
		{
			return _componentMappings;
		}
	}
}
