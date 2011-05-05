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
package extra.tbs.view.display
{
	import base.core.entity.IEntity;
	import base.core.entity.IEntityComponent;
	import base.view.display.Display;

	import com.hexagonstar.util.debug.Debug;

	import flash.utils.Dictionary;
	
	
	/**
	 * Playfield display for turn-based strategy games.
	 */
	public class TBSPlayfieldDisplay extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void
		{
			var unit:IEntity = main.entityFactory.createEntity("unitInfantry");
			Debug.trace(unit.toString());
			var d:Dictionary = unit.getComponents();
			for each (var c:IEntityComponent in d)
			{
				Debug.trace(c.toString());
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function addListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function removeListeners():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function enableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function disableChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function pauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function unpauseChildren():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayText():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function layoutChildren():void
		{
		}
	}
}
