init()
{
	level.ttt.coords = spawnStruct();
	level.ttt.coords.pickups = [];

	coords = [];
	coords[0] = (2189, -1920, -46);
	coords[1] = (649, -1658, -64);
	coords[2] = (1203, -1171, -135);
	coords[3] = (805, -862, -135);
	coords[4] = (1893, -81, -67);
	coords[5] = (1731, 1483, -89);
	coords[6] = (393, 1731, 6);
	coords[7] = (305, -3, -67);
	coords[8] = (-1046, -976, -63);
	coords[9] = (-474, -731, -71);
	coords[10] = (173, -1909, -57);
	coords[11] = (3214, -1779, -54);
	coords[12] = (2883, -842, -51);
	coords[13] = (2594, 1284, -63);
	coords[14] = (2144, 2340, -63);
	coords[15] = (1065, 1224, -12);
	coords[16] = (-785, 1175, -4);

	level.ttt.coords.pickups["mp_abandon"] = coords;
}
