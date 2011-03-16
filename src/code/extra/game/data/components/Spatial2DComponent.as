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
package extra.game.data.components
{
	import base.data.entity.EntityComponent;

	import flash.geom.Point;
	
	
	/**
	 * Basic spatial component that can exist at a 2D position and has a size
	 * and a rotation.
	 */
	public class Spatial2DComponent extends EntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _position:Point;
		/** @private */
		private var _rotation:Number;
		/** @private */
		private var _size:Point;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Spatial2DComponent()
		{
			_position = new Point();
			_rotation = 0;
			_size = new Point();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The position of the spatial component.
		 */
		public function get position():Point
		{
			return _position.clone();
		}
		
		
		/**
		 * The rotation of the spatial component.
		 */
		public function get rotation():Number
		{
			return _rotation;
		}
		
		
		/**
		 * The size of the spatial component.
		 */
		public function get size():Point
		{
			return _size.clone();
		}
		
		
		/**
		 * The x coordinate of the SpatialComponent's position.
		 */
		public function get x():Number
		{
			return _position.x;
		}
		public function set x(v:Number):void
		{
			_position.x = v;
		}
		
		
		/**
		 * The y coordinate of the SpatialComponent's position.
		 */
		public function get y():Number
		{
			return _position.y;
		}
		public function set y(v:Number):void
		{
			_position.y = v;
		}
		
		
		/**
		 * The width of the SpatialComponent's size.
		 */
		public function get width():Number
		{
			return _size.x;
		}
		public function set width(v:Number):void
		{
			_size.x = v;
		}
		
		
		/**
		 * The height of the SpatialComponent's size.
		 */
		public function get height():Number
		{
			return _size.y;
		}
		public function set height(v:Number):void
		{
			_size.y = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function onAdd():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function onRemove():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
