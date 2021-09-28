#include common_scripts\utility;
#include scripts\ttt\_util;

init()
{
	passengerhelicopter = spawnStruct();
	passengerhelicopter.name = "PASSENGER LITTLEBIRD";
	passengerhelicopter.description = "^3Setz dich reeeein.\n^7Bla bla bla.\nBla bla bla.\n\nPress [ ^3[{+smoke}]^7 ] to bla bla.";
	passengerhelicopter.icon = "cardicon_mig";
	passengerhelicopter.onBuy = ::OnBuy;
	passengerhelicopter.getIsAvailable = ::getIsAvailable;
	passengerhelicopter.unavailableHint = &"^1put hint here";

	scripts\ttt\items::registerItem(passengerhelicopter, "traitor");
	scripts\ttt\items::registerItem(passengerhelicopter, "detective");
}

getIsAvailable()
{
	return true;
}

OnBuy()
{
	// mins = level.spawnMins;
	// maxs = level.spawnMaxs;
	// maxs = (maxs[0], maxs[1], maps\mp\killstreaks\_airdrop::getFlyHeightOffset(0, 0, mins[2]));
	// thread drawDebugText(mins, "MINS", (1.0, 0.8, 0.5), 1, 2, 999999);
	// thread drawDebugText(maxs, "MAXS", (1.0, 0.8, 0.5), 1, 2, 999999);
	// thread drawDebugBox(mins, maxs, (1.0, 0.8, 0.5), 999999);

	heli = spawnHelicopter(self, self.origin + anglesToForward(self.angles) * 128 + (0, 0, 128), self.angles, "littlebird_mp" , "vehicle_little_bird_armed");
	heli solid();

	heli.pilot = undefined;
	heli.colliding = false;
	heli.speed = 80;
	heli.accel = 8;
	heli.decel = 10;
	heli.nextXY = undefined;
	heli.nextZ = undefined;
	heli.prevPilotInput = [];
	heli.playerCollisionBlocks = [];
	heli.collisionVertices = [];
	heli.lookAtEnt = spawn("script_origin", heli.origin);
	heli.lookAtEnt enableLinkTo();
	heli.lookAtEnt linkTo(heli, "tag_origin", (512, 0, 0), (0, 0, 0));
	heli setLookAtEnt(heli.lookAtEnt);

	heli vehicle_setSpeed(heli.speed, heli.accel, heli.decel);
	// heli setAirResistance(20);
	heli setMaxPitchRoll(45, 20);
	heli setYawSpeed(120, 50, 80, 0.0);
	heli setTurningAbility(0.8);
	heli setHoverParams(0, 0.0, 0.0);
	heli setJitterParams((0, 0, 0), 0.5, 1.5);

	heli.anchors = []; // note: tag_passenger, tag_pilot1, tag_pilot2, tag_player, tag_turret
	heli.anchor["pilot"] = spawn("script_origin", heli.origin);
	heli.anchor["pilot"] enableLinkTo();
	heli.anchor["pilot"] linkto(heli, "tag_driver", (0, 0, -30), (0, 0, 0));

	// heli setupPlayerCollision();
	// heli setupCollision();

	// heli thread DEBUG();

	heli scripts\ttt\use::makeUsableCustom(
		::OnHeliTrigger,
		::OnHeliAvailable,
		::OnHeliAvailableEnd,
		128
	);
}

setupPlayerCollision()
{
	blocks = [];
	blocks[0]["point"] = (0.2, 0.05, -0.3);
	blocks[1]["point"] = (-0.16, 0.05, -0.3);
	blocks[2]["point"] = (0.2, 0.05, -0.2);
	blocks[3]["point"] = (-0.16, 0.05, -0.2);
	blocks[4]["point"] = (0.02, 0.18, -0.4);
	blocks[4]["angles"] = (0, 0, -45);
	blocks[5]["point"] = (-0.45, 0, -0.12);
	blocks[6]["point"] = (-0.75, -0.02, -0.1);
	blocks[6]["angles"] = (65, 0, 0);

	blocksBothSides = blocks;
	foreach (block in blocks)
	{
		point = block["point"];
		angles = block["angles"];

		if (point[1] <= 0) continue;

		mirroredBlock = [];
		mirroredBlock["point"] = (point[0], point[1] * -1, point[2]);
		mirroredBlock["angles"] = angles;

		blocksBothSides[blocksBothSides.size] = mirroredBlock;
	}

	foreach (block in blocksBothSides)
	{
		point = block["point"];
		angles = block["angles"];

		block = spawn("script_model", self getPointInBounds(point[0], point[1], point[2]));
		block setModel("com_plasticcase_friendly");
		if (!isDefined(angles)) block.angles = self.angles;
		else block.angles = combineAngles(self.angles, angles);
		block cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
		block linkTo(self);

		self.playerCollisionBlocks[self.playerCollisionBlocks.size] = block;
	}
}

