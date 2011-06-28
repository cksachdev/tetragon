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
package base.assist
{
	import base.Main;

	import com.hexagonstar.util.reflection.getClassName;

	import flash.display.Stage;
	
	
	/**
	 * Abstract base class for build-specific persistent assist classes.
	 * 
	 * <p>An assistor is a helper class for Main that may contain persistent instructions
	 * for a specific application build type.</p>
	 */
	public class Assistor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		private var _id:String;
		private var _priority:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Assistor()
		{
			_main = Main.instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the assistor. Called automatically by main after app init phase
		 * is finished.
		 */
		public function init():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Unique ID of the assistor. Automatically set when registering assistor classes.
		 * Can only be set once!
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(v:String):void
		{
			if (_id != null) return;
			_id = v;
		}
		
		
		/**
		 * Used internally to prioritize in which order assistor classes are initlialized.
		 * @private
		 */
		public function get priority():int
		{
			return _priority;
		}
		public function set priority(v:int):void
		{
			_priority = v;
		}
		
		
		/**
		 * Reference to main for use in sub classes.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * Reference to the main stage for use in sub classes.
		 */
		protected function get stage():Stage
		{
			return _main.contextView.stage;
		}
	}
}
