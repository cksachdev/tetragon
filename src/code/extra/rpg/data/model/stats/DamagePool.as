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
package extra.rpg.data.model.stats
{
	/**
	 * A DamagePool defines a statistic pool of points that represent
	 * a (damageable) condition for an Actor, e.g. health, mind or action points.
	 * 
	 * Every actor posesses one or more damage pools (health, mind, action)
	 * which represents how much the actor owns of the specific vitality. Damage
	 * Pools typically grow (i.e. their max. value raises) whenever the actor's
	 * level increases.
	 * 
	 * If a Damage Pool is decreased by a successful attack, it will slowly
	 * raise again until it reaches [maximum - wounds].
	 * 
	 * A Damage Pool can be wounded by means of specific attacks or weapons and
	 * the wounds property determines by how much the pool is wounded. Wounds
	 * decrease the max. value of the pool, effectively make the actor having a
	 * smaller pool and therefore more easily incappable. Wounds stay on the pool
	 * unless they are healed by a medic or by use of a medpack.
	 * 
	 * Damage Pools determine when an actor becomes incapped (incapacitated). If
	 * pool's value reaches or sinks below that of the incapThreshold property.
	 * This means that if an actor has a low incapThreshold he is harder to
	 * incap than an actor with a high incapThreshold value.
	 */
	public class DamagePool
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _maximum:int		= 100;
		/** @private */
		private var _value:int			= _maximum;
		/** @private */
		private var _wounds:int			= 0;
		/** @private */
		private var _incapThreshold:int	= 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * the maximum value of the pool. This value typically increases the
		 * stronger the character or creature is. (The minimum is always 0).
		 * The maximum value cannot be smaller than 0.
		 */
		public function get maximum():int
		{
			return _maximum;
		}
		public function set maximum(v:int):void
		{
			_maximum = (v < 0) ? 0 : v;
		}
		
		
		/**
		 * Determines the current value of the damage pool.
		 * The value cannot be smaller than 0 and not be larger than maximum.
		 */
		public function get value():int
		{
			return _value;
		}
		public function set value(v:int):void
		{
			_value = (v < 0) ? 0 : (v > _maximum) ? _maximum : v;
		}
		
		
		/**
		 * The wounds value of the pool. Normally this is only relevant for health
		 * type damage pools as these should be able to get wounded. The maximum
		 * value is decreased by the wounds value, effectively making the actor loose
		 * pool points quicker because the pool is smaller. Wounds can only be healed
		 * by using med packs or by having a medic healing it.
		 * The wounds value cannot be smaller than 0 and not be larger than maximum.
		 */
		public function get wounds():int
		{
			return _wounds;
		}
		public function set wounds(v:int):void
		{
			_wounds = (v < 0) ? 0 : (v > _maximum) ? _maximum : v;
		}
		
		
		/**
		 * The threshold value that determines when an actor becomes incapacitated
		 * after loosing too many pool points. For example if this value is 100, the
		 * actor becomes incapacitated after his pool value drops to 100 or below.
		 * The incap threshold value cannot be smaller than 0 and not be larger than
		 * maximum.
		 */
		public function get incapThreshold():int
		{
			return _incapThreshold;
		}
		public function set incapThreshold(v:int):void
		{
			_incapThreshold = (v < 0) ? 0 : (v > _maximum) ? _maximum : v;
		}
	}
}
