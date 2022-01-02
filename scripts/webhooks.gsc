/**
 * NOTE: This script requires a proxy server to transform IW4X's httpGet request into POST
 * HTTP requests, that the Discord API expects. Currently IW4X cannot send POST http requests.
 */

init()
{
	level thread OnPlayerConnect();
}

OnPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerDisconnect(player);

		if (storageHas("webhooks_connected_players:" + player.guid)) continue;

		storageSet("webhooks_connected_players:" + player.guid, "");
		sendWebhookPlayerConnect(player);
	}
}

OnPlayerDisconnect()
{
	self waittill("disconnect");

	storageRemove("webhooks_connected_players:" + self.guid);

	if (level.players.size == 0)
		sendWebhookServerEmpty();
}

sendWebhookPlayerConnect(newPlayer)
{
	waittillframeend;

	json = escapeURIString(
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Player joined\"," +
			"\"color\": 11313056," +
			"\"fields\": [" +
				"{" +
					"\"name\": \"Players\"," +
					"\"value\": \"" + buildPlayerList(newPlayer) + "\"," +
					"\"inline\": true" +
				"}," +
				"{" +
					"\"name\": \"Map\"," +
					"\"value\": \"" + getDvar("mapname") + "\"," +
					"\"inline\": true" +
				"}" +
			"]," +
			"\"footer\": {" +
				"\"text\": \"" + removeColorsFromString(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%CURRENTTIME%\"" + // currently timestamp is put in via proxy server
			// "\"thumbnail\": {" +
			// 	"\"url\": \"https://gib.murl.is/static/embed.png\"" +
			// "}" +
		"}" +
	"]" +
"}");

	executeWebhook(json);
}

sendWebhookServerEmpty()
{
		json = escapeURIString(
"{" +
	"\"embeds\": [" +
		"{" +
			"\"title\": \"Server empty\"," +
			"\"description\": \"Party's over! %F0%9F%8C%9A\"," +
			"\"color\": 11313056," +
			"\"footer\": {" +
				"\"text\": \"" + removeColorsFromString(getDvar("sv_hostname")) + "\"" +
			"}," +
			"\"timestamp\": \"%CURRENTTIME%\"" + // currently timestamp is put in via proxy server
		"}" +
	"]" +
"}");

	executeWebhook(json);
}

executeWebhook(json)
{
	proxyURL = getDvar("sv_webhook_proxy_url");
	webhookURL = getDvar("sv_webhook_url");
	if (proxyURL == "" || webhookURL == "") return;

	request = httpGet(proxyURL + "?url=" + webhookURL + "&body=" + json);
}

escapeURIString(str)
{
	map = [];
	map["!"] = "%21";
	map["#"] = "%23";
	map["$"] = "%24";
	// map["%"] = "%25"; // probably not necessary due to % being unavailable in the client anyway... allows for URL encoded emoji
	map["&"] = "%26";
	map["'"] = "%27";
	map["("] = "%28";
	map[")"] = "%29";
	map["*"] = "%2A";
	map["+"] = "%2B";
	map[","] = "%2C";
	map["/"] = "%2F";
	map[":"] = "%3A";
	map[";"] = "%3B";
	map["="] = "%3D";
	map["?"] = "%3F";
	map["@"] = "%40";
	map["["] = "%5B";
	map["\\"] = "%5C";
	map["]"] = "%5D";

	result = "";

	for (i = 0; i < str.size; i++)
	{
		letter = str[i];

		if (isDefined(map[letter]))
			result += map[letter];
		else
			result += letter;
	}

	return result;
}

removeColorsFromString(str)
{
	parts = strTok(str, "^");
	foreach (i, part in parts)
	{
		if (i == 0 && str[0] != "^") continue;

		switch (part[0])
		{
			case "0":
			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case ":":
			case ";":
				parts[i] = getSubStr(part, 1);
		}
	}
	result = "";
	foreach (part in parts) result += part;
	return result;
}

buildPlayerList(newPlayer)
{
	str = "";
	foreach (player in level.players)
	{
		newPrefix = "";
		if (isDefined(newPlayer) && player == newPlayer)
			newPrefix = "%F0%9F%86%95 ";
		str += newPrefix + player.name + "\\n";
	}
	return removeColorsFromString(str);
}
