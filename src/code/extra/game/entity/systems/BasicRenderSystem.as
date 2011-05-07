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
package extra.game.entity.systems
{
	import base.core.entity.EntitySystem;
	import base.core.entity.IEntity;
	import base.core.entity.IEntitySystem;

	import extra.game.entity.components.GraphicsComponent;
	import extra.game.entity.components.Spacial2DComponent;
	
	
	/**
	 * BasicRenderSystem class
	 */
	public class BasicRenderSystem extends EntitySystem implements IEntitySystem
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _entities:Vector.<IEntity>;
		
		//private var _bitmap:Bitmap;
		//private var _buffer:BitmapData;
		//private var _blankRect:Rectangle;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function BasicRenderSystem()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function onRegister():void
		{
			//_bitmap = new Bitmap();
			//main.contextView.addChild(_bitmap);
			//_buffer = new BitmapData(800, 600, false, 0x000000);
			//_bitmap.bitmapData = _buffer;
			//_blankRect = new Rectangle(0, 0, 800, 600);
			_entities = main.entityManager.getEntityFamily(GraphicsComponent, Spacial2DComponent).entities;
		}
		
		
		public function start():void
		{
			main.renderSignal.add(onRender);
		}
		
		
		public function dispose():void
		{
			main.renderSignal.remove(onRender);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onRender():void
		{
			//_buffer.lock();
			//_buffer.fillRect(_blankRect, 0x000000);
			for each (var e:IEntity in _entities)
			{
				var spacial:Spacial2DComponent = e.getComponent(Spacial2DComponent);
				var graphics:GraphicsComponent = e.getComponent(GraphicsComponent);
				//Debug.trace("draw " + e + " at x" + spacial.position.x + " y" + spacial.position.y);
				//var p:Point = new Point(spacial.position.x, spacial.position.y);
				//_buffer.copyPixels(graphics.graphic.bitmapData, graphics.boundingRect, p, null, null, true);
			}
			//_buffer.unlock();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
