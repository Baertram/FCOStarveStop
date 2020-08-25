if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop
------------------------------------------------------------------------------------------------------------
-- Addon info
------------------------------------------------------------------------------------------------------------
FCOSS.addonVars =  {}
FCOSS.addonVars.addonRealVersion		= 0.91
FCOSS.addonVars.addonSavedVarsVersion	= 0.4
FCOSS.addonVars.addonName				= "FCOStarveStop"
FCOSS.addonVars.addonSavedVars			= "FCOStarveStop_Settings"
FCOSS.addonVars.settingsName   			= "FCO StarveStop"
FCOSS.addonVars.settingsDisplayName   	= "|c00FF00FCO |cFFFF00 StarveStop|r"
FCOSS.addonVars.addonAuthor				= "Baertram"
FCOSS.addonVars.addonWebsite			= "http://www.esoui.com/downloads/info1291-FCOStarveStop.html#info"

------------------------------------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------------------------------------
--libLoadedAddons
local LIBLA = LibLoadedAddons
FCOSS.libLA = LIBLA
--LibFoodDrinkBuff
local libFDB = LIB_FOOD_DRINK_BUFF
FCOSS.libFDB = libFDB
--LibPotionBuff
local libPB = LibPotionBuff
FCOSS.libPB = libPB
--LibAddonMenu-2.0
FCOSS.addonMenu = LibAddonMenu2

local function FCOSS_addonLoaded(evetName, addon)
	if addon ~= FCOSS.addonVars.addonName then return end
	EVENT_MANAGER:UnregisterForEvent(evetName)

    --Check if any other dependent/similar addon is active
    FCOSS.checkIfOtherAddonsAreActive()

    --Load the SavedVariables settings
    FCOSS.loadSettings()

    --Deactivate debugging again
	FCOSS.debug = false

	-- Set Localization
	FCOSS.preventerVars.KeyBindingTexts = false
    FCOSS.Localization()

    --Initialize the food and drink buff ability ID names (description texts) for the current active client language
	--FCOSS.getFoodBuffNames(false) --> Using library libFoodDrinkBuffs now

    local settings = FCOSS.settingsVars.settings
    local defaults = FCOSS.settingsVars.defaults
    --Update some localized settings now
    if not settings.textAlertGeneralChanged and settings.textAlertGeneral == defaults["textAlertGeneral"] and FCOSS.localizationVars.fco_ss_loc["icon_tooltip_text"] ~= "" then
    	settings.textAlertGeneral = FCOSS.localizationVars.fco_ss_loc["icon_tooltip_text"]
    end
    if not settings.textAlertGeneralChangedPotion and settings.textAlertGeneralPotion == defaults["textAlertGeneralPotion"] and FCOSS.localizationVars.fco_ss_loc["icon_tooltip_potion_text"] ~= "" then
    	settings.textAlertGeneralPotion = FCOSS.localizationVars.fco_ss_loc["icon_tooltip_potion_text"]
    end

    --Load the eevent callback functions
    FCOSS.loadEvents()

    --Create the alert icon control
	FCOSS.createAlertIcons()

	--Add a fragment for the food buff icon container to the HUD and HUD_UD scenes
    --so the icon can be shown/hidden
	local fragmentFood = ZO_HUDFadeSceneFragment:New(FCOStarveStopContainer, nil, 0)
	HUD_SCENE:AddFragment(fragmentFood)
	HUD_UI_SCENE:AddFragment(fragmentFood)
	--Add a fragment for the potion icon container to the HUD and HUD_UD scenes
    --so the icon can be shown/hidden
	local fragmentPotion = ZO_HUDFadeSceneFragment:New(FCOStarveStopContainerPotion, nil, 0)
	HUD_SCENE:AddFragment(fragmentPotion)
	HUD_UI_SCENE:AddFragment(fragmentPotion)
	--Callback function for HUD scene
    HUD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			zo_callLater(function()
				if not FCOSS.alertIcon:IsHidden() and FCOSS.alertIcon.hideNow then
					FCOSS.alertIcon.hideNow = false
		    		FCOStarveStopContainer:SetHidden(true)
			    	FCOSS.alertIcon:SetHidden(true)
			    end
				if not FCOSS.alertIconPotion:IsHidden() and FCOSS.alertIconPotion.hideNow then
					FCOSS.alertIconPotion.hideNow = false
		    		FCOStarveStopContainerPotion:SetHidden(true)
			    	FCOSS.alertIconPotion:SetHidden(true)
			    end
            end, 350)
        end
    end)

    -- Register slash commands
	FCOSS.RegisterSlashCommands()

	-- Registers addon to loadedAddon library
	LIBLA:RegisterAddon(FCOSS.addonVars.addonName, FCOSS.addonVars.addonRealVersion)
end

--Addon initialization
function FCOSS.initialize()
	EVENT_MANAGER:RegisterForEvent(FCOSS.addonVars.addonName, EVENT_ADD_ON_LOADED, FCOSS_addonLoaded)
end

--Starting the addon
FCOSS.initialize()
