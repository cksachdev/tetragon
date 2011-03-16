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
package base.data
{
	/**
	 * IDataObject Interface
	 */
	public interface IDataObject
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * initializes the DataObject, optionally assigning it an ID. This should be
		 * called immediately after the DataObject is created.
		 */
		function initialize():void;
		
		
		/**
		 * Disposes the DataObject by removing all components and unregistering it from
		 * the name manager.
		 * 
		 * <p>DataObjects are automatically removed from any groups/sets that they are
		 * members of when they are disposed.</p>
		 * 
		 * <p>Currently this will not invalidate any other references to the DataObject so
		 * the DataObject will only be cleaned up by the garbage collector if those are
		 * set to null manually.</p>
		 */
		function dispose():void;
		
		
		/**
		 * Returns a string representation of the object. Optionally a number of arguments
		 * can be specified, typically properties that are output together with the object
		 * name to provide additional information about the object.
		 * 
		 * @example
		 * <pre>
		 *    // overriden toString method to include a size property:
		 *    override public function toString(...args):String
		 *    {
		 *        return super.toString("size=" + size);
		 *    }
		 * </pre>
		 * 
		 * @param args an optional, comma-delimited list of class properties that should be
		 *            output together with the object name.
		 * @return A string representation of the object.
		 */
		function toString(...args):String;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the data object.
		 */
		function get id():String;
		function set id(v:String):void;
	}
}