DEBUG()
{
	game["ttt_debug_vertices"] = [];

	game["ttt_debug_vertices"][0] = (0.305, 0, -0.4);
	game["ttt_debug_vertices"][1] = (0.32, 0, -0.3);
	game["ttt_debug_vertices"][2] = (0.32, 0, -0.2);
	game["ttt_debug_vertices"][3] = (0.29, 0, -0.15);
	game["ttt_debug_vertices"][4] = (0.21, 0, -0.1);
	game["ttt_debug_vertices"][5] = (0.25, 0, -0.34);
	game["ttt_debug_vertices"][6] = (0.25, 0.1, -0.3);
	game["ttt_debug_vertices"][7] = (0.25, 0.11, -0.2);
	game["ttt_debug_vertices"][8] = (0.22, 0.1, -0.15);
	game["ttt_debug_vertices"][9] = (0.16, 0.08, -0.1);
	game["ttt_debug_vertices"][10] = (0.145, 0.13, -0.3);
	game["ttt_debug_vertices"][11] = (0.095, 0.135, -0.225);
	game["ttt_debug_vertices"][12] = (0.065, 0.12, -0.16);
	game["ttt_debug_vertices"][13] = (0.05, 0.085, -0.105);
	game["ttt_debug_vertices"][14] = (0.155, 0, -0.36);
	game["ttt_debug_vertices"][15] = (0, 0, -0.37);
	game["ttt_debug_vertices"][16] = (0, 0.12, -0.265);
	game["ttt_debug_vertices"][17] = (0, 0.11, -0.2);
	game["ttt_debug_vertices"][18] = (-0.015, 0.09, -0.12);
	game["ttt_debug_vertices"][19] = (0.025, 0.11, -0.32);
	game["ttt_debug_vertices"][20] = (0, 0, -0.04);
	game["ttt_debug_vertices"][21] = (-0.115, 0, -0.365);
	game["ttt_debug_vertices"][22] = (-0.115, 0.085, -0.34);
	game["ttt_debug_vertices"][23] = (-0.11, 0.115, -0.27);
	game["ttt_debug_vertices"][24] = (-0.115, 0.105, -0.2);
	game["ttt_debug_vertices"][25] = (-0.12, 0.065, -0.14);
	game["ttt_debug_vertices"][26] = (-0.13, 0, -0.05);
	game["ttt_debug_vertices"][27] = (-0.2, 0, -0.345);
	game["ttt_debug_vertices"][28] = (-0.21, 0.08, -0.27);
	game["ttt_debug_vertices"][29] = (-0.21, 0.06, -0.2);
	game["ttt_debug_vertices"][30] = (-0.23, 0, -0.06);
	game["ttt_debug_vertices"][31] = (-0.22, 0.035, -0.125);
	game["ttt_debug_vertices"][32] = (-0.3, 0, -0.29);
	game["ttt_debug_vertices"][33] = (-0.32, 0, -0.21);
	game["ttt_debug_vertices"][34] = (-0.34, 0.03, -0.135);
	game["ttt_debug_vertices"][35] = (-0.455, 0, -0.15);
	game["ttt_debug_vertices"][36] = (-0.56, 0, -0.155);
	game["ttt_debug_vertices"][37] = (-0.665, 0, -0.16);
	game["ttt_debug_vertices"][38] = (-0.765, 0, -0.165);
	game["ttt_debug_vertices"][39] = (0.275, 0.205, -0.45);
	game["ttt_debug_vertices"][40] = (-0.085, 0.205, -0.45);

	self thread DEBUG_UPDATE(game["ttt_debug_vertices"]);

	for (;;)
	{
		level waittill("say", text, player);

		args = strTok(text, " ");
		if (args.size == 0) return;

		cmd = args[0];

		if (cmd == "add")
		{
			if (!isDefined(args[1])) args[1] = "0";
			if (!isDefined(args[2])) args[2] = "0";
			if (!isDefined(args[3])) args[3] = "0";
			point = (toFloat(args[1]), toFloat(args[2]), toFloat(args[3]));
			index = game["ttt_debug_vertices"].size;
			game["ttt_debug_vertices"][index] = point;
			self thread DEBUG_UPDATE(game["ttt_debug_vertices"]);
		}
		else if (cmd == "place")
		{
			if (!isDefined(args[1])) args[1] = game["ttt_debug_vertices"].size;
			player thread DEBUG_PLACE(args[1], self);
		}
		else if (cmd == "mov")
		{
			index = int(args[1]);
			point = (toFloat(args[2]), toFloat(args[3]), toFloat(args[4]));
			game["ttt_debug_vertices"][index] = point;
			self thread DEBUG_UPDATE(game["ttt_debug_vertices"]);
		}
		else if (cmd == "del")
		{
			index = int(args[1]);
			game["ttt_debug_vertices"] = array_remove(game["ttt_debug_vertices"], game["ttt_debug_vertices"][index]);
			self thread DEBUG_UPDATE(game["ttt_debug_vertices"]);
		}
		else if (cmd == "log")
		{
			foreach (i, vertex in game["ttt_debug_vertices"])
			{
				logPrint("[" + i + "] = " + vertex + ";\n");
			}
		}
	}
}

