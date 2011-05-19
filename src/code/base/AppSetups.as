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
package base
{
	import base.setup.*;

	import extra.demo.setup.DemoSetup;
	import extra.game.setup.GameSetup;
	import extra.rpg.setup.RPGSetup;
	import extra.tbs.setup.TBSSetup;
	
	
	/**
	 * A class that contains a list of base/extra setup classes which are being
	 * initialized during the application init phase.
	 * 
	 * <p>The InitApplicationCommand uses this class briefly to get all setup classes that
	 * are compiled into the build and instantiates them so that the setup packages can be
	 * connected to the base engine.</p>
	 * 
	 * <p>TODO Utimately make this class being auto-generated through the build process
	 * and find a way to conviently set in the build properties which setup classes should
	 * be included in the build. (If Ant only would support iteration!!)</p>
	 */
	public class AppSetups
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _setups:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function AppSetups()
		{
			_setups = [];
			
			/* Add Desktop-specific setup if this is an AIR Desktop build. */
			CONFIG::IS_DESKTOP_BUILD
			{
				_setups.push(DesktopSetup);
			}
			/* Add Android-specific setup if this is an AIR Android build. */
			CONFIG::IS_ANDROID_BUILD
			{
				_setups.push(AndroidSetup);
			}
			/* Add iOS-specific setup if this is an AIR iOS build. */
			CONFIG::IS_IOS_BUILD
			{
				_setups.push(IOSSetup);
			}
			
			/* You can add setups for extra code branches here if needed. */
 			CONFIG::EXTRA_GAME
			{
				_setups.push(GameSetup);
			}
 			CONFIG::EXTRA_RPG
			{
				_setups.push(RPGSetup);
			}
 			CONFIG::EXTRA_TBS
			{
				_setups.push(TBSSetup);
			}
 			CONFIG::EXTRA_DEMO
			{
				_setups.push(DemoSetup);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * An array of qualified class names to setup classes that set up additional
		 * base and extra packages for use with the application.
		 */
		public function get setups():Array
		{
			return _setups;
		}
	}
}
