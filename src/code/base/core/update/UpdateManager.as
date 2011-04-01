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
package base.core.update
{
	import air.update.ApplicationUpdater;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import base.core.debug.Log;
	import base.data.Config;
	import base.data.Registry;
	import base.event.UpdateManagerEvent;

	import com.hexagonstar.exception.SingletonException;

	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	
	/**
	 * Handles updates for AIR applications.
	 */
	public class UpdateManager extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _instance:UpdateManager;
		/** @private */
		private static var _singletonLock:Boolean = false;
		/** @private */
		private var _updater:ApplicationUpdater;
		/** @private */
		private var _config:Config;
		/** @private */
		private var _isInstallPostponed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateManager()
		{
			if (!_singletonLock) throw new SingletonException(this);
			setup();
			addEventListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * initialize
		 */
		public function initialize():void
		{
			if (_updater)
			{
				_updater.initialize();
			}
		}
		
		
		/**
		 * checkForUpdate
		 */
		public function checkForUpdate():void
		{
			if (!_updater) return;
			_isInstallPostponed = false;
			_updater.checkNow();
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			removeEventListeners();
			_updater = null;
			_instance = null;
		}
		
		
		/**
		 * Returns a String Representation of UpdateManager.
		 * 
		 * @return A String Representation of UpdateManager.
		 */
		override public function toString():String
		{
			return "[UpdateManager]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the singleton instance of the class.
		 */
		public static function get instance():UpdateManager
		{
			if (_instance == null)
			{
				_singletonLock = true;
				_instance = new UpdateManager();
				_singletonLock = false;
			}
			return _instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onInitialized(e:UpdateEvent):void 
		{
			if (_updater)
			{
				Log.debug("Initialized. (currentVersion: " + _updater.currentVersion + ").", this);
				_updater.checkNow();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onUpdateStatus(e:StatusUpdateEvent):void 
		{
			if (e.available)
			{
				finish();
			}
			else
			{
				finish();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onBeforeInstall(e:UpdateEvent):void
		{
			if (_isInstallPostponed)
			{
				e.preventDefault();
				_isInstallPostponed = false;
			}
		}
		
		
		/**
		 * @private
		 */
		private function onDownloadStarted(e:UpdateEvent):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onProgress(e:ProgressEvent):void 
		{
			//Log.debug("Progress ...", this);
		}
		
		
		/**
		 * @private
		 */
		private function onDownloadComplete(e:UpdateEvent):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onUpdateError(e:StatusUpdateErrorEvent):void 
		{
			Log.warn("Update Error: " + e.text + " (errorID: " + e.errorID + ", subErrorID: "
				+ e.subErrorID + ").", this);
			dispatchEvent(e);
		}
		
		
		/**
		 * @private
		 */
		private function onDownloadError(e:DownloadErrorEvent):void 
		{
			Log.warn("Update Download Error: " + e.text, this);
			finish();
		}
		
		
		/**
		 * @private
		 */
		private function onError(e:ErrorEvent):void
		{
			Log.warn("Update Error: " + e.text, this);
			dispatchEvent(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			_config = Registry.config;
			
			if (_config.updateURL != null && _config.updateURL.length > 0)
			{
				_updater = new ApplicationUpdater();
				_updater.updateURL = _config.updateURL;
				_updater.delay = _config.updateCheckInterval;
			}
		}
		
		
		/**
		 * @private
		 */
		private function addEventListeners():void
		{
			if (!_updater) return;
			_updater.addEventListener(UpdateEvent.INITIALIZED, onInitialized);
			_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus);
			_updater.addEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall);
			_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onUpdateError);
			_updater.addEventListener(UpdateEvent.DOWNLOAD_START, onDownloadStarted);
			_updater.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
			_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
			_updater.addEventListener(ErrorEvent.ERROR, onError);
		}
		
		
		/**
		 * @private
		 */
		private function removeEventListeners():void
		{
			if (!_updater) return;
			_updater.removeEventListener(UpdateEvent.INITIALIZED, onInitialized);
			_updater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus);
			_updater.removeEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall);
			_updater.removeEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onUpdateError);
			_updater.removeEventListener(UpdateEvent.DOWNLOAD_START, onDownloadStarted);
			_updater.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_updater.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
			_updater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
			_updater.removeEventListener(ErrorEvent.ERROR, onError);
		}
		
		
		/**
		 * @private
		 */
		private function finish():void
		{
			dispatchEvent(new UpdateManagerEvent(UpdateManagerEvent.FINISHED));
		}
	}
}
