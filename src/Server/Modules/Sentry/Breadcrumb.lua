local Breadcrumb = {}
Breadcrumb.__index = Breadcrumb

function Breadcrumb.new(self)
	self = self or {}
	self.timestamp = self.timestamp or os.time()
	setmetatable(self, Breadcrumb)
	return self
end

return Breadcrumb
