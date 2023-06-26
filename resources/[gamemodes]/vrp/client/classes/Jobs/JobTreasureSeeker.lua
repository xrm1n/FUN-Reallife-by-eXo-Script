-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobTreasureSeeker.lua
-- *  PURPOSE:     JobTreasureSeeker job
-- *
-- ****************************************************************************
JobTreasureSeeker = inherit(Job)
JobTreasureSeeker.Rope = {}

function JobTreasureSeeker:constructor()
	Job.constructor(self, 1, 714.30, -1703.26, 2.43, 270, "TreasureSeeker.png", {150, 110, 50}, "files/images/Jobs/HeaderFarmer.png", _(HelpTextTitles.Jobs.TreasureSeeker):gsub("Job: ", ""), _(HelpTexts.Jobs.TreasureSeeker), LexiconPages.JobTreasureSeeker, self.onInfo)
	self:setJobLevel(JOB_LEVEL_TREASURESEEKER)
	NonCollisionArea:new("Cuboid", {Vector3(717, -1707, -1), 8, 17, 6})
end

function JobTreasureSeeker:start()
	TreasureRadar:new()
	HelpBar:getSingleton():setLexiconPage(LexiconPages.JobTreasureSeeker)
end

function JobTreasureSeeker:stop()
	delete(TreasureRadar:getSingleton())
	HelpBar:getSingleton():setLexiconPage(nil)
end

addRemoteEvents{"jobTreasureDrawRope"}
addEventHandler("jobTreasureDrawRope", root,function(engine, magnet)
	JobTreasureSeeker.Rope[engine] = magnet --gets drawn in client/classes/Vehicle.lua
end)
