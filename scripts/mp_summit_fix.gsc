#include maps\mp\_utility;

init()
{
	if (getDvar("mapname") != "mp_summit") return;

	thread killTrigger((0, 1280, -156 -384), 4096, 256);
}
