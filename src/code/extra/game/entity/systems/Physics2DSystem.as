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

	import extra.game.entity.components.GravityComponent;
	import extra.game.entity.components.Physics2DComponent;
	import extra.game.entity.components.Spacial2DComponent;
	
	
	/**
	 * Physics2DSystem class
	 */
	public class Physics2DSystem extends EntitySystem implements IEntitySystem
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _entities:Vector.<IEntity>;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Physics2DSystem()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function onRegister():void
		{
		}
		
		
		public function start():void
		{
			_entities = main.entityManager.getEntityFamily(Spacial2DComponent, Physics2DComponent, GravityComponent).entities;
			main.tickSignal.add(onTick);
		}
		
		
		public function dispose():void
		{
			main.tickSignal.remove(onTick);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		public function onTick(t:Number):void
		{
			for each (var e:IEntity in _entities)
			{
				var spacial:Spacial2DComponent = e.getComponent(Spacial2DComponent);
				var physics:Physics2DComponent = e.getComponent(Physics2DComponent);
				var gravity:GravityComponent = e.getComponent(GravityComponent);
				physics.velocity.addEquals(gravity.force);
				spacial.postion.addEquals(physics.velocity.multiply(t));
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
