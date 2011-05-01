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
package extra.tbs.entity.components
{
	import base.core.entity.IEntityComponent;
	
	
	/**
	 * TBSUnitStatsComponent class
	 */
	public class TBSUnitStatsComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _movementPoints:int;
		private var _movementPointsCurrent:int;
		private var _mobility:int;
		private var _vision:int;
		private var _strength:int;
		private var _fuel:int;
		private var _xp:int;
		private var _xpValueAttack:int;
		private var _xpValueDefense:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TBSUnitStatsComponent()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "[TBSUnitStatsComponent]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The movement points that the unit has available per turn. This value determines
		 * how many fields the unit can travel per turn. The minimum allowed value for this
		 * is 0 which result in the unit being immobile.
		 */
		public function get movementPoints():int
		{
			return _movementPoints;
		}
		public function set movementPoints(v:int):void
		{
			_movementPoints = v > 0 ? v : 0;
		}
		
		
		/**
		 * The amount of movement points that the unit has left for the current turn. This
		 * value is reset to movementPoints at the beginning of every new turn. The minimum
		 * possible value for this is 0.
		 */
		public function get movementPointsCurrent():int
		{
			return _movementPointsCurrent;
		}
		public function set movementPointsCurrent(v:int):void
		{
			_movementPointsCurrent = v > 0 ? v : 0;
		}
		
		
		/**
		 * A value that determines the unit's mobility. This value plays a role in calculating
		 * the unit's movement speed.
		 */
		public function get mobility():int
		{
			return _mobility;
		}
		public function set mobility(v:int):void
		{
			_mobility = v > 0 ? v : 0;
		}
		
		
		/**
		 * The vision of the unit determines how many fields far the unit can see in fog-of-war
		 * conditions. If this value is set to zero the unit is essentially blind.
		 */
		public function get vision():int
		{
			return _vision;
		}
		public function set vision(v:int):void
		{
			_vision = v > 0 ? v : 0;
		}
		
		
		/**
		 * The combat strength of the unit. This value determines the defense strength of the
		 * unit. A value of 0 means the unit has no innate defense.
		 */
		public function get strength():int
		{
			return _strength;
		}
		public function set strength(v:int):void
		{
			_strength = v > 0 ? v : 0;
		}
		
		
		/**
		 * Some units can require fuel to function. A value of 0 means the unit is out of fuel,
		 * a value of -1 means that the unit has infinite fuel (used for units that don't
		 * require any fuel, e.g. infantry).
		 */
		public function get fuel():int
		{
			return _fuel;
		}
		public function set fuel(v:int):void
		{
			_fuel = v > -1 ? v : -1;
		}
		
		
		/**
		 * The current amount of XP (experience points) that the unit has. XP is used to
		 * promote units, giving them new abilities.
		 */
		public function get xp():int
		{
			return _xp;
		}
		public function set xp(v:int):void
		{
			_xp = v > 0 ? v : 0;
		}
		
		
		/**
		 * A value that determines how much XP the units earns after doing a successful
		 * offensive action.
		 */
		public function get xpValueAttack():int
		{
			return _xpValueAttack;
		}
		public function set xpValueAttack(v:int):void
		{
			_xpValueAttack = v > 0 ? v : 0;
		}
		
		
		/**
		 * A value that determines how much XP the units earns after doing a successful
		 * defensive action.
		 */
		public function get xpValueDefense():int
		{
			return _xpValueDefense;
		}
		public function set xpValueDefense(v:int):void
		{
			_xpValueDefense = v > 0 ? v : 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