DEBUG_PLACE(index, heli)
{
	self endon("death");
	self endon("disconnect");

	self notifyOnPlayerCommand("ttt_debug_freeze", "+smoke");

	point = (0, 0, -0.2);

	self thread DEBUG_TOGGLE_FREEZE();

	for (;;)
	{
		if (self.ttt.freezeCount > 0)
		{
			movement = self getNormalizedMovement();
			point = (point[0], point[1], point[2] + movement[0] * 0.005);
			heliAngle = heli.angles[1] - 180;
			selfAngle = self.angles[1] - 180;
			angle = heliAngle - selfAngle;
			if (angle > 180) angle -= 360;
			if (angle < -180) angle += 360;
			iPrintLn(angle);

			if (angle > 135 || angle < -135)
				point = (point[0], point[1] + movement[1] * 0.005, point[2]);
			else if (angle < -45)
				point = (point[0] + movement[1] * 0.005, point[1], point[2]);
			else if (angle < 45)
				point = (point[0], point[1] + movement[1] * -0.005, point[2]);
			else
				point = (point[0] + movement[1] * -0.005, point[1], point[2]);
		}

		pos = heli getPointInBounds(point[0], point[1], point[2]);
		thread drawDebugPoint(pos, (1, 1, 0), 1);

		if (self attackButtonPressed())
			return;
		if (self adsButtonPressed())
			break;

		wait(0.05);
	}

	self notify("ttt_debug_place");
	game["ttt_debug_vertices"][index] = point;
	heli thread DEBUG_UPDATE(game["ttt_debug_vertices"]);
	wait(0.1);
	self notify("ttt_debug_stop_freeze");
}

DEBUG_TOGGLE_FREEZE()
{
	self endon("ttt_debug_stop_freeze");

	for (;;)
	{
		val = self waittill_any_return("ttt_debug_freeze", "ttt_debug_place");
		if (val == "ttt_debug_place") return;
		self freezePlayer();
		self waittill_any("ttt_debug_freeze", "ttt_debug_place");
		self unfreezePlayer();
	}
}

DEBUG_UPDATE(vertices)
{
	self notify("debug_vertices_update");
	self endon("debug_vertices_update");

	for (;;)
	{
		foreach (i, vertex in vertices)
		{
			pos = self getPointInBounds(vertex[0], vertex[1], vertex[2]);

			thread drawDebugPoint(pos, (0, 1, 0.3), 1);
			thread drawDebugText(pos, i, (1.0, 0.8, 0.5), 0.7, 0.25, 1);
		}
		wait(0.05);
	}
}

DEBUG_LINE(point, dir, ticks)
{
	for (i = 0; i < ticks; i++)
	{
		pos = self getPointInBounds(point[0], point[1], point[2]);

		targetPos = pos + anglesToNormal(self.angles, dir);
		tracedPos = playerPhysicsTrace(pos, targetPos);

		thread drawDebugLine(pos, targetPos, (0, 1, 0.3), 1);
		wait(0.05);
	}
}

toFloat(val)
{
	setDvar("sometempdebugdvar", val);
	return getDvarFloat("sometempdebugdvar");
}

