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
	import base.command.Command;
	import base.command.CommandManager;
	import base.command.env.InitApplicationCommand;
	import base.core.debug.Console;
	import base.core.debug.FPSMonitor;
	import base.core.debug.Log;
	import base.core.entity.EntityFactory;
	import base.core.entity.EntityManager;
	import base.core.entity.EntitySystemManager;
	import base.core.settings.LocalSettingsManager;
	import base.data.DataSupportManager;
	import base.data.Registry;
	import base.io.key.KeyManager;
	import base.io.resource.ResourceManager;
	import base.signals.RenderSignal;
	import base.signals.TickSignal;
	import base.state.StateManager;
	import base.view.screen.ScreenManager;

	import com.hexagonstar.exception.SingletonException;
	import com.hexagonstar.util.debug.HLog;
	import com.hexagonstar.util.display.StageReference;

	import flash.display.*;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	
	
	/**
	 * The main hub of the application.
	 */
	public final class Main
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:Main;
		/** @private */
		private static var _singletonLock:Boolean = false;
		
		/** @private */
		private var _contextView:DisplayObjectContainer;
		/** @private */
		private var _utilityContainer:Sprite;
		/** @private */
		private var _console:Console;
		/** @private */
		private var _fpsMonitor:FPSMonitor;
		
		/** @private */
		private var _setupHelper:*;
		
		/** @private */
		private var _dataSupportManager:DataSupportManager;
		/** @private */
		private var _commandManager:CommandManager;
		/** @private */
		private var _resourceManager:ResourceManager;
		/** @private */
		private var _stateManager:StateManager;
		/** @private */
		private var _screenManager:ScreenManager;
		/** @private */
		private var _localSettingsManager:LocalSettingsManager;
		/** @private */
		private var _keyManager:KeyManager;
		/** @private */
		private var _entityManager:EntityManager;
		/** @private */
		private var _entitySystemManager:EntitySystemManager;
		/** @private */
		private var _entityFactory:EntityFactory;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		public var tickSignal:TickSignal;
		public var renderSignal:RenderSignal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructs a new App instance.
		 */
		public function Main()
		{
			if (!_singletonLock) throw new SingletonException(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the singleton instance of Main.
		 */
		public static function get instance():Main
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new Main();
				_singletonLock = false;
			}
			return _instance;
		}
		
		
		/**
		 * A reference to the base display object container.
		 */
		public function get contextView():DisplayObjectContainer
		{
			return _contextView;
		}
		
		
		/**
		 * A reference to the base display object's stage.
		 */
		public function get stage():Stage
		{
			return contextView.stage;
		}
		
		
		/**
		 * A reference to the console. Will return <code>null</code> if the console has
		 * been disabled.
		 */
		public function get console():Console
		{
			return _console;
		}
		
		
		/**
		 * A reference to the FPS monitor. Will return <code>null</code> if the FPS monitor
		 * has been disabled.
		 */
		public function get fpsMonitor():FPSMonitor
		{
			return _fpsMonitor;
		}
		
		
		/**
		 * A reference to the base nativeWindow of the application if it is supported by the
		 * build type. Otherwise it returns the base display object container instead.
		 */
		public function get baseWindow():*
		{
			CONFIG::IS_AIR_BUILD
			{
				if (NativeWindow.isSupported) return contextView.stage.nativeWindow;
			}
			return contextView;
		}
		
		
		/**
		 * Determines whether the application is in fullscreen mode (<code>true</code>) or not
		 * (<code>false</code>).
		 */
		public function get isFullscreen():Boolean
		{
			return (contextView.stage.displayState == StageDisplayState["FULL_SCREEN_INTERACTIVE"]
				|| contextView.stage.displayState == StageDisplayState.FULL_SCREEN);
		}
		
		
		/**
		 * A reference to the setup helper if the build type uses any. Read-only access!
		 */
		public function get setupHelper():*
		{
			return _setupHelper;
		}
		/**
		 * @private
		 */
		public function set setupHelper(v:*):void
		{
			if (_setupHelper) return;
			_setupHelper = v;
		}
		
		
		public function get dataSupportManager():DataSupportManager
		{
			return _dataSupportManager;
		}
		
		
		/**
		 * A reference to the command manager.
		 */
		public function get commandManager():CommandManager
		{
			return _commandManager;
		}
		
		
		/**
		 * A reference to the resource manager.
		 */
		public function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		/**
		 * A reference to the state manager.
		 */
		public function get stateManager():StateManager
		{
			return _stateManager;
		}
		
		
		/**
		 * A reference to the screen manager.
		 */
		public function get screenManager():ScreenManager
		{
			return _screenManager;
		}
		
		
		/**
		 * A reference to the localsettings manager.
		 */
		public function get localSettingsManager():LocalSettingsManager
		{
			return _localSettingsManager;
		}
		
		
		/**
		 * A reference to the key input manager.
		 */
		public function get keyManager():KeyManager
		{
			return _keyManager;
		}
		
		
		/**
		 * A reference to the entity factory.
		 */
		public function get entityFactory():EntityFactory
		{
			return _entityFactory;
		}
		
		
		/**
		 * A reference to the entity manager.
		 */
		public function get entityManager():EntityManager
		{
			return _entityManager;
		}
		
		
		/**
		 * A reference to the entity system manager.
		 */
		public function get entitySystemManager():EntitySystemManager
		{
			return _entitySystemManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onAppInitComplete(command:Command):void 
		{
			/* Time to open the initial application state. */
			stateManager.start();
			//screenManager.start();
		}
		
		
		/**
		 * Global Error Handler.
		 * @private
		 */
		private function onUncaughtError(e:UncaughtErrorEvent):void 
		{
			e.preventDefault();
			var msg:String;
			
			if (e.error is Error)
			{
				var e1:Error = Error(e.error);
				msg = "Name: " + e1.name + ", ErrorID: " + e1.errorID
					+ ", Message: \"" + e1.message + "\""
					+ (e1.getStackTrace() ? "\n" + e1.getStackTrace() : "") + ".";
				Log.error("Uncaught error occured - " + msg);
			}
			else if (e.error is ErrorEvent)
			{
				var e2:ErrorEvent = ErrorEvent(e.error);
				msg = "ErrorID: " + e2.errorID + ", Text: \"" + e2.text + "\".";
				Log.error("Uncaught error event occured - " + msg);
			}
			else
			{
				Log.error("Uncaught error occured - something went abysmally wrong!");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes Main by providing the context view to it. This method is called
		 * only once at start by the Entry class.
		 * 
		 * @private
		 */
		internal function init(contextView:DisplayObjectContainer):void
		{
			_contextView = contextView;
			_instance = this;
			setup();
		}
		
		
		/**
		 * Executes tasks that need to be done before the application init process is being
		 * executed. This typically includes creating the application's UI as well as
		 * instantiating other objects that exist throught the whole application life time.
		 * This method should only ever need to be called once during application life time,
		 * i.e everything that is being set up here should only be necessary to set up once
		 * and exist until the application is closed.
		 * 
		 * @private
		 */
		private function setup():void
		{
			CONFIG::IS_WEB_BUILD
			{
				/* Call JavaScript function to give keyboard focus to web-based Flash content. */
				if (ExternalInterface.available)
				{
					ExternalInterface.call("onFlashContentLoaded");
				}
			}
			
			/* Set up global error listener if this is a release version. */
			if (!AppInfo.IS_DEBUG)
			{
				contextView.loaderInfo.uncaughtErrorEvents.addEventListener(
					UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
			}
			
			/* Set stage reference as early as possible. */
			StageReference.stage = contextView.stage;
			
			/* Ignore whitespace on all XML data files. */
			XML.ignoreWhitespace = true;
			XML.ignoreProcessingInstructions = true;
			XML.ignoreComments = true;
			
			/* Init the data model registry. */
			Registry.init();
			
			/* Create managers. */
			_dataSupportManager = new DataSupportManager();
			_commandManager = new CommandManager();
			_resourceManager = new ResourceManager();
			_stateManager = new StateManager();
			_screenManager = new ScreenManager();
			_localSettingsManager = new LocalSettingsManager();
			_keyManager = new KeyManager();
			
			/* Create entity architecture-related objects. */
			tickSignal = new TickSignal();
			renderSignal = new RenderSignal();
			_entityManager = new EntityManager();
			_entitySystemManager = new EntitySystemManager();
			_entityFactory = new EntityFactory();
			
			/* We make the logger available as soon as possible so that any log
			 * messages from the hexagonLib come through even before the console
			 * would be available! */
			HLog.registerExternalLogger(Log);
			
			/* Start initialization phase. */
			commandManager.execute(new InitApplicationCommand(), onAppInitComplete);
		}
		
		
		/**
		 * @private
		 */
		public function setupDebugUtilities():void
		{
			if (!_console && Registry.config.consoleEnabled)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					contextView.addChild(_utilityContainer);
				}
				_console = new Console(_utilityContainer);
				_console.init();
			}
			
			if (!_fpsMonitor && Registry.config.fpsMonitorEnabled)
			{
				if (!_utilityContainer)
				{
					_utilityContainer = new Sprite();
					contextView.addChild(_utilityContainer);
				}
				_fpsMonitor = new FPSMonitor(_utilityContainer);
			}
		}
	}
}
