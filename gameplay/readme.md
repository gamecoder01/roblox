# Todo


## 1. Create a genPlatform.lua under Workspace
```Lua
local Workspace = game:GetService("Workspace")

local gridSize = 20
local spacing = 3
local partSize = 2

-- Starting position (centered around origin)
local startX = -(gridSize - 1) * spacing / 2
local startZ = -(gridSize - 1) * spacing / 2
local yPos = -1 -- Height above baseplate

local i = 1
for x = 0, gridSize - 1 do
	for z = 0, gridSize - 1 do
		task.spawn(function()
	        local sphere = Instance.new("Part")
	        sphere.Shape = Enum.PartType.Block
			sphere.Size = Vector3.new(partSize, partSize, partSize)
	        sphere.Anchored = true
	        sphere.Position = Vector3.new(startX + x * spacing, yPos, startZ + z * spacing)
	        sphere.Name = "block" .. i
			sphere.Parent = Workspace
			i = i+1
		end)
	end
end
```
## 2. Create a block part (adjust its position) and insert the code below

```lua
local part = script.Parent

-- Laser settings
local laserColor = Color3.new(1, 0, 0) -- Red
local laserMaterial = Enum.Material.Neon
local laserWidth = 0.5

local minX = -20
local maxX = 20
local minZ = -20
local maxZ = 20

while true do
	-- Wait a random time between 1 and 3 seconds

	-- Generate random direction and distance for X and Z
	local xOffset = math.random(-20, 20)
	local zOffset = math.random(-20, 20)
	local currentCFrame = part:GetPivot()
	local currentPos = currentCFrame.Position

	-- Calculate new position
	local newX = currentPos.X + xOffset
	local newZ = currentPos.Z + zOffset

	-- Clamp new position within boundaries
	if newX < minX then newX = minX end
	if newX > maxX then newX = maxX end
	if newZ < minZ then newZ = minZ end
	if newZ > maxZ then newZ = maxZ end

	local newCFrame = CFrame.new(newX, currentPos.Y, newZ)
	part:PivotTo(newCFrame)

	-- task.wait(math.random(1, 3))

	-- Calculate bottom position of the part
	local partCFrame = part.CFrame
	local partSizeY = part.Size.Y
	local origin = partCFrame.Position - partCFrame.UpVector * (partSizeY / 2)

	-- Fire direction (downward)
	local direction = Vector3.new(0, -500, 0)

	-- Raycast to find where the laser hits
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {part}
	raycastParams.IgnoreWater = true
	--raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, raycastParams)
	local hitPosition = origin + direction

	if result then
		hitPosition = result.Position
		-- Traverse up the ancestry to find a Humanoid
		local instance = result.Instance

		if instance and instance:IsA("Part") then
			-- Optional: Add a delay before destroying
			task.wait(0.5)
			instance:Destroy()
		end

		local humanoid = nil
		while instance and instance ~= workspace do
			humanoid = instance:FindFirstChild("Humanoid")
			if humanoid then
				break
			end
			instance = instance.Parent
		end
		if humanoid then
			print("Laser hit player: " .. humanoid.Parent.Name)
			humanoid.Health = 0
		end
	end

	-- Create laser part
	local laser = Instance.new("Part")
	laser.Anchored = true
	laser.CanCollide = false
	laser.Material = laserMaterial
	laser.Color = laserColor
	laser.Transparency = 0
	laser.Size = Vector3.new(laserWidth, (origin - hitPosition).Magnitude, laserWidth)
	laser.CFrame = CFrame.new((origin + hitPosition) / 2, hitPosition)
	laser.Orientation = Vector3.new(0, 90, 0)
	laser.Parent = workspace

	-- Remove laser after short time
	task.wait(2)
	laser:Destroy()
end


```
