/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package base.command{	import base.event.CommandEvent;		/**	 * A CompositeCommand is a composite command that consists of several single	 * commands which are executed in sequential order.	 */	public class CompositeCommand extends PausableCommand implements ICommandListener	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/** @private */		protected var _progress:int;		/** @private */		protected var _commands:Vector.<BaseCommand>;		/** @private */		protected var _messages:Vector.<String>;		/** @private */		protected var _currentCmd:BaseCommand;		/** @private */		protected var _currentMsg:String;						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new CompositeCommand instance.		 */		public function CompositeCommand()		{			super();		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * Executes the composite command. Abstract method. Be sure to call super.execute()		 * first in subclassed execute methods.		 */ 		override public function execute():void		{			super.execute();						_paused = false;			_progress = 0;			_commands = new Vector.<BaseCommand>();			_messages = new Vector.<String>();						enqueueCommands();			next();		}						/**		 * Aborts the command's execution.		 */		override public function abort():void		{			super.abort();			if (_currentCmd) _currentCmd.abort();		}						/**		 * @inheritDoc		 */		override public function dispose():void		{			super.dispose();						for (var i:int = 0; i < _commands.length; i++)			{				_commands[i].dispose();			}						_currentCmd = null;			_currentMsg = null;			_commands = null;			_messages = null;		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * The name identifier of the command.		 */		override public function get name():String		{			return "compositeCommand";		}						/**		 * The command's progress.		 */		public function get progress():int		{			return _progress;		}				/**		 * The Message associated to the command's progress.		 */		public function get progressMessage():String		{			return _currentMsg;		}						//-----------------------------------------------------------------------------------------		// Event Handlers		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		public function onCommandProgress(e:CommandEvent):void		{			/* Not used yet! */		}						/**		 * @private		 */		public function onCommandComplete(e:CommandEvent):void		{			removeCommandListeners();			notifyProgress();			next();		}						/**		 * @private		 */		public function onCommandAbort(e:CommandEvent):void		{			removeCommandListeners();			notifyProgress();			next();		}						/**		 * @private		 */		public function onCommandError(e:CommandEvent):void		{			removeCommandListeners();			notifyProgress();			notifyError(e.message);			next();		}						//-----------------------------------------------------------------------------------------		// Private Methods		//-----------------------------------------------------------------------------------------				/**		 * Abstract method. This is the place where you enqueue single commands.		 * @private		 */		protected function enqueueCommands():void		{		}						/**		 * Enqueues a commandfor use in the composite command's execution sequence.		 * @private		 */		protected function enqueue(cmd:BaseCommand, progressMsg:String = ""):void		{			_commands.push(cmd);			_messages.push(progressMsg);		}						/**		 * Executes the next enqueued command.		 * @private		 */		protected function next():void		{			_currentMsg = _messages.shift();						if (!_aborted && _commands.length > 0)			{				_currentCmd = _commands.shift();				_currentCmd.addEventListener(CommandEvent.COMPLETE, onCommandComplete);				_currentCmd.addEventListener(CommandEvent.ABORT, onCommandAbort);				_currentCmd.addEventListener(CommandEvent.ERROR, onCommandError);				_currentCmd.execute();			}			else			{				complete();			}		}						/**		 * @private		 */		protected function removeCommandListeners():void		{			_currentCmd.removeEventListener(CommandEvent.COMPLETE, onCommandComplete);			_currentCmd.removeEventListener(CommandEvent.ABORT, onCommandAbort);			_currentCmd.removeEventListener(CommandEvent.ERROR, onCommandError);		}						/**		 * Notify listeners that the command has updated progress.		 * @private		 */		protected function notifyProgress():void		{			_progress++;			dispatchEvent(new CommandEvent(CommandEvent.PROGRESS, this,				_currentMsg, _progress));		}						/**		 * @private		 */		override protected function notifyError(errorMsg:String):void		{			dispatchEvent(new CommandEvent(CommandEvent.ERROR, this, errorMsg, _progress));		}						/**		 * @private		 */		override protected function complete():void		{			super.complete();		}	}}