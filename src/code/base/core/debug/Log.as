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
package base.core.debug
{
	import base.Main;
	import base.data.Registry;

	import com.hexagonstar.util.debug.LogLevel;

	import flash.display.Stage;
	
	
	/**
	 * Provides the logging mechanism for tetragon. This class is used anywhere in the
	 * project code to send logging information to tetragon's internal console as well
	 * as to any external loggers.
	 * 
	 * @see Console
	 * @see ExternalLogAdapter
	 */
	public final class Log
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _main:Main;
		/** @private */
		private static var _buffer:Array;
		/** @private */
		private static var _console:Console;
		/** @private */
		private static var _externalLog:ExternalLogAdapter;
		/** @private */
		private static var _enabled:Boolean = true;
		/** @private */
		private static var _initial:Boolean = true;
		/** @private */
		private static var _filterLevel:int = 0;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Puts the logger into it's initial state.
		 */
		public static function init():void 
		{
			_main = null;
			_buffer = null;
			_console = null;
			_externalLog = null;
			_initial = true;
			_externalLog = new ExternalLogAdapter();
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
			
			Log.monitor(_main.contextView.stage);
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
		 * Tells any external logger to monitor the application.
		 * 
		 * @param stage Stage object required for monitoring.
		 */
		public static function monitor(stage:Stage):void
		{
			if (_externalLog) _externalLog.monitor(stage);
		}
		
		
		/**
		 * Sends trace data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function trace(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.TRACE) return;
			if (_externalLog) _externalLog.trace(data);
			send(data, LogLevel.TRACE, caller);
		}
		
		
		/**
		 * Sends debug data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function debug(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.DEBUG) return;
			if (_externalLog) _externalLog.debug(data);
			send(data, LogLevel.DEBUG, caller);
		}
		
		
		/**
		 * Sends info data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function info(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.INFO) return;
			if (_externalLog) _externalLog.info(data);
			send(data, LogLevel.INFO, caller);
		}
		
		
		/**
		 * Sends warn data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function warn(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.WARN) return;
			if (_externalLog) _externalLog.warn(data);
			send(data, LogLevel.WARN, caller);
		}
		
		
		/**
		 * Sends error data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function error(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.ERROR) return;
			if (_externalLog) _externalLog.error(data);
			send(data, LogLevel.ERROR, caller);
		}
		
		
		/**
		 * Sends fatal data to the logger.
		 * 
		 * @param data The data to log.
		 * @param caller Optional caller of the method which is used in the output string.
		 */
		public static function fatal(data:*, caller:Object = null):void
		{
			if (_filterLevel > LogLevel.FATAL) return;
			if (_externalLog) _externalLog.fatal(data);
			send(data, LogLevel.FATAL, caller);
		}
		
		
		/**
		 * Sends a delimiter line to the console.
		 * 
		 * @param length Length of the line, in characters.
		 * @param level The filter level.
		 */
		public static function delimiter(length:int = 20, level:int = 2):void
		{
			if (_console) _console.delimiter(length, level);
		}
		
		
		/**
		 * Sends a linefeed to the logger.
		 */
		public static function linefeed():void
		{
			send("", LogLevel.INFO);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines wether the logger and any external loggers are enabled or not.
		 */
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
			_enabled = v;
			if (_externalLog) _externalLog.enabled = v;
		}
		
		
		/**
		 * Determines the filter level of the logger and any external loggers.
		 */
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
		 * @private
		 */
		private static function send(data:*, level:int, caller:Object = null):void
		{
			if (!_enabled) return;
			
			/* Use initial buffer for any ouptut that is logged before
			 * the Logger is initialized. */
			if (!_main)
			{
				if (!_buffer) _buffer = [];
				_buffer.push({data: data, level: level, caller: caller});
				return;
			}
			
			if (_initial) Log.flushBuffer();
			
			if (caller)
			{
				if (caller is String) data = caller + ": " + data;
				else if (caller["toString"]) data = caller["toString"]() + ": " + data;
			}
			
			if (_console) _console.log(data, level);
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
