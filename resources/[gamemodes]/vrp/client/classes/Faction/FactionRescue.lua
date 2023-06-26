
addRemoteEvents{"rescueLadderUpdateCollision", "rescueLadderFixCamera"}

addEventHandler("rescueLadderUpdateCollision", root, function(enable)
	if source:getType() == "vehicle" and source:getModel() == 544 then
		local source = source
		local enable = enable
		local removeCollisions
		removeCollisions = function(ele)
			for i, e in pairs(ele:getAttachedElements()) do
				if e:getType() == "object" then
					setElementCollisionsEnabled(e, enable == nil and false or enable)
					e:setCollidableWith(source, false)
					removeCollisions(e)
				end
			end
		end
		removeCollisions(source)
	end
end)


addEventHandler("rescueLadderFixCamera", root, function(ladder1, ladder3)
	if ladder1 then
		local mult = math.clamp(1, getDistanceBetweenPoints3D(ladder1.matrix.position, ladder3.matrix.position), 30)
		local pos1 = ladder1.matrix.position - ladder1.matrix.right*mult + ladder1.matrix.up*mult
		local pos2 = ladder3.matrix.position - ladder3.matrix.forward*4
		setCameraMatrix(pos1, pos2, 0, 180)
	else
		nextframe(function()
			setCameraTarget(localPlayer)
		end)
	end
end)