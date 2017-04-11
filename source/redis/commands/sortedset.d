module redis.commands.sortedset;

mixin template sortedsetCommands()
{
	/*
	 * Add one or more members to a sorted set, or update its score if it already exists. 
	 * @return 
	 */
	int zadd(string key,int score,string value)
	{
		auto result = send!(int)("ZADD",key,score,value);
		return result;
	}
	
	/*
	 * Return a range of members in a sorted set, by index. 
	 * @return
	 */
	string[] zrange(string key,int min,int max)
	{
		auto result = send("ZRANGE",key,min,max,"WITHSCORES");
		return result.toStringArray;
	}

	/*
	 * Get the number of members in a sorted set. 
	 * @return
	 */
	int zcard(string key)
	{
		auto result = send!(int)("ZCARD",key);
		return result;
	}

	/*
	 * Count the members in a sorted set with scores within the given values. 
	 * @return
	 */
	int zcount(string key,int min,int max)
	{
		auto result = send!(int)("ZCOUNT",key,min,max);
		return result;
	}
}
