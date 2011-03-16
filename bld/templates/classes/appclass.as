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
package @top_package@
{
	import @top_package@.core.preload.IPreloadable;
	import @top_package@.core.preload.Preloader;
	
	
	[SWF(width="@swf_width@", height="@swf_height@", backgroundColor="#@swf_bgcolor@", frameRate="@swf_framerate@")]
	
	/**
	 * The App class acts as the 'front door' of your application. This is the class
	 * that the compiler is being told to compile and from which all other application
	 * logic is being initiated.
	 * 
	 * Ant auto-generated file. Do not edit!
	 */
	[Frame(factoryClass="@top_package@.AppPreloader")]
	public class App implements IPreloadable
	{
		/** @private */
		private var _main:Main;
		
		
		/**
		 * Invoked by the preloader after the application has been fully preloaded.
		 * 
		 * @param preloader a reference to the preloader.
		 */
		public function onApplicationPreloaded(preloader:Preloader):void
		{
			_main = new Main(preloader);
		}
	}
}
