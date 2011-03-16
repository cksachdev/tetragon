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
package base.util
{
	import base.Main;
	import base.core.console.Console;
	import base.data.Registry;

	import com.hexagonstar.debug.LogLevel;
	import com.hexagonstar.util.debug.Debug;

	import flash.display.Stage;
	
	
	/**
	 * A simple wrapper class for project-external (and internal) Logging classes.
	 */
	public final class Log
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private static var _main:Main;
		private static var _buffer:Array;
		private static var _console:Console;
		private static var _enabled:Boolean = true;
		private static var _initial:Boolean = true;
		private static var _filterLevel:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the logger into it's initial state.
		 */
		public static function init():void 
		{
			_main = null;
			_buffer = null;
			_console = null;
			_initial = true;
		}
		
		
		/**
		 * Readies the logger. Needs to be called before the Logger can be used.
		 */
		public static function ready(main:Main):void
		{
			_main = main;
			_console = _main.console;
			
			if (_console)
			{
				_console.clear();
				_console.clearInput();
			}
			
			filterLevel = Registry.config.loggingFilterLevel;
			enabled = Registry.config.loggingEnabled;
			
			Log.monitor(_main.view.stage);
		}
		
		
		/**
		 * Receives any logging data from the logger in the hexagonLib.
		 */
		public static function logByLevel(level:int, data:*):void
		{
			level = (level < LogLevel.TRACE) ? LogLevel.TRACE
				: (level > LogLevel.FATAL) ? LogLevel.FATAL : level;
			
			switch (level)
			{
				case LogLevel.TRACE:
					trace(data);
					break;
				case LogLevel.DEBUG:
					debug(data);
					break;
				case LogLevel.INFO:
					info(data);
					break;
				case LogLevel.WARN:
					warn(data);
					break;
				case LogLevel.ERROR:
					error(data);
					break;
				case LogLevel.FATAL:
					fatal(data);
			}
		}
		
		
		/**
		 * monitor
		 */
		public static function monitor(stage:Stage):void
		{
			Debug.monitor(stage);
		}
		
		
		/**
		 * trace
		 */
		public static function trace(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.TRACE) return;
			send(data, LogLevel.TRACE, caller);
		}
		
		
		/**
		 * debug
		 */
		public static function debug(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.DEBUG) return;
			send(data, LogLevel.DEBUG, caller);
		}
		
		
		/**
		 * info
		 */
		public static function info(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.INFO) return;
			send(data, LogLevel.INFO, caller);
		}
		
		
		/**
		 * warn
		 */
		public static function warn(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.WARN) return;
			send(data, LogLevel.WARN, caller);
		}
		
		
		/**
		 * error
		 */
		public static function error(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.ERROR) return;
			send(data, LogLevel.ERROR, caller);
		}
		
		
		/**
		 * fatal
		 */
		public static function fatal(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.FATAL) return;
			send(data, LogLevel.FATAL, caller);
		}
		
		
		/**
		 * delimiter
		 */
		public static function delimiter(length:int = 20, level:int = 2):void
		{
			Debug.delimiter();
			if (_console) _console.delimiter(length, level);
		}
		
		
		/**
		 * linefeed
		 */
		public static function linefeed():void
		{
			send("", LogLevel.INFO);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public static function get enabled():Boolean
		{
			return _enabled;
		}
		public static function set enabled(v:Boolean):void
		{
			if (v)
			{
				Log.info("Logging enabled with filter level " + _filterLevel + ".");
			}
			else
			{
				Log.info("Logging disabled.");
			}
			_enabled = Debug.enabled = v;
		}
		
		
		public static function get filterLevel():int
		{
			return _filterLevel;
		}
		public static function set filterLevel(v:int):void
		{
			_filterLevel = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * send
		 * @private
		 */
		private static function send(data:*, level:int, caller:Object = null):void
		{
			if (_enabled)
			{
				/* Use initial buffer for any ouptut that is logged before
				 * the Logger is initialized. */
				if (!_main)
				{
					if (_buffer == null) _buffer = [];
					_buffer.push({data: data, level: level, caller: caller});
					return;
				}
				
				if (_initial) Log.flushBuffer();
				
				if (caller)
				{
					if (caller is String) data = caller + " " + data;
					else if (caller["toString"]) data = caller["toString"]() + " " + data;
				}
				
				Debug.trace(data, level);
				if (_console) _console.log(data, level);
			}
		}
		
		
		/**
		 * Empties initial buffer.
		 * @private
		 */
		private static function flushBuffer():void
		{
			_initial = false;
			for (var i:int = 0; i < _buffer.length; i++)
			{
				var o:Object = _buffer[i];
				send(o["data"], o["level"], o["caller"]);
			}
			_buffer = null;
		}
	}
}