setupCollision()
{
	points = [];
	points[0] = (0.305, 0, -0.4);
	points[1] = (0.32, 0, -0.3);
	points[2] = (0.32, 0, -0.2);
	points[3] = (0.29, 0, -0.15);
	points[4] = (0.21, 0, -0.1);
	points[5] = (0.25, 0, -0.34);
	points[6] = (0.25, 0.1, -0.3);
	points[7] = (0.25, 0.11, -0.2);
	points[8] = (0.22, 0.1, -0.15);
	points[9] = (0.16, 0.08, -0.1);
	points[10] = (0.145, 0.13, -0.3);
	points[11] = (0.095, 0.135, -0.225);
	points[12] = (0.065, 0.12, -0.16);
	points[13] = (0.05, 0.085, -0.105);
	points[14] = (0.155, 0, -0.36);
	points[15] = (0, 0, -0.37);
	points[16] = (0, 0.12, -0.265);
	points[17] = (0, 0.11, -0.2);
	points[18] = (-0.015, 0.09, -0.12);
	points[19] = (0.025, 0.11, -0.32);
	points[20] = (0, 0, -0.04);
	points[21] = (-0.115, 0, -0.365);
	points[22] = (-0.115, 0.085, -0.34);
	points[23] = (-0.11, 0.115, -0.27);
	points[24] = (-0.115, 0.105, -0.2);
	points[25] = (-0.12, 0.065, -0.14);
	points[26] = (-0.13, 0, -0.05);
	points[27] = (-0.2, 0, -0.345);
	points[28] = (-0.21, 0.08, -0.27);
	points[29] = (-0.21, 0.06, -0.2);
	points[30] = (-0.23, 0, -0.06);
	points[31] = (-0.22, 0.035, -0.125);
	points[32] = (-0.3, 0, -0.29);
	points[33] = (-0.32, 0, -0.21);
	points[34] = (-0.34, 0.03, -0.135);
	points[35] = (-0.455, 0, -0.15);
	points[36] = (-0.56, 0, -0.155);
	points[37] = (-0.665, 0, -0.16);
	points[38] = (-0.765, 0, -0.165);
	points[39] = (0.275, 0.205, -0.45);
	points[40] = (-0.085, 0.205, -0.45);

	foreach (point in points)
	{
		self setupCollisionVertex(point);

		if (point[1] > 0)
			self setupCollisionVertex((point[0], point[1] * -1, point[2]));
	}

	self thread collisionThink();
}

setupCollisionVertex(point)
{
	vertex = spawnStruct();
	vertex.point = point;
	vertex.pos = undefined;
	vertex.lastPos = undefined;

	self.collisionVertices[self.collisionVertices.size] = vertex;
}

collisionThink()
{
	for (;;)
	{
		// move the player collision blocks out of the way for the traces
		foreach (block in self.playerCollisionBlocks)
			block.origin -= 16384;

		foreach (i, vertex in self.collisionVertices)
		{
			vertex.pos = self getPointInBounds(vertex.point[0], vertex.point[1], vertex.point[2]);

			if (isDefined(vertex.lastPos) && !self.colliding)
			{
				trace = bulletTrace(vertex.lastPos, vertex.pos, false, self);
				if (trace["fraction"] < 1.0 && trace["surfacetype"] != "default")
					self thread collide(vertex, trace);
			}

			vertex.lastPos = vertex.pos;
		}

		// move player collision blocks back
		foreach (block in self.playerCollisionBlocks)
			block.origin += 16384;

		wait(0.05);
	}
}

collide(vertex, trace)
{
	iPrintLn("^5COLLISION START");

	iPrintLn(trace["surfacetype"]);

	vehicleVelocity = self vehicle_getVelocity();
	vehicleCenterPos = self getPointInBounds(0, 0, -0.2);

	lastTickDiff = vertex.pos - vertex.lastPos;
	vertexSpeed = length(lastTickDiff);
	bounceSpeed = max(1, vertexSpeed * 3);

	self.colliding = true;

	// simulate hitting a surface
	self vehicle_setSpeed(bounceSpeed * 10, bounceSpeed * 10, bounceSpeed * 10);
	self setVehGoalPos(self.origin + trace["normal"], true);

	self waittill_any("near_goal", "goal");

	// simulate bouncing off the surface
	self vehicle_setSpeed(bounceSpeed, bounceSpeed, bounceSpeed);
	bounceOffset = trace["normal"] * vertexSpeed * 3;
	self setVehGoalPos(self.origin + bounceOffset, true);
	thread drawDebugLine(self.origin, self.origin + bounceOffset, (1, 0, 1));
	self setNearGoalNotifyDist(length(bounceOffset) / 2);

	self waittill_any("near_goal", "goal");

	// self joltBody((self.origin + (0, 0, 64)), 1);

	self vehicle_setSpeed(self.speed, self.accel, self.decel);
	self.colliding = false;
	iPrintLn("^1COLLISION END");
}

