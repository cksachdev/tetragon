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
	import base.data.types.Point3D;
	import base.data.types.SpatialSize;
	
	
	/**
	 * Basic spatial component that can exist at a 2D or 3D position and has a size
	 * and a rotation.
	 */
	public class Spatial3DComponent extends EntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _position:Point3D;
		/** @private */
		private var _rotation:Point3D;
		/** @private */
		private var _size:SpatialSize;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Spatial3DComponent()
		{
			_position = new Point3D();
			_rotation = new Point3D();
			_size = new SpatialSize();
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
		public function get position():Point3D
		{
			return _position.clone();
		}
		
		
		/**
		 * The rotation of the spatial component.
		 */
		public function get rotation():Point3D
		{
			return _rotation.clone();
		}
		
		
		/**
		 * The size of the spatial component.
		 */
		public function get size():SpatialSize
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
		 * The z coordinate of the SpatialComponent's position.
		 */
		public function get z():Number
		{
			return _position.z;
		}
		public function set z(v:Number):void
		{
			_position.z = v;
		}
		
		
		/**
		 * The x value of the SpatialComponent's rotation.
		 */
		public function get rotationX():Number
		{
			return _rotation.x;
		}
		public function set rotationX(v:Number):void
		{
			_rotation.x = v;
		}
		
		
		/**
		 * The y value of the SpatialComponent's rotation.
		 */
		public function get rotationY():Number
		{
			return _rotation.y;
		}
		public function set rotationY(v:Number):void
		{
			_rotation.y = v;
		}
		
		
		/**
		 * The z value of the SpatialComponent's rotation.
		 */
		public function get rotationZ():Number
		{
			return _rotation.z;
		}
		public function set rotationZ(v:Number):void
		{
			_rotation.z = v;
		}
		
		
		/**
		 * The width of the SpatialComponent's size.
		 */
		public function get width():Number
		{
			return _size.width;
		}
		public function set width(v:Number):void
		{
			_size.width = v;
		}
		
		
		/**
		 * The height of the SpatialComponent's size.
		 */
		public function get height():Number
		{
			return _size.height;
		}
		public function set height(v:Number):void
		{
			_size.height = v;
		}
		
		
		/**
		 * The depth of the SpatialComponent's size.
		 */
		public function get depth():Number
		{
			return _size.depth;
		}
		public function set depth(v:Number):void
		{
			_size.depth = v;
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
