module redis.redis;

import std.stdio;
import std.conv;
import std.traits;
import std.json;
import std.exception;
import std.variant;
import std.array;
import std.string;
import std.typetuple;
import std.exception;

public import redis;
public class Redis
{
	import std.socket : TcpSocket, InternetAddress;

	private:
	TcpSocket conn;

	public:

	mixin keyCommands;
	mixin stringCommands;
	mixin hashCommands;
	mixin listCommands;
	mixin setCommands;
	mixin sortedsetCommands;

	/**
	 * Create a new connection to the Redis server
	 */
	this(string host = "127.0.0.1", ushort port = 6379)
	{
		conn = new TcpSocket(new InternetAddress(host, port));
	}

	override string toString()
	{
		return "redis";
	}

	auto opDispatch(string name,T...)(T args)
	{
		//try{
		auto result =  send(name,args);
		//} catch (exception e){
		//return e.msg;
		//}
		return result;
	}

	/**
	 * Call Redis using any type T that can be converted to a string
	 *
	 * Examples:
	 *
	 * ---
	 * send("SET name Adil")
	 * send("SADD", "myset", 1)
	 * send("SADD", "myset", 1.2)
	 * send("SADD", "myset", true)
	 * send("SADD", "myset", "Batman")
	 * send("SREM", "myset", ["$3", "$4"])
	 * send("SADD", "myset", object) //provided 'object' implements toString()
	 * send("GET", "*") == send("GET *")
	 * send("ZADD", "my_unique_json", 1, json.toString());
	 * send("EVAL", "return redis.call('set','lua','LUA')", 0);
	 * ---
	 */
	R send(R = Response, T...)(string key, T args)
	{
		//Implement a write queue here.
		// All encoded responses are put into a write queue and flushed
		// For a send request, flush the queue and listen to a response
		// For async calls, just flush the queue
		// This automatically gives us PubSub

		debug(redis) { writeln(escape(toMultiBulk(key, args)));}
		conn.send(toMultiBulk(key, args));
		Response[] r = receiveResponses(conn, 1);
		return cast(R)(r[0]);
	}

	R send(R = Response)(string cmd)
	{
		debug(redis) { writeln(escape(toMultiBulk(cmd)));}

		conn.send(toMultiBulk(cmd));
		Response[] r = receiveResponses(conn, 1);
		return cast(R)(r[0]);
	}

	/**
	 * Send a string that is already encoded in the Redis protocol
	 */
	R sendRaw(R = Response)(string cmd)
	{
		debug(redis) { writeln(escape(cmd));}

		conn.send(cmd);
		Response[] r = receiveResponses(conn, 1);
		return cast(R)(r[0]);
	}

	/**
	 * Send a series of commands as a pipeline
	 *
	 * Examples:
	 *
	 * ---
	 * pipeline(["SADD shopping_cart Shirt", "SADD shopping_cart Pant", "SADD shopping_cart Boots"])
	 * ---
	 */
	import std.traits : isSomeChar;
	Response[] pipeline(C)(C[][] commands) if (isSomeChar!C)
	{
		import std.array : appender;

		auto app = appender!(C[])();
		foreach(c; commands) {
			app ~= encode(c);
		}

		conn.send(app.data);
		return receiveResponses(conn, commands.length);
	}

	/**
	 * Execute commands in a MULTI/EXEC block.
	 *
	 * @param all - (Default: false) - By default, only the results of a transaction are returned. If set to "true", the results of each queuing step is also returned.
	 *
	 * Examples:
	 *
	 * ---
	 * transaction(["SADD shopping_cart Shirt", "INCR shopping_cart_ctr"])
	 * ---
	 */
	Response[] transaction(string[] commands, bool all = false)
	{
		auto cmd = ["MULTI"];
		cmd ~= commands;
		cmd ~= "EXEC";
		auto rez = pipeline(cmd);

		if(all) {
			return rez;
		}

		auto resp = rez[$ - 1];
		if(resp.isError()) {
			throw new RedisResponseException(resp.value);
		}

		return resp.values;
	}

