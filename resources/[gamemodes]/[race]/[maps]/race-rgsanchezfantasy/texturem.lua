function GarageClient ()
txd = engineLoadTXD("vgsegarage.txd") 
engineImportTXD(txd, 8957 )
end
addEventHandler( "onClientResourceStart", resourceRoot, GarageClient )