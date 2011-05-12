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
	 * A DataList is a data structure that stores a list of data objects that belong
	 * together.
	 */
	public class DataList extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A map that stores objects of type DataListItem.
		 */
		private var _items:Object;
		
		private var _dataType:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param id
		 * @param dataType
		 */
		public function DataList(id:String, dataType:String = null)
		{
			_id = id;
			_dataType = dataType;
			_items = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new list item in the data list mapped under the specified id.
		 * 
		 * @param itemID The ID to map the new list item under.
		 * @return true if the item was created, false if an item with the id already
		 *         exists in the map.
		 */
		public function createItem(itemID:String):Boolean
		{
			if (_items[itemID]) return false;
			_items[itemID] = new DataListItem();
			return true;
		}
		
		
		/**
		 * Creates a new dataset with the specified setID in the list item that is
		 * mapped in the list under the specified itemID.
		 * 
		 * @param itemID
		 * @param setID
		 * @return true or false.
		 */
		public function createSet(itemID:String, setID:String):Boolean
		{
			var item:DataListItem = _items[itemID];
			if (!item) return false;
			item.createSet(setID);
			return true;
		}
		
		
		/**
		 * Maps a property to the list item which is mapped under the given itemID.
		 * If the item was found and a value is already mapped in the item under
		 * the specified key, it is overwritten.
		 * 
		 * @param itemID The ID of the item in which to map the property.
		 * @param key The key under which the value is mapped in the item.
		 * @param value The property value.
		 * @return true if the property was added successfully, false if the
		 *         specified itemID was not found in the data list.
		 */
		public function mapProperty(itemID:String, key:String, value:*):Boolean
		{
			var item:DataListItem = _items[itemID];
			if (!item) return false;
			item.mapProperty(key, value);
			return true;
		}
		
		
		/**
		 * Maps the specified value under the given key in a data set in the list.
		 * 
		 * @param itemID
		 * @param setID
		 * @param key
		 * @param value
		 * @return true or false.
		 */
		public function mapSetProperty(itemID:String, setID:String, key:String, value:*):Boolean
		{
			var item:DataListItem = _items[itemID];
			if (!item) return false;
			return item.mapSetProperty(setID, key, value);
		}
		
		
		/**
		 * Returns the property that is mapped under the specified key from the list
		 * item that is mapped under the specified itemID. Or return null if the item
		 * is not mapped in the data list or if the property is not mapped in the item.
		 * 
		 * @param itemID
		 * @param key
		 * @return The mapped property or null.
		 */
		public function getProperty(itemID:String, key:String):*
		{
			var item:DataListItem = _items[itemID];
			if (!item) return null;
			return item.getProperty(key);
		}
		
		
		/**
		 * Returns a property from a set that is mapped inside an item in the list.
		 * 
		 * @param itemID
		 * @param setID
		 * @param key
		 * @return The mapped set property or null.
		 */
		public function getSetProperty(itemID:String, setID:String, key:String):*
		{
			var item:DataListItem = _items[itemID];
			if (!item) return null;
			return item.getSetProperty(setID, key);
		}
		
		
		/**
		 * Returns the datalist item that is mapped under the specified itemID.
		 */
		public function getItem(itemID:String):DataListItem
		{
			return _items[itemID];
		}
		
		
		/**
		 * dump
		 */
		public function dump():String
		{
			var s:String = "\nDataList (id: " + _id + ", datatype: " + _dataType + ")";
			for (var key:String in _items)
			{
				s += "\n\titem: " + key + DataListItem(_items[key]).dump();
			}
			return s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The data type that the list represents.
		 */
		public function get dataType():String
		{
			return _dataType;
		}
	}
}


final class DataListItem
{
	private var _properties:Object;
	private var _sets:Object;
	
	public function DataListItem()
	{
		_properties = {};
	}
	
	public function createSet(setID:String):Boolean
	{
		if (!_sets) _sets = {};
		if (_sets[setID]) return false;
		_sets[setID] = new DataListItemSet();
		return true;
	}
	
	public function mapProperty(key:String, value:*):void
	{
		_properties[key] = value;
	}
	
	public function mapSetProperty(setID:String, key:String, value:*):Boolean
	{
		if (!_sets) return false;
		var dataset:DataListItemSet = _sets[setID];
		if (!dataset) return false;
		dataset.mapProperty(key, value);
		return true;
	}
	
	public function getProperty(key:String):*
	{
		return _properties[key];
	}
	
	public function getSetProperty(setID:String, key:String):*
	{
		if (!_sets) return null;
		var dataset:DataListItemSet = _sets[setID];
		if (!dataset) return null;
		return dataset.getProperty(key);
	}
	
	public function dump():String
	{
		var s:String = "";
		var key:String;
		for (key in _properties)
		{
			s += "\n\t\t" + key + ": " + _properties[key];
		}
		for (key in _sets)
		{
			s += "\n\t\tset: " + key + DataListItemSet(_sets[key]).dump();
		}
		return s;
	}
}


final class DataListItemSet
{
	private var _properties:Object;
	
	public function DataListItemSet()
	{
		_properties = {};
	}
	
	public function mapProperty(key:String, value:*):void
	{
		_properties[key] = value;
	}
	
	public function getProperty(key:String):*
	{
		return _properties[key];
	}
	
	public function dump():String
	{
		var s:String = "";
		for (var key:String in _properties)
		{
			s += "\n\t\t\t" + key + ": " + _properties[key];
		}
		return s;
	}
}
