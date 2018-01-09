# dredis
Flexible and feature-complete Redis client for Dlang

```d
import std.stdio;
import redis;

void main()
{
	writeln("Edit source/app.d to start your project.");
	
    auto redis = new Redis("10.1.11.168",6379,"123456");
	
    redis.set("redie_User_31","password");
    writeln(redis.get("redie_User_31"));
}
```
