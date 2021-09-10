local function copy(value)
	if type(value) == "table" then
		local new = {}
		for i, v in pairs(value) do
			new[i] = copy(v)
		end
		return new
	end
	return value
end

local function merge(base, ...)
	local new = {}
	for i, v in pairs(base) do
		new[i] = v
	end
	for i = 1, select("#", ...) do
		for i, v in pairs(select(i, ...)) do
			new[i] = v
		end
	end
	return new
end

local Scope = {}
Scope.__index = Scope

function Scope.new()
	local self = {}
	setmetatable(self, Scope)
	return self
end

function Scope:clone()
	local new = Scope.new()
	new:setUser(self.user)
	new:setExtras(self.extras)
	new:setTags(self.tags)
	new.context = copy(self.context)
	new:setLevel(self.level)
	new:setTransaction(self.transaction)
	new:setFingerprint(self.fingerprint)
	new.eventProcessors = copy(self.eventProcessors)
	new.breadcrumbs = copy(self.breadcrumbs)
	return new
end

function Scope:setUser(user)
	self.user = copy(user)
end

function Scope:setExtra(key, value)
	if not self.extras then
		self.extras = {}
	end
	self.extras[key] = copy(value)
end

function Scope:setExtras(extras)
	self.extras = copy(extras)
end

function Scope:setTag(key, value)
	if not self.tags then
		self.tags = {}
	end
	self.tags[key] = copy(value)
end

function Scope:setTags(tags)
	self.tags = copy(tags)
end

function Scope:setContext(key, value)
	if not self.context then
		self.context = {}
	end
	self.context[key] = copy(value)
end

function Scope:setLevel(level)
	self.level = level
end

function Scope:setTransaction(transaction)
	self.transaction = copy(transaction)
end

function Scope:setFingerprint(fingerprint)
	self.fingerprint = copy(fingerprint)
end

function Scope:addEventProcessor(processor)
	if not self.eventProcessors then
		self.eventProcessors = {}
	end
	self.eventProcessors[#self.eventProcessors + 1] = processor
end

function Scope:clear()
	self.user = nil
	self.extras = nil
	self.tags = nil
	self.context = nil
	self.level = nil
	self.transaction = nil
	self.fingerprint = nil
	self.breadcrumbs = nil
end

function Scope:addBreadcrumb(crumb, maxBreadcrumbs)
	if not self.breadcrumbs then
		self.breadcrumbs = {}
	end
	crumb = copy(crumb)
	crumb.timestamp = os.time()
	if #self.breadcrumbs > maxBreadcrumbs then
		table.remove(self.breadcrumbs, 1)
	end
	self.breadcrumbs[#self.breadcrumbs + 1] = crumb
end

function Scope:clearBreadcrumbs()
	self.breadcrumbs = nil
end

function Scope:applyToEvent(event)
	if self.user then
		event.user = merge(event.user, self.user)
	end
	if self.extra then
		event.extra = merge(event.extra, self.extra)
	end
	if self.tags then
		event.tags = merge(event.tags, self.tags)
	end
	if self.context then
		event.context = merge(event.context, self.context)
	end
	if not event.level then
		event.level = self.level
	end
	if not event.transaction then
		event.transaction = self.transaction
	end
	-- if not event.fingerprint then
	-- 	event.fingerprint = self.fingerprint
	-- end
	if not event.breadcrumbs then
		event.breadcrumbs = self.breadcrumbs
	end
	if event.breadcrumbs then
		if #event.breadcrumbs == 0 then
			event.breadcrumbs = nil
		else
			local crumbs = event.breadcrumbs
			event.breadcrumbs = {values = crumbs}
		end
	end
	return self:_processEvent(event)
end

function Scope:_processEvent(event)
	if self.eventProcessors then
		local current = event
		for _, processor in ipairs(self.eventProcessors) do
			local new = processor(current)
			if new then
				current = new
			else
				return nil
			end
		end
		return current
	end
	return event
end

return Scope
