local Knit = require(game:GetService("ReplicatedStorage").Knit)

Knit.AddControllers(script.Parent.Controllers)

Knit.Start:Catch(warn)