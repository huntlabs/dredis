module redis.commands.hash;

mixin template hashCommands()
{
	/*
	 * Sets field in the hash stored at key to value. 
	 * @return 
	 * 1 if field is a new field in the hash and value was set.
	 * 0 if field already exists in the hash and the value was updated.
	 */
	int hset(string key,string field,string value)
	{
		auto result = send!(int)("HSET",key,field,value);
		return result;
	}

	/*
	 * Returns the value associated with field in the hash stored at key. 
	 * @return
	 */
	string hget(string key,string field)
	{
		auto result = send!(string)("HGET",key,field);
		return result;
	}


	/*
	 * Returns the number of fields contained in the hash stored at key. 
	 * @return
	 */
	int hlen(string key)
	{
		auto result = send!(int)("HLEN",key);
		return result;
	}

	/*
	 * Removes the specified fields from the hash stored at key.
	 * @return the number of fields that were removed from the hash, not including specified but non existing fields.
	 */
	int hdel(T...)(string key,T args)
	{
		auto result = send!(int)("HDEL",key,args);
		return result;
	}

}
