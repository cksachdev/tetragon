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
package base.command.cli
{
	import base.command.CLICommand;
	import base.core.cli.CLICommandVO;
	import base.core.debug.Console;
	import base.data.Registry;

	import com.hexagonstar.util.debug.LogLevel;
	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * CLI command to show console help text or help text for and provided command.
	 */
	public class HelpCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _command:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void 
		{
			var console:Console = main.console;
			var help:String;
			
			if (_command)
			{
				var cmd:CLICommand;
				var map:Object = console.cli.commandMap;
				var vo:CLICommandVO = map[_command];
				
				/* If commandVO wasn't found by it's mapped key, try with shortcut. */
				if (!vo)
				{
					for (var tr:String in map)
					{
						var o:CLICommandVO = map[tr];
						if (_command == o.shortcut)
						{
							_command = tr;
							vo = o;
							break;
						}
					}
				}
				
				if (vo)
				{
					try
					{
						cmd = new vo.clazz();
					}
					catch (err:Error)
					{
						// TODO Command class is not of type CLICommand, throw error?
					}
					
					if (cmd)
					{
						help = "\n    " + Console.INV_START + " COMMAND: " + vo.trigger
							+ "        SHORTCUT: " + (vo.shortcut ? vo.shortcut : "")
							+ "        CATEGORY: " + vo.category
							+ "        " + Console.INV_END
							+ "\n\tSUMMARY:\n\t\t"
							+ (cmd.helpText ? cmd.helpText : vo.descr)
							+ " Any arguments starting with + are optional."
							+ "\n\n\tUSAGE:\n\t\t" + vo.trigger;
						if (cmd.signature && cmd.signature.length > 0)
						{
							for each (var s:String in cmd.signature)
							{
								help += " <" + s + ">";
							}
						}
						if (cmd.example) help += "\n\n\tEXAMPLE:\n\t\t" + cmd.example;
					}
				}
				else
				{
					console.cli.fail("HELP - Unknown command: " + _command);
				}
			}
			else
			{
				var keyHelp:TabularText = new TabularText(2, true, "  ", null, "        ");
				keyHelp.add(["<" + Registry.config.consoleKey + ">", "Toggle console"]);
				keyHelp.add(["<TAB>", "(When out of focus) Focusses the console input field"]);
				keyHelp.add(["<TAB>", "(When in focus) Place cursor to end of current console input"]);
				keyHelp.add(["<ENTER>", "Execute the current input"]);
				keyHelp.add(["<CTRL+ARROW UP>", "Scroll console output up by one line"]);
				keyHelp.add(["<CTRL+ARROW DOWN>", "Scroll console output down by one line"]);
				keyHelp.add(["<CTRL+PAGE UP>", "Scroll console output up by one page"]);
				keyHelp.add(["<CTRL+PAGE DOWN>", "Scroll console output down by one page"]);
				keyHelp.add(["<CTRL+BACKSPACE>", "Clear the input field"]);
				keyHelp.add(["<ARROW UP>", "Step backward through command history"]);
				keyHelp.add(["<ARROW DOWN>", "Step forward through command history"]);
				
				help = "\n  " + Console.INV_START + " CONSOLE HELP " + Console.INV_END
					+ "\n\n  KEYBOARD CONTROLS:\n" + keyHelp.toString();
			}
			
			if (help)
			{
				console.log(help + "\n", LogLevel.INFO);
			}
			
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "help";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get signature():Array
		{
			return ["+command:Identifier"];
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get helpText():String
		{
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// CLI Command Signature Arguments
		//-----------------------------------------------------------------------------------------
		
		public function set command(v:String):void
		{
			_command = v;
		}
	}
}