	/**
	 * Simplified call to EVAL
	 *
	 * Examples:
	 *
	 * ---
	 * Response r = eval("return redis.call('set','lua','LUA_AGAIN')");
	 * r.value == "LUA_AGAIN";
	 *
	 * Response r1 = redis.eval("return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}", ["key1", "key2"], ["first", "second"]);
	 * writeln(r1); // [key1, key2, first, second]
	 *
	 * Response r1 = redis.eval("return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}", [1, 2]);
	 * writeln(r1); // [1, 2]
	 * ---
	 */
	Response eval(K = string, A = string)(string lua_script, K[] keys = [], A[] args = [])
	{
		conn.send(toMultiBulk("EVAL", lua_script, keys.length, keys, args));
		Response[] r = receiveResponses(conn, 1);
		return (r[0]);
	}

	Response evalSha(K = string, A = string)(string sha1, K[] keys = [], A[] args = [])
	{
		conn.send(toMultiBulk("EVALSHA", sha1, keys.length, keys, args));
		Response[] r = receiveResponses(conn, 1);
		return (r[0]);
	}

}



unittest
{
	auto redis = new Redis();
	redis.FLUSHALL();
	debug(redis) { writeln("\n\n\nredis commands test.....");}
	assert(redis.set("xxkey","10") == true);
	assert(redis.get("xxkey") == "10");
	assert(redis.exists("xxkey") == true);
	//assert(redis.dump("xxkey") == "\u0000\xC0\n\b\u0000ײ\xBB\xFA\xA7\xB7\xE9\x83");
	assert(redis.del("xxkey") == 1);
	assert(redis.set("xxkey","10") == true);
	assert(redis.expire("xxkey",20) == 1);
	assert(redis.expire("yykey",20) == 0);
	assert(redis.expireat("xxkey",1798736461) == 1);
	assert(redis.expireat("yykey",1798736461) == 0);
	redis.set("ssoxx","1");
	redis.set("bboxx","2");
	redis.set("ssmxx","3");
	assert(redis.keys("*m*") == ["ssmxx"]);
	redis.set("abc","test",10);
	assert(redis.ttl("abc") == 10);
	redis.set("incrkey","10");
	assert(redis.incr("incrkey") == 11);

	assert(redis.hset("website","google","google.com") == 1);
	assert(redis.hset("website","baidu","baidu.com") == 1);
	assert(redis.hset("website","putao","putao.com") == 1);
	assert(redis.hset("website","google","google.com") == 0);
	assert(redis.hlen("website") == 3);
	assert(redis.hget("website","google") == "google.com");
	assert(redis.hdel("website","google") == 1);
	assert(redis.hlen("website") == 2);
	assert(redis.hdel("website","baidu","putao") == 2);
	assert(redis.hlen("website") == 0);


	assert(redis.lpush("language","c") == 1);
	assert(redis.lpush("language","php") == 2);
	assert(redis.llen("language") == 2);
	assert(redis.lset("language",0,"d") == true);
	assert(redis.lpop("language") == "d");
	assert(redis.llen("language") == 1);
	assert(redis.lrange("language",0,1) == ["c"]);


	debug(redis) { writeln("redis commands test end\n\n\n");}

	auto response = redis.send("LASTSAVE");
	assert(response.type == ResponseType.Integer);

	assert(redis.send!(bool)("SET", "name", "adil baig"));

	redis.send("SET emptystring ''");
	response = redis.send("GET emptystring");
	assert(response.value == "");

	response = redis.send("GET name");
	assert(response.type == ResponseType.Bulk);
	assert(response.value == "adil baig");

	/* START Test casting byte[] */
	assert(cast(byte[])response == "adil baig"); //Test casting to byte[]
	assert(cast(byte[])response == [97, 100, 105, 108, 32, 98, 97, 105, 103]);

	redis.send("SET mykey 10");
	response = redis.send("INCR mykey");
	assert(response.type == ResponseType.Integer);
	assert(response.intval == 11);
	auto bytes = (cast(ubyte[])response);
	assert(bytes.length == response.intval.sizeof);
	assert(bytes[0] == 11);
	/* END Test casting byte[] */

	assert(redis.send!(string)("GET name") == "adil baig");

	response = redis.send("GET nonexistentkey");
	assert(response.type == ResponseType.Nil);
	assert(cast(ubyte[])response == []);

	redis.send("DEL myset");
	redis.send("SADD", "myset", 1.2);
	redis.send("SADD", "myset", 1);
	redis.send("SADD", "myset", true);
	redis.send("SADD", "myset", "adil");
	redis.send("SADD", "myset", 350001939);
	redis.send("SADD", ["myset","$4"]);
	auto r = redis.send("SMEMBERS myset");
	assert(r.type == ResponseType.MultiBulk);
	assert(r.values.length == 6);

	//Check pipeline
	redis.send("DEL ctr");
	auto responses = redis.pipeline(["SET ctr 1", "INCR ctr", "INCR ctr", "INCR ctr", "INCR ctr"]);

	assert(responses.length == 5);
	assert(responses[0].type == ResponseType.Status);
	assert(responses[1].intval == 2);
	assert(responses[2].intval == 3);
	assert(responses[3].intval == 4);
	assert(responses[4].intval == 5);

	redis.send("DEL buddies");
	auto buddiesQ = ["SADD buddies Batman", "SADD buddies Spiderman", "SADD buddies Hulk", "SMEMBERS buddies"];
	Response[] buddies = redis.pipeline(buddiesQ);
	assert(buddies.length == buddiesQ.length);
	assert(buddies[0].type == ResponseType.Integer);
	assert(buddies[1].type == ResponseType.Integer);
	assert(buddies[2].type == ResponseType.Integer);
	assert(buddies[3].type == ResponseType.MultiBulk);
	assert(buddies[3].values.length == 3);

	//Check transaction
	redis.send("DEL ctr");
	responses = redis.transaction(["SET ctr 1", "INCR ctr", "INCR ctr"], true);
	assert(responses.length == 5);
	assert(responses[0].type == ResponseType.Status);
	assert(responses[1].type == ResponseType.Status);
	assert(responses[2].type == ResponseType.Status);
	assert(responses[3].type == ResponseType.Status);
	assert(responses[4].type == ResponseType.MultiBulk);
	assert(responses[4].values[0].type == ResponseType.Status);
	assert(responses[4].values[1].intval == 2);
	assert(responses[4].values[2].intval == 3);

	redis.send("DEL ctr");
	responses = redis.transaction(["SET ctr 1", "INCR ctr", "INCR ctr"]);
	assert(responses.length == 3);
	assert(responses[0].type == ResponseType.Status);
	assert(responses[1].intval == 2);
	assert(responses[2].intval == 3);

	response = redis.send("EVAL", "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}", 2, "key1", "key2", "first", "second");
	assert(response.values.length == 4);
	assert(response.values[0].value == "key1");
	assert(response.values[1].value == "key2");
	assert(response.values[2].value == "first");
	assert(response.values[3].value == "second");

	//Same as above, but simpler
	response = redis.eval("return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}", ["key1", "key2"], ["first", "second"]);
	assert(response.values.length == 4);
	assert(response.values[0].value == "key1");
	assert(response.values[1].value == "key2");
	assert(response.values[2].value == "first");
	assert(response.values[3].value == "second");

	response = redis.eval("return redis.call('set','lua','LUA_AGAIN')");
	assert(cast(string)redis.send("GET lua") == "LUA_AGAIN");

	// A BLPOP times out to a Nil multibulk
	response = redis.send("BLPOP nonExistentList 1");
	assert(response.isNil());
}
