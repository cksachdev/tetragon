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
	 * TBSUnitPropertiesComponent class
	 */
	public class TBSUnitPropertiesComponent extends EntityComponent implements IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _nameID:String;
		private var _nameShortID:String;
		private var _designationID:String;
		private var _designationShortID:String;
		private var _descriptionID:String;
		private var _movementTypeID:String;
		private var _price:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A personal name for the unit. This is optional and can be used if a unit should
		 * have a recognizable name among it's type of units, for example a spy unit could
		 * have a personal name to make it easier to be recognized among other spy units.
		 * 
		 * If no name ID was specified for the unit, this property will return the same as
		 * the unit's designation ID.
		 */
		public function get nameID():String
		{
			if (_nameID == null || _nameID.length < 1) return designationID;
			return _nameID;
		}
		public function set nameID(v:String):void
		{
			_nameID = v;
		}
		
		
		/**
		 * ID for the abbreviated version of the name.
		 * 
		 * If no short name ID was specified for the unit, this property will return the
		 * same as the unit's short designation ID.
		 */
		public function get nameShortID():String
		{
			return _nameShortID;
		}
		public function set nameShortID(v:String):void
		{
			_nameShortID = v;
		}
		
		
		/**
		 * The ID of the name of the unit as it goes by trade (e.g. Infantry).
		 */
		public function get designationID():String
		{
			return _designationID;
		}
		public function set designationID(v:String):void
		{
			_designationID = v;
		}
		
		
		/**
		 * ID of the abbreviated version of the designation.
		 */
		public function get designationShortID():String
		{
			return _designationShortID;
		}
		public function set designationShortID(v:String):void
		{
			_designationShortID = v;
		}
		
		
		/**
		 * ID for optional text that describes the unit.
		 */
		public function get descriptionID():String
		{
			return _descriptionID;
		}
		public function set descriptionID(v:String):void
		{
			_descriptionID = v;
		}
		
		
		/**
		 * ID of the movement type of the unit, e.g. tires, tread, sea etc.
		 */
		public function get movementTypeID():String
		{
			return _movementTypeID;
		}
		public function set movementTypeID(v:String):void
		{
			_movementTypeID = v;
		}
		
		
		/**
		 * The money it costs to buy one of these units.
		 */
		public function get price():uint
		{
			return _price;
		}
		public function set price(v:uint):void
		{
			_price = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
