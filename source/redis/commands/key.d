module redis.commands.key;

mixin template keyCommands()
{
	/*
	 * Removes the specified keys.
	 * @return The number of keys that were removed.
	 */
	int del(string...)(string args)
	{
		auto result = send!(int)("DEL",args);	
		return result;
	}
	/*
	 * Serialize the value stored at key in a Redis-specific format and return it to the user. 
	 * @return the serialized value.
	 */
	void dump(string key)
	{
		auto result = send("DUMP",key);
		//return null;
	}
	/*
	 * @return Returns if key exists.
	 */
	bool exists(string key)
	{
		auto result = send!(bool)("EXISTS",key);
		return result;
	}
	/*
	 * Set a timeout on key.
	 * @return
	 * 1 if the timeout was set.
	 * 0 if key does not exist or the timeout could not be set.
	 */
	int expire(string key,int timeout)
	{
		auto result = send!(int)("EXPIRE",key,timeout);
		return result;
	}
	/*
	 * Set a unixtime timeout on key.
	 * @return
	 * 1 if the timeout was set.
	 * 0 if key does not exist or the timeout could not be set.
	 */
	int expireat(string key,int timeout)
	{
		auto result = send!(int)("EXPIREAT",key,timeout);
		return result;
	}
	/*
	 * @return Returns all keys matching pattern.
	 */
	string[] keys(string pattern)
	{
		auto result = send("KEYS",pattern);
		//return result;
		debug(redis) { writeln(typeid(result),result,"type : ",result.type," value : ",result.value,);}
		return result.toStringArray;
	}
	/*
	 * Atomically transfer a key from a source Redis instance to a destination Redis instance. 
	 * @return The command returns OK on success, or NOKEY if no keys were found in the source instance.
	 */
	bool migrate(string...)(string host,string port,string args)
	{
		auto result = send!(bool)("MIGRATE",host,port,args);
		return result;
	}
	/*
	 * @return TTL in seconds, or a negative value in order to signal an error (see the description above).
	 */
	int ttl(string key)
	{
		auto result = send!(int)("TTL",key);
		return result;
	}
}
