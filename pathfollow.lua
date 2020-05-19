game.Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(char)
		
		wait(2)
		local PathfindingService = game:GetService("PathfindingService")
	 
		-- Variables for the zombie, its humanoid, and destination
		local zombie = game.Workspace.Zombie
		local humanoid = zombie.Humanoid
		--print(humanoid)
		local destination = char -- char:FindFirstChild("Head") --game.Workspace.Cupcake1
		--print(destination)
		-- Create the path object
		local path = PathfindingService:CreatePath()
		 
		-- Variables to store waypoints table and zombie's current waypoint
		local waypoints
		local currentWaypointIndex
		
		local function followPath(destinationObject)
			-- Compute and check the path
			path:ComputeAsync(zombie.HumanoidRootPart.Position, destinationObject.HumanoidRootPart.Position)
			print("start")
			print(zombie.HumanoidRootPart.Position)
			print("target")
			print(destinationObject.HumanoidRootPart.Position)
			
			-- Empty waypoints table after each new path computation
			waypoints = {}
		 	print(path.Status)
			if path.Status == Enum.PathStatus.Success then
				-- Get the path waypoints and start zombie walking
				waypoints = path:GetWaypoints()
				for _, waypoint in pairs(waypoints) do
					local part = Instance.new("Part")
					part.Shape = "Ball"
					part.Material = "Neon"
					part.Size = Vector3.new(0.6, 0.6, 0.6)
					part.Position = waypoint.Position
					part.Anchored = true
					part.CanCollide = false
					part.Parent = game.Workspace
				end
				print(#waypoints)
				-- Move to first waypoint
				currentWaypointIndex = 1
				humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
			else
				-- Error (path not found); stop humanoid
				humanoid:MoveTo(zombie.HumanoidRootPart.Position)
				print("err")
			end
		end
		 
		local function onWaypointReached(reached)
			
			if reached and currentWaypointIndex < #waypoints then
				currentWaypointIndex = currentWaypointIndex + 1
				humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
				--print(waypoints[currentWaypointIndex].Position)
			else
				followPath(destination)
			end
			print(currentWaypointIndex)
		end
		 
		local function onPathBlocked(blockedWaypointIndex)
			print("recompute")
			-- Check if the obstacle is further down the path
			if blockedWaypointIndex > currentWaypointIndex then
				-- Call function to re-compute the path
				
				followPath(destination)
			end
		end
		 
		-- Connect 'Blocked' event to the 'onPathBlocked' function
		path.Blocked:Connect(onPathBlocked)
		 
		-- Connect 'MoveToFinished' event to the 'onWaypointReached' function
		humanoid.MoveToFinished:Connect(onWaypointReached)
		 
		followPath(destination)
		
	end)
end)


