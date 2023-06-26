addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource()),
	function()
local desusound =playSound3D("music.mp3",1453.3000488281, -4667.3999023438, 28.700000762939, true)
setSoundVolume(desusound,1.3)
setSoundMaxDistance(desusound, 250)
    end
	           )
