module redis.commands.list;

mixin template listCommands()
{
	/*
	 * Set the value of an element in a list by its index. 
	 * @return 
	 */
	bool lset(string key,int index,string value)
	{
		auto result = send!(bool)("LSET",key,index,value);
		return result;
	}
	
	/*
	 * Prepend one or multiple values to a list. 
	 * @return 
	 */
	int lpush(T...)(string key,string args)
	{
		auto result = send!(int)("LPUSH",key,args);
		return result;
	}

	/*
	 * Remove and get the first element in a list. 
	 * @return 
	 */
	string lpop(string key)
	{
		auto result = send!(string)("LPOP",key);
		return result;
	}

	/*
	 * Get a range of elements from a list. 
	 * @return
	 */
	string[] lrange(string key,int start,int end)
	{
		auto result = send("lrange",key,start,end);
		return result.toStringArray;
	}


	/*
	 * Get the length of a list. 
	 * @return
	 */
	int llen(string key)
	{
		auto result = send!(int)("LLEN",key);
		return result;
	}
}
