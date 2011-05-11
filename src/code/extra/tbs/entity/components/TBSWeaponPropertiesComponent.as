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
	import base.core.entity.EntityComponent;
	import base.core.entity.IEntityComponent;
	
	
	/**
	 * TBSWeaponPropertiesComponent class
	 */
	public class TBSWeaponPropertiesComponent extends EntityComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _nameID:String;
		private var _descriptionID:String;
		private var _weaponTypeID:String;
		private var _minRange:int;
		private var _maxRange:int;
		private var _ammo:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get nameID():String
		{
			return _nameID;
		}
		public function set nameID(v:String):void
		{
			_nameID = v;
		}
		
		
		public function get descriptionID():String
		{
			return _descriptionID;
		}
		public function set descriptionID(v:String):void
		{
			_descriptionID = v;
		}
		
		
		public function get weaponTypeID():String
		{
			return _weaponTypeID;
		}
		public function set weaponTypeID(v:String):void
		{
			_weaponTypeID = v;
		}
		
		
		public function get minRange():int
		{
			return _minRange;
		}
		public function set minRange(v:int):void
		{
			_minRange = v;
		}
		
		
		public function get maxRange():int
		{
			return _maxRange;
		}
		public function set maxRange(v:int):void
		{
			_maxRange = v;
		}
		
		
		public function get ammo():int
		{
			return _ammo;
		}
		public function set ammo(v:int):void
		{
			_ammo = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
