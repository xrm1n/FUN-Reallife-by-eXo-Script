-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/ItemManager.lua
-- *  PURPOSE:     Item manager class
-- *
-- ****************************************************************************
ItemManager = inherit(Singleton)
ItemManager.Map = {}

function ItemManager:constructor()
	addRemoteEvents{"onClientBreakItem"}
	self.m_ClassItems = {
		["Keypad"] = ItemKeyPad,
		["Tor"] = ItemDoor,
		["Einrichtung"] = ItemFurniture,
		["Eingang"] = ItemEntrance,
		["Transmitter"] = ItemTransmitter,
		["Barrikade"] = ItemBarricade,
		["Warnkegel"] = ItemBarricade,
		["Sky Beam"] = ItemSkyBeam,
		["Blitzer"] = ItemSpeedCam,
		["Nagel-Band"] = ItemNails,
		["Radio"] = ItemRadio,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
		["Burger"] = ItemFood,
		["Lebkuchen"] = ItemFood,
		["Wuerstchen"] = ItemFood,

		["Kuheuter mit Pommes"] = ItemFood,
		["Zombie-Burger"] = ItemFood,
		["Suessigkeiten"] = ItemFood,
		["Zuckerstange"] = ItemFood,
		["Pizza"] = ItemFood,
		["Pilz"] = ItemFood,
		["Zigarette"] = ItemFood,
		["Donut"] = ItemFood,
		["Keks"] = ItemFood,
		["Apfel"] = ItemFood,
		["KöderDummy"] = ItemFood,
		["Donutbox"] = ItemDonutBox,
		["Osterei"] = ItemEasteregg;
		["Kürbis"] = ItemPumpkin;
		["Taser"] = ItemTaser;
		["SLAM"] = ItemSlam;
		["Rauchgranate"] = ItemSmokeGrenade;
		["DefuseKit"] = ItemDefuseKit;
		["Päckchen"] = ItemPresent;

		["Bambusstange"] = ItemFishing,
		["Angelrute"] = ItemFishing,
		["Profi Angelrute"] = ItemFishing,
		["Legendäre Angelrute"] = ItemFishing,
		["Kleine Kühltasche"] = ItemFishing,
		["Kühltasche"] = ItemFishing,
		["Kühlbox"] = ItemFishing,
		["Köder"] = ItemFishing,
		["Leuchtköder"] = ItemFishing,
		["Pilkerköder"] = ItemFishing,
		["Schwimmer"] = ItemFishing,
		["Spinner"] = ItemFishing,
		["Fischlexikon"] = ItemFishing,

		["Wuerfel"] = ItemDice,
		["Weed-Samen"] = Plant,
		["Apfelbaum-Samen"] = Plant,
		["Blumen-Samen"] = Plant,
		["Kanne"] = ItemCan,
		["Handelsvertrag"] = ItemSellContract,
		["Ausweis"] = ItemIDCard,
		["Benzinkanister"] = ItemFuelcan,
		["Reparaturkit"] = ItemRepairKit,
		["Medikit"] = ItemHealpack,
		--Alcohol
		["Bier"] = ItemAlcohol,
		["Whiskey"] = ItemAlcohol,
		["Sex on the Beach"] = ItemAlcohol,
		["Pina Colada"] = ItemAlcohol,
		["Monster"] = ItemAlcohol,
		["Shot"] = ItemAlcohol,
		["Cuba-Libre"] = ItemAlcohol,
		["Gluehwein"] = ItemAlcohol,

		--Firework
		["Rakete"] = ItemFirework,
		["Rohrbombe"] = ItemFirework,
		["Raketen Batterie"] = ItemFirework,
		["Römische Kerze"] = ItemFirework,
		["Römische Kerzen Batterie"] = ItemFirework,
		["Kugelbombe"] = ItemFirework,
		["Böller"] = ItemFirework,

		--//Wearables
		["Helm"] = WearableHelmet,
		["Motorcross-Helm"] = WearableHelmet,
		["Pot-Helm"] = WearableHelmet,
		["Gasmaske"] = WearableHelmet,
		["Stern"] = WearableHelmet,
		["Einsatzhelm"] = WearableHelmet,
		["Hasenohren"] = WearableHelmet,
		["Weihnachtsmütze"] = WearableHelmet,
		["Lebkuchen-Maske"] = WearableHelmet,
		["Kevlar"] = WearableShirt,
		["Tragetasche"] = WearableShirt,
		["Swatschild"] = WearablePortables,
		["Kleidung"] = WearableClothes,

		["Clubkarte"] = ItemPlayHouseCard,

		["Schuh"] = ItemThrowShoe, 
		["Abfall"] = ItemThrowTrash,
		["Flasche"] = ItemThrowBottle,  
	}

	self.m_Properties = {
		["Barrikade"] = {true}, --// breakable,
		["Warnkegel"] = {true}, --// breakable,
	}

	for name, class in pairs(self.m_ClassItems) do
		local breakable = false
		if self.m_Properties[name] then
			breakable = true
		end
		local instance = class:new( )
		instance:setName(name)
		instance:loadItem()
		instance.m_Breakable = breakable
		ItemManager.Map[name] = instance
	end

	addEventHandler("onClientBreakItem",root, bind(self.Event_onItemBreak,self))
end

function ItemManager:updateOnQuit()

end

function ItemManager:Event_onItemBreak()
	if source and isElement(source) then
		if source.m_Super and source.m_Super.m_Breakable then
			delete(source.m_Super)
		end
	end
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getInstance(itemName)
	return ItemManager.Map[itemName]
end
