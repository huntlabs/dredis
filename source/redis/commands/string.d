module redis.commands.string;

mixin template stringCommands()
{
	/*
	 * Set key to hold the string value. If key already holds a value, it is overwritten
	 * @return 
	 */
	bool set(string key,string value)
	{
		import std.stdio;writeln(__FUNCTION__,"\t",key,"\t",value);
		auto result = send!(bool)("SET",key,value);
		return result;
	}
	bool set(string key,string value,int timeout)
	{
		auto result = send!(bool)("SET",key,value,"EX",timeout);
		return result;
	}
	bool set(string key,string value,string flag)
	{
		auto result = send!(bool)("SET",key,value,flag);
		return result;
	}
	bool set(string key,string value,string flag,int timeout)
	{
		auto result = send!(bool)("SET",key,value,flag,"EX",timeout);
		return result;
	}

	/*
	 * Increments the number stored at key by one.
	 * @return
	 */
	int incr(string key)
	{
		auto result = send!(int)("INCR",key);
		return result;
	}
	
	/*
	 * Get the value of key. 
	 * @return
	 */
	string get(string key)
	{
		auto result = send!(string)("GET",key);
		return result;
	}

	/*
	 * If key already exists and is a string, this command appends the value at the end of the string. 
	 * If key does not exist it is created and set as an empty string.
	 * @return
	 */
	string append(string key,string value)
	{
		auto result = send!(string)("APPEND",key,value);
		return result;
	}

}
