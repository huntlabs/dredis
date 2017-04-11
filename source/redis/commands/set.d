module redis.commands.set;

mixin template setCommands()
{
	/*
	 * Add one or more members to a set. 
	 * @return 
	 */
	int sadd(T...)(string key,T args)
	{
		auto result = send!(int)("SADD",key,args);
		return result;
	}
	
	/*
	 * Remove and return one or multiple random members from a set. 
	 * @return 
	 */
	string spop(string key)
	{
		auto result = send!(string)("SPOP",key);
		return result;
	}

	/*
	 * Add multiple sets. 
	 * @return
	 */
	string[] sunion(string... )(string args)
	{
		auto result = send("SUNION",args);
		return result.toStringArray;
	}


	/*
	 * Get the number of members in a set. 
	 * @return
	 */
	int scard(string key)
	{
		auto result = send!(int)("SCARD",key);
		return result;
	}

}