OnHeliAvailable(heli)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(&"[ ^3[{+activate}] ^7] to enter/exit ^3helicopter");
}
OnHeliAvailableEnd()
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

OnHeliTrigger(heli)
{
	if (!isDefined(heli.pilot))
	{
		heli.pilot = self;
		self PlayerLinkToBlend(heli.anchor["pilot"], "", 1.0, 0.25, 0.25);
		wait(1.0);
		self PlayerLinkToDelta(heli.anchor["pilot"], "", 0.85, 90, 90, 45, 45, true);
		self setClientDvar("cg_thirdPerson", true);
		self setClientDvar("cg_thirdPersonMode", 1);
		self setClientDvar("cg_thirdPersonRange", 320);

		self thread heliControlThink(heli);
	}
	else
	{
		heli.pilot unlink();
		heli.pilot setClientDvar("cg_thirdPerson", false);
		heli.pilot setClientDvar("cg_thirdPersonMode", 1);
		heli.pilot setClientDvar("cg_thirdPersonRange", 120);

		heli notify("pilot_exited", heli.pilot);
		heli.pilot = undefined;
	}
}

heliControlThink(heli)
{
	heli endon("death");
	heli endon("pilot_exited");

	for (;;)
	{
		heli handleForward(self);
		heli handleUp(self);
		heli handleTurn(self);

		if (!heli.colliding)
		{
			nextGoalPos = (0, 0, 0);
			if (isDefined(heli.nextXY)) nextGoalPos += heli.nextXY;
			if (isDefined(heli.nextZ)) nextGoalPos += heli.nextZ;
			if (nextGoalPos != (0, 0, 0))
			{
				iPrintLn(nextGoalPos);
				heli setVehGoalPos(nextGoalPos, true);
				thread drawDebugLine(heli.origin, nextGoalPos, (1, 0.5, 0.2), 20);
				if (distanceSquared((heli.origin[0], heli.origin[1], 0), heli.nextXY) < 16)
					heli.nextXY = undefined;
				if (distanceSquared((0, 0, heli.origin[2]), heli.nextZ) < 16)
					heli.nextZ = undefined;
			}
		}

		wait(0.05);
	}
}

handleForward(pilot)
{
	inputForward = pilot getNormalizedMovement()[0];

	if (inputForward == 0 && self.prevPilotInput["forward"] == 0) return;

	A_LOT = 1024 * 32;
	horizPos = self.origin * (1, 1, 0);
	horizVelocity = self vehicle_getVelocity() * (1, 1, 0);
	forward = anglesToForward(self.angles) * (1, 1, 0);

	if (inputForward != 0)
		self.nextXY = horizPos + forward * inputForward * A_LOT;
	else if (self.prevPilotInput["forward"] != 0)
		self.nextXY = horizPos + horizVelocity * (length(horizVelocity) * self.decel / self.speed * 0.03); // not sure if this works well with any speed / decel values

	thread drawDebugLine(self.origin, (self.nextXY[0], self.nextXY[1], self.origin[2]), (0, 1, 1), 20);

	self.prevPilotInput["forward"] = inputForward;
}
handleUp(pilot)
{
	inputUp = 0;
	if (pilot.ttt.vehicles.controls["jump"]) inputUp++;
	if (pilot.ttt.vehicles.controls["sprint"]) inputUp--;

	if (inputUp == 0 && self.prevPilotInput["up"] == 0) return;

	vertPos = self.origin * (0, 0, 1);
	vertVelocity = self vehicle_getVelocity() * (0, 0, 1);

	if (inputUp != 0)
		self.nextZ = vertPos + (0, 0, 1) * inputUp * (self.speed / 3) * max(1, distance2D(self.origin, self.nextXY) / 3);
	else if (self.prevPilotInput["up"] != 0)
		self.nextZ = vertPos + vertVelocity / 3;

	thread drawDebugLine(self.origin, (self.origin[0], self.origin[1], self.nextZ[2]), (1, 0, 1), 20);

	self.prevPilotInput["up"] = inputUp;
}
handleTurn(pilot)
{
	inputYaw = 0;
	inputYaw = pilot getNormalizedMovement()[1];

	if (inputYaw == 0) return;

	self.lookAtEnt.origin = self.origin;
	self.lookAtEnt.origin += anglesToForward(self.angles) * 512;
	self.lookAtEnt.origin += anglesToRight(self.angles) * 512 * inputYaw;
	self.prevPilotInput["yaw"] = inputYaw;
}
