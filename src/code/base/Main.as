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
	import base.core.entity.EntityManager;
	import base.core.entity.EntitySystemManager;
	import base.data.Registry;
	import base.view.ApplicationView;
	import base.view.screen.ScreenManager;

	import com.hexagonstar.util.debug.HLog;
	import com.hexagonstar.util.display.StageReference;

	import org.swiftsuspenders.Injector;

	import flash.display.*;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.system.ApplicationDomain;
	
	
	/**
	 * The main hub of the application.
	 */
	public class Main
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:Main;
		/** @private */
		private var _contextView:DisplayObjectContainer;
		/** @private */
		private var _applicationView:ApplicationView;
		/** @private */
		private var _setupHelper:*;
		/** @private */
		private var _injector:Injector;
		/** @private */
		private var _entityManager:EntityManager;
		/** @private */
		private var _entitySystemManager:EntitySystemManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructs a new App instance.
		 */
		public function Main(contextView:DisplayObjectContainer)
		{
			_contextView = contextView;
			_instance = this;
			
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The instance of Main.
		 */
		public static function get instance():Main
		{
			return _instance;
		}
		
		
		/**
		 * A reference to the base display object container.
		 */
		public function get contextView():DisplayObjectContainer
		{
			return _contextView;
		}
		
		
		public function get applicationView():ApplicationView
		{
			if (!_applicationView) _applicationView = new ApplicationView(this);
			return _applicationView;
		}
		
		
		/**
		 * A reference to the console. Will return <code>null</code> if the console has
		 * been disabled.
		 */
		public function get console():Console
		{
			return applicationView.console;
		}
		
		
		/**
		 * A reference to the FPS monitor. Will return <code>null</code> if the FPS monitor
		 * has been disabled.
		 */
		public function get fpsMonitor():FPSMonitor
		{
			return applicationView.fpsMonitor;
		}
		
		
		/**
		 * A reference to the screen manager.
		 */
		public function get screenManager():ScreenManager
		{
			return applicationView.screenManager;
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
		
		
		/**
		 * The application's main IoC injector.
		 */
		public function get injector():Injector
		{
			if (!_injector)
			{
				_injector = new Injector();
				_injector.applicationDomain = contextView && contextView.loaderInfo
					? contextView.loaderInfo.applicationDomain
					: ApplicationDomain.currentDomain;
			}
			return _injector;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onAppInitComplete(command:Command):void 
		{
			/* Start the UI */
			applicationView.start();
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
			
			/* Create entity architecture-related objects. */
			_entityManager = new EntityManager();
			_entitySystemManager = new EntitySystemManager(injector);
			
			/* Do base IoC injection mappings. */
			//injector.mapValue(EntityManager, _entityManager);
			//injector.mapValue(EntitySystemManager, _entitySystemManager);
			
			/* CommandManager requires a reference to Main. */
			CommandManager.instance.main = this;
			
			/* Init the data model registry. */
			Registry.init();
			
			contextView.addChild(applicationView);
			
			/* We make the logger available as soon as possible so that any log
			 * messages from the hexagonLib come through even before the console
			 * would be available! */
			HLog.registerExternalLogger(Log);
			
			/* Start initialization phase. */
			CommandManager.instance.execute(new InitApplicationCommand(), onAppInitComplete);
		}
	}
}
