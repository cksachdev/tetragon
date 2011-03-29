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
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import base.core.debug.Log;
	import base.data.Config;
	import base.event.UpdateManagerEvent;

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
		
		private var _updater:ApplicationUpdaterUI;
		private var _config:Config;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateManager(config:Config)
		{
			_config = config;
			setup();
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
			if (_updater)
			{
				_updater.isCheckForUpdateVisible = true;
				_updater.checkNow();
			}
		}
		
		
		/**
		 * Returns a String Representation of UpdateManager.
		 * @return A String Representation of UpdateManager.
		 */
		override public function toString():String
		{
			return "[UpdateManager]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get applicationUpdater():ApplicationUpdaterUI
		{
			return _updater;
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
				//_updater.checkNow();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onProgress(e:ProgressEvent):void 
		{
			Log.debug("progress");
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
		private function onUpdateError(e:StatusUpdateErrorEvent):void 
		{
			Log.warn("Update Error: " + e.text + " (errorID: " + e.errorID + ", subErrorID: "
				+ e.subErrorID + ").", this);
			dispatchEvent(e);
		}
		
		
		/**
		 * @private
		 */
		private function onError(e:ErrorEvent):void
		{
			Log.warn("Update Error: " + e.text, this);
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
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			if (_config.updateURL != null && _config.updateURL.length > 0)
			{
				_updater = new ApplicationUpdaterUI();
				_updater.updateURL = _config.updateURL;
				_updater.delay = _config.updateCheckInterval;
				_updater.isCheckForUpdateVisible = _config.updateCheckVisible;
				_updater.isDownloadProgressVisible = _config.updateDownloadProgressVisible;
				_updater.isDownloadUpdateVisible = _config.updateDownloadUpdateVisible;
				_updater.isFileUpdateVisible = _config.updateFileUpdateVisible;
				
				/* Custom comparison function that takes build nr. into account.
				 * Version string structure is major.minor.maintenance.build.
				 * Only numbers are allowed. */
				_updater.isNewerVersionFunction = function(cv:String, nv:String):Boolean
				{
					var c:Array = cv.split(".");
					var n:Array = nv.split(".");
					if (int(n[0]) > int(c[0])) return true;
					if (int(n[1]) > int(c[1])) return true;
					if (int(n[2]) > int(c[2])) return true;
					if (int(n[3]) > int(c[3])) return true;
					return false;
				};
				
				_updater.addEventListener(UpdateEvent.INITIALIZED, onInitialized);
				_updater.addEventListener(ProgressEvent.PROGRESS, onProgress);
				_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus);
				_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR,
					onUpdateError);
				_updater.addEventListener(ErrorEvent.ERROR, onError);
				_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onDownloadError);
			}
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
