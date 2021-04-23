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

	coords = [];
	coords[0] = (1680, -256, -5);
	coords[1] = (-761, 342, 8);
	coords[2] = (-1414, -203, 7);
	coords[3] = (-1354, 1047, 12);
	coords[4] = (97, -488, -10);
	coords[5] = (845, -730, -14);
	coords[6] = (1871, -1342, 23);
	coords[7] = (-101, -241, 33);
	coords[8] = (-335, 232, 5);
	level.ttt.coords.pickups["mp_trailerpark"] = coords;

	coords = [];
	coords[0] = (-1216, 706, -7);
	coords[1] = (-1469, 266, -7);
	coords[2] = (-4, 883, 80);
	coords[3] = (13, -178, 8);
	coords[4] = (597, -689, 0);
	coords[5] = (1028, -373, 0);
	coords[6] = (-2051, -1489, -55);
	coords[7] = (-1839, -493, -7);
	coords[8] = (-1940, -33, -7);
	coords[9] = (-763, -1296, 136);
	coords[10] = (248, -1723, -7);
	coords[11] = (-768, -2037, 0);
	coords[12] = (-939, -725, 136);
	level.ttt.coords.pickups["mp_nightshift"] = coords;
}
