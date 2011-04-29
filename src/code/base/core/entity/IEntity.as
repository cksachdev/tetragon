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
package base.core.entity
{
	import base.core.IDisposable;

	import flash.utils.Dictionary;
	
	
	/**
	 * 
	 */
	public interface IEntity extends IDisposable
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a compoment with the entity.
		 * 
		 * @param component Component to be added.
		 */
		function addComponent(component:Object):Boolean;
		
		
		/**
		 * Retrieves a components instance based on class name.
		 * 
		 * @param componentClass class name of component to be retrieved.
		 */
		function getComponent(componentClass:Class):*;
		
		
		/**
		 * retrieves the dictionary contaning all the entities components.
		 * 
		 * @return a dictionary of the entites components with the component Class as the key.
		 * 
		 */
		function getComponents():Dictionary;
		
		
		/**
		 * Unregisters a component from the entity.
		 * 
		 * @param componentClass class def of component to be unregistered.
		 */
		function removeComponent(componentClass:Class):void;
		
		
		/**
		 * Gets the entities unique ID.
		 * 
		 * @return id unique ID.
		 */
		function get id():String
	}
}
