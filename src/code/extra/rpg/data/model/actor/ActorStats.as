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
package extra.rpg.data.model.actor
{
	import extra.rpg.data.model.stats.CharacterLevel;
	import extra.rpg.data.model.stats.DamagePool;
	
	
	/**
	 * The ActorStats class contains stats-related values for an actor.
	 */
	public class ActorStats
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The maximum allowed value for fatigue.
		 */
		public static var MAX_FATIGUE:int = 200;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The level of the associated actor.
		 */
		public var level:CharacterLevel;
		
		/**
		 * The health damage pool of the associated actor.
		 */
		public var health:DamagePool;
		
		/**
		 * The action damage pool of the associated actor.
		 */
		public var action:DamagePool;
		
		/**
		 * The mind damage pool of the associated actor.
		 */
		public var mind:DamagePool;
		
		/** @private */
		private var _attributes:Object;
		/** @private */
		private var _fatigue:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ActorStats instance.
		 */
		public function ActorStats()
		{
			level = new CharacterLevel();
			health = new DamagePool();
			action = new DamagePool();
			mind = new DamagePool();
			
			_attributes = {};
			_fatigue = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the value for the attribute of the specified ID.
		 */
		public function setAttribute(attributeID:String, value:int):void
		{
			_attributes[attributeID] = value;
		}
		
		
		/**
		 * The fatigue of an actor.
		 */
		public function get fatigue():int
		{
			return _fatigue;
		}
		public function set fatigue(v:int):void
		{
			_fatigue = (v < 0) ? 0 : (v > ActorStats.MAX_FATIGUE) ? ActorStats.MAX_FATIGUE : v;
		}
	}
}
