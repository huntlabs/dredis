module redis.commands.connection;

mixin template connectionCommands()
{
	/*
	 * Ping the server.
	 * @return
	 */
	string ping()
	{
		auto result = send!(string)("PING");
		return result;
	}
	
}
