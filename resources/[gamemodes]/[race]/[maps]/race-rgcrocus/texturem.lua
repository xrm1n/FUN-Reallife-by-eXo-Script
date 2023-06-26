function SignboardClient ()
txd = engineLoadTXD("metalbarrier.txd") 
engineImportTXD(txd, 978 )
engineImportTXD(txd, 979 )
txd = engineLoadTXD("vgsegarage.txd") 
engineImportTXD(txd, 8957 )
end
addEventHandler( "onClientResourceStart", resourceRoot, SignboardClient )