--===================================================================
-- Class: oauth2
--===================================================================
local url = require('socket.url')
local storyboard = require('storyboard')
local json = require("json")

local Meetup = {}
local Meetup_mt = {__index = Meetup}

---------------------------------------------------------------------
-- Private Functions
---------------------------------------------------------------------

-- String utility. Split string to table
function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

-- Create url query string from table
local function to_url_query(t, escape)
	local escape = escape or nil
	local result = ""
	local pair
	for k in pairs(t) do
		if escape then
			pair = k .. "=" .. url.escape(t[k])
		else
			pair = k .. "=" .. t[k]
		end
		if result == "" then
			result = pair
		else
			result = result .. "&" .. pair
		end
	end
	return result
end

-- URL query string to table
local function parse_url_query(s)
	local result = {}
	local pair
	for i,v in ipairs(split(s, '&')) do
		pair = split(v, '=')
		result[pair[1]] = pair[2]
	end
	return result
end

---------------------------------------------------------------------
-- Public Functions
---------------------------------------------------------------------

-- Create new instance
function Meetup.new(obj)
	local obj = obj or {}
		-- apiKey, consumerKey and consumerSecret are required
		obj.authorizationURI = 'https://secure.meetup.com/oauth2/authorize'
		obj.accessURI = 'https://secure.meetup.com/oauth2/access'
		obj.gotoScene = "members"
		obj.groupURLName = 'Corona-SDK-Honolulu-Meetup'
		obj.dataDownloaded = false
		obj.isAuthorized = 0

	return setmetatable(obj, Meetup_mt)
end

function Meetup:setAuthorizationEvent(target)
	self.authorizationEvent = {name = 'isAuthorized', target = target}
end

-- Login network request listener
function Meetup:onAuthorize(e)
	local msg
	local result = true
	if e.errorCode then
		msg = "Error: " .. e.errorMessage
		print(msg)
		result = false
	end
	if string.find(e.url, 'http://127.0.0.1') == 1 then
		local parsed_url = url.parse(e.url)
		local query = parse_url_query(parsed_url.query)
		if e.state then
			print("onAuthorize state", e.state)
		else
			print("onAuthorize query", parsed_url.query)
			self.consumerCode = query.code
			self.isAuthorized = 1
		end
		result = false
	end
	return result
end

-- Popup Meetup login
function Meetup:authorize()
	local query_string = {
		client_id=self.consumerKey,
		response_type='code',
		set_mobile='on',
		redirect_uri='http://127.0.0.1'
	}
	local uri = self.authorizationURI .. "?" .. to_url_query(query_string)
	print("Meetup:authorize", uri)
	native.showWebPopup(uri, {urlRequest=function(e) return self:onAuthorize(e) end})
end

-- Access network request listener
function Meetup:onAccess(e)
	local msg
	local result = true
	local data = {}
	if e.isError then
		msg = "Error: " .. e.response
		print(msg)
		result = false
	else
		msg = "Response: " .. e.response
		print(msg)
		data = json.decode(e.response)
		self.accessToken = data.access_token
		self.refreshToken = data.refresh_token
		result = false
	end
	native.setActivityIndicator(result)
	return result
end

-- Get access token
function Meetup:access()
	local query_string = {
		client_id=self.consumerKey,
		client_secret=self.consumerSecret,
		grant_type='authorization_code',
		redirect_uri='http://127.0.0.1',
		code=self.consumerCode
	}
	local uri = self.accessURI .. "?" .. to_url_query(query_string)
	local params = {}
	params.headers = {}
	params.headers["Content-Type"] = 'application/x-www-form-urlencoded'
	params.body = to_url_query(query_string)
	print("Meetup:access", uri)
	network.request(uri, 'POST', function(e) self:onAccess(e) end, params)
	native.setActivityIndicator(true)
end

-- Get data listener
function Meetup:onGetData(e)
	local msg
	if e.isError then
		msg = "Error: " .. e.response
		print("onGetData", msg)
	else
		msg = "Response: " .. e.response
		print("onGetData", msg)
		self.data = json.decode(e.response)
		self.dataDownloaded = true
	end
	native.setActivityIndicator(false)
end

-- Get data
function Meetup:getData(s, id)
	s = s or nil
	id = id or 0
	print("getData", s, id)
	local query_string = {
		key = self.apiKey,
		access_token = self.accessToken,
		group_urlname = 'Corona-SDK-Honolulu-Meetup'
	}
	local url = ""
	if s == 'members' then
		query_string.order = 'name'
		url = "https://api.meetup.com/2/members" .. "?" .. to_url_query(query_string)
	elseif s == 'events' then
		query_string.group_urlname = self.groupURLName
		query_string.status = 'past,upcoming'
		url = "https://api.meetup.com/2/events" .. "?" .. to_url_query(query_string)
	elseif s == 'comments' then
		query_string.event_id = self.eventID
		query_string.order = 'time'
		url = "https://api.meetup.com/2/event_comments" .. "?" .. to_url_query(query_string)
	elseif s == 'ratings' then
		query_string.event_id = self.eventID
		query_string.order = 'rating'
		url = "https://api.meetup.com/2/event_ratings" .. "?" .. to_url_query(query_string)
	else
		url = "https://api.meetup.com/2/event/" .. id
	end
	print("getData", url)
	network.request(url, 'GET', function(e) self:onGetData(e) end)
	native.setActivityIndicator(true)
end

-- Send data listener
function Meetup:onSendData(e)
	local msg
	print("onSendData", e.response)
	if e.isError then
		msg = "Error: " .. e.response
		print("onSendData", msg)
	else
		msg = "Response: " .. e.response
		print("onSendData", msg)
		self.dataSent = true
	end
	native.setActivityIndicator(false)
end

-- Send data
function Meetup:sendData(s, d)
	s = s or nil
	d = d or {}
		
	d.key = self.apiKey
	d.access_token = self.accessToken
	d.comment = url.escape(d.comment)
	print("sendData", s)
	print("sendData", d.comment)
	
	local headers = {}
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	
	local body = to_url_query(d)
	print("sendData", body)
	local params = {headers = headers, body = body}
	local url = ""
	
	if s == 'event_comment' then
		url = "https://api.meetup.com/2/event_comment"
	end
	
	network.request(url, "POST", function(e) self:onSendData(e) end, params)
	native.setActivityIndicator(true)
end

---------------------------------------------------------------------
-- Return class
---------------------------------------------------------------------
return Meetup