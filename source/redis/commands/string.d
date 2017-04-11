module redis.commands.string;

mixin template stringCommands()
{
	/*
	 * Set key to hold the string value. If key already holds a value, it is overwritten
	 * @return 
	 */
	bool set(string key,string value)
	{
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

}
