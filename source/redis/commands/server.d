module redis.commands.server;

mixin template serverCommands()
{
	/*
	 * Remove all keys from all databases.
	 * @return
	 */
	void flushall()
	{
		send("FLUSHALL");
	}
	
}
