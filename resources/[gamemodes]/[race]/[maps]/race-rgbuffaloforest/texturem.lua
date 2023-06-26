function BarrierClient ()
txd = engineLoadTXD("metalbarrier.txd") 
engineImportTXD(txd, 979 )
engineImportTXD(txd, 978 )
end
addEventHandler( "onClientResourceStart", resourceRoot, BarrierClient )