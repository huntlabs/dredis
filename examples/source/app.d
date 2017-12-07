import std.stdio;
import redis;

void main()
{
	writeln("Edit source/app.d to start your project.");
	
    auto redis = new Redis("redis.host = r-uf6da5702d0bbeb4.redis.rds.aliyuncs.com",6379,"Putao123");
	
    redis.set("redie_User_31","password");
    int i = 10;
    while(i>0){
        assert(cast(ubyte[])redis.get("redie_User_31") == [7, 118, 0, 2, 31, 0, 0, 0, 4, 11, 0, 49, 51, 51, 51, 51, 51, 51, 51, 51, 48, 53, 4, 2, 0, 48, 53, 4, 12, 0, 72, 113, 108, 106, 53, 76, 121, 72, 55, 121, 107, 108, 4, 40, 0, 53, 67, 56, 56, 53, 68, 57, 49, 67, 50, 49, 57, 52, 69, 50, 69, 50, 52, 69, 50, 70, 65, 50, 69, 52, 65, 48, 55, 70, 54, 67, 67, 51, 56, 48, 50, 67, 53, 67, 54, 4, 0, 0, 4, 2, 0, 56, 54, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 3, 57, 69, -61, 89, 0, 0, 0, 0, 3, 30, 45, -58, 89, 0, 0, 0, 0]);
        i--;
    }
}
