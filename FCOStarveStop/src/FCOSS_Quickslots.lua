if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Quickslots
------------------------------------------------------------------------------------------------------------
--Function to change the quickslots if a buff/potion cd is fading out/gone
function FCOSS.changeQuickslots(insideCombat, buffFoodAlert)
    buffFoodAlert = buffFoodAlert or false
    --Is the quickslot change enabled in the settings?
    local inPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize
    if FCOSS.settingsVars.settings.quickSlotChangePVE or FCOSS.settingsVars.settings.quickSlotChangePVP then
        --Check the current zone where the user is and the group status
        inPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize = FCOSS.getCurrentZoneAndGroupStatus()
        --d("PvP: " .. tostring(inPVP) .. ", insideCombat: " .. tostring(insideCombat) .. ", buffFoodAlert: " .. tostring(buffFoodAlert) .. ", isInDelve: " .. tostring(isInDelve) .. ", isInPublicDungeon: " .. tostring(isInPublicDungeon) .. ", isInGroupDungeon: " .. tostring(isInGroupDungeon) .. ", isInRaid: " .. tostring(isInRaid) .. ", isInGroup: " .. tostring(isInGroup) .. ", groupSize: " .. groupSize)
    else
        --Just check if user is in PvP area
        inPVP = IsPlayerInAvAWorld()
        --d("PvP: " .. tostring(inPVP) .. ", insideCombat: " .. tostring(insideCombat) .. ", buffFoodAlert: " .. tostring(buffFoodAlert))
    end
    --Get the currently active quickslot
    local currentQuickSlot
    --Is the current quickslot already defined from any other quickslot addon, like "AutoSlotSwitch"?
    if FCOSS.otherAddons.autoSlotSwitch["isLoaded"] and FCOSS.otherAddons.autoSlotSwitch["lastNonCombatQuickslot"] ~= -1 then
        currentQuickSlot = FCOSS.otherAddons.autoSlotSwitch["lastNonCombatQuickslot"]
    else
        currentQuickSlot = GetCurrentQuickslot()
    end

    --Upon entering combat: Remember the last active quickslot before the fight
    if insideCombat then
        --d("inside combat")
        if inPVP then
            --d("pvp")
            --PVP: Check the settings if the last active quickslot should automatically be remembered, or if a special one should be used (selected in the settings)
            if FCOSS.settingsVars.settings.quickSlotChangeToPVPLast then
                --d("change to last pvp active")
                FCOSS.settingsVars.settings.quickSlotBeforePVP = currentQuickSlot
            end
        else
            --d("pve")
            --PVE: Check the settings if the last active quickslot should automatically be remembered, or if a special one should be used (selected in the settings)
            if FCOSS.settingsVars.settings.quickSlotChangeToPVELast then
                --d("change to last pve active")
                FCOSS.settingsVars.settings.quickSlotBeforePVE = currentQuickSlot
            end
        end
    else
        --d("out of combat")
        --Not inside combat - remember the current active quickslot so the option "Change to last active" can be used
        if inPVP then
            --d("pvp")
            FCOSS.settingsVars.settings.quickSlotBeforePVPInCombat = currentQuickSlot
        else
            --d("pve")
            FCOSS.settingsVars.settings.quickSlotBeforePVEInCombat = currentQuickSlot
        end
    end -- if insideCombat

    --Changing quickslots for current area (PvE/PvP) is not activated, or other addons are preferred?
    --Only if the buff food check was done and the food is currently not active, or the settings allow to change quickslots if buff food is active too
    if  (inPVP and not FCOSS.settingsVars.settings.quickSlotChangePVP) or (not inPVP and not FCOSS.settingsVars.settings.quickSlotChangePVE)
            or (insideCombat and FCOSS.checkIfOtherQuickslotAddonsArePreferred())
            or (not FCOSS.buffFoodNotActive and not FCOSS.settingsVars.settings.changeQuickslotsWithBuffFood)
    then
        --d("ABORTING")
        return false
    end

    --Check if we are in combat currently and change the quickslot accordingly, if activate in the settings
    --Out of combat
    if not insideCombat then
        --d(">not in combat")
        if inPVP then
            --d(">PVP")
            --PVP
            if buffFoodAlert then
                SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVP)

            else
                if     (not FCOSS.otherAddons.autoSlotSwitch["isLoaded"])
                        or (not FCOSS.settingsVars.settings.preferAutoSlotSwitch and FCOSS.otherAddons.autoSlotSwitch["isLoaded"]) then
                    --Change to the last active quickslot before combat PVP, or change to pre-defined quickslots?
                    if FCOSS.settingsVars.settings.quickSlotChangeToPVPLast then
                        --Change to last active before combat
                        SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotBeforePVP)
                    else
                        --Change to pre-defined quickslots PVP
                        if 	   isInDelve then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToDelvePVP)
                        elseif isInPublicDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVP)
                        elseif isInGroupDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVP)
                        elseif isInRaid or (isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD) then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVP)
                        else
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPVP)
                        end
                    end
                end
            end
        else
            --d(">PVE")
            --PVE
            if buffFoodAlert then
                SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVE)
            else
                if     (not FCOSS.otherAddons.autoSlotSwitch["isLoaded"])
                        or (not FCOSS.settingsVars.settings.preferAutoSlotSwitch and FCOSS.otherAddons.autoSlotSwitch["isLoaded"]) then
                    --d(">>drin")
                    --Change to the last active quickslot before combat PVE, or change to pre-defined quickslots?
                    if FCOSS.settingsVars.settings.quickSlotChangeToPVELast then
                        --Change to last active before combat
                        SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotBeforePVE)
                    else
                        --Change to pre-defined quickslots PVE out of combat
                        if 	   isInDelve then
                            --d(">delve")
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToDelvePVE)
                        elseif isInPublicDungeon then
                            --d(">pub dungeon")
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVE)
                        elseif isInGroupDungeon then
                            --d(">group dungeon")
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVE)
                        elseif isInRaid or (isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD) then
                            --d(">raid group dungeon")
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVE)
                        else
                            --d(">normal: " .. FCOSS.settingsVars.settings.quickSlotChangeToPVE)
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPVE)
                        end
                    end
                end
            end
        end

        --In combat
    else
        if inPVP then
            --PVP
            if buffFoodAlert and FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffInCombat then
                SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVP)
            else
                if     (not FCOSS.settingsVars.settings.preferAutoSlotSwitch and not FCOSS.otherAddons.autoSlotSwitch["isLoaded"])
                        or (not FCOSS.settingsVars.settings.preferAutoSlotSwitch and FCOSS.otherAddons.autoSlotSwitch["isLoaded"]) then
                    --Change to the last active quickslot used in combat PVP, or change to pre-defined quickslots?
                    if FCOSS.settingsVars.settings.quickSlotChangeToPVPInCombatLast then
                        --Change to last active before combat
                        SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotBeforePVPInCombat)
                    else
                        --Change to pre-defined quickslots PVP out of combat
                        if 	   isInDelve then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToDelvePVPInCombat)
                        elseif isInPublicDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVPInCombat)
                        elseif isInGroupDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVPInCombat)
                        elseif isInRaid or (isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD) then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVPInCombat)
                        else
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPVPInCombat)
                        end
                    end
                end
            end
        else
            --PVE
            if buffFoodAlert and FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffInCombat then
                SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVE)
            else
                if     (not FCOSS.otherAddons.autoSlotSwitch["isLoaded"])
                        or (not FCOSS.settingsVars.settings.preferAutoSlotSwitch and FCOSS.otherAddons.autoSlotSwitch["isLoaded"]) then
                    --Change to the last active quickslot used in combat PVE, or change to pre-defined quickslots?
                    if FCOSS.settingsVars.settings.quickSlotChangeToPVEInCombatLast then
                        --Change to last active before combat
                        SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotBeforePVEInCombat)
                    else
                        --Change to pre-defined quickslots PVE out of combat
                        if 	   isInDelve then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToDelvePVEInCombat)
                        elseif isInPublicDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVEInCombat)
                        elseif isInGroupDungeon then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVEInCombat)
                        elseif isInRaid or (isInGroup and groupSize > SMALL_GROUP_SIZE_THRESHOLD) then
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVEInCombat)
                        else
                            SetCurrentQuickslot(FCOSS.settingsVars.settings.quickSlotChangeToPVEInCombat)
                        end
                    end
                end
            end
        end
    end
    --Change to correct quickslot again after you consumed the food buff?
    if not insideCombat then
        FCOSS.preventerVars.changeBackToQuickslotAfterFoodBuffUsage = buffFoodAlert
    else
        FCOSS.preventerVars.changeBackToQuickslotAfterFoodBuffUsage = buffFoodAlert and FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffInCombat
    end
end


--Function to check if the active quickslot is a potion and change to the wanted potion quickslot if it's not a potion
function FCOSS.checkActiveQuickSlotIsPotionAndChangeToPotionIfNeeded()
    local retPotionName = ""
    --Check if the food buff is currently active. If not: Do not change the quickslot to a potion!
    if FCOSS.buffFoodNotActive then return "" end
    local insideCombat = IsUnitInCombat('player')
    --Check if quickslots should be changed
    FCOSS.changeQuickslots(insideCombat, false) -- no food buff alert, so change to the desired quickslot now
    --Get the active quickslot
    local currentQuickSlot = GetCurrentQuickslot()
    if currentQuickSlot ~= nil then
        --Get the current quickslot's text, quality and icon
        local qsNameText = GetSlotName(currentQuickSlot)
        local slotItemQuality = GetSlotItemQuality(currentQuickSlot)
        if qsNameText and slotItemQuality then
            local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, slotItemQuality)
            local colorDef = ZO_ColorDef:New(r, g, b, 1)
            qsNameText = colorDef:Colorize(qsNameText)
        end
        if qsNameText ~= "" then retPotionName = qsNameText end
        --Get the quickslot texture
        local qsIconPath = GetSlotTexture(currentQuickSlot)
        if not qsIconPath or qsIconPath == "" then qsIconPath = EMPTY_QUICKSLOT_TEXTURE
        else
            --Put the quickslot's texture into the string
            retPotionName = zo_iconTextFormat(qsIconPath, 48, 48, retPotionName)
        end
    end
    return retPotionName
end

function FCOSS.GetQuickslots()
    if not QUICKSLOT_WINDOW or not QUICKSLOT_WINDOW.quickSlots then return false end
    local qsTable = {}
    local qSlots = QUICKSLOT_WINDOW.quickSlots

    for qsNr, qsControl in pairs(qSlots) do
        local qsNameText = GetSlotName(qsNr)
        local itemLink = GetSlotItemLink(qsNr)
        local itemRequiredLevel = GetItemLinkRequiredLevel(itemLink)
        local itemRequiredVetLevel = GetItemLinkRequiredVeteranRank(itemLink)
        local itemLevel
        if itemRequiredVetLevel and itemRequiredVetLevel > 0 then
            itemLevel = "|cffd700CP" .. itemRequiredVetLevel
        else
            if itemRequiredLevel > 0 then
                itemLevel = "|cb4b4b4" .. itemRequiredLevel
            end
        end

        local iconPath = GetSlotTexture(qsNr)
        if not iconPath or iconPath == "" then iconPath = EMPTY_QUICKSLOT_TEXTURE end

        --Filled quickslot?
        if iconPath ~= EMPTY_QUICKSLOT_TEXTURE then
            qsNameText = zo_strformat(SI_TOOLTIP_ITEM_NAME, qsNameText)

            local slotItemQuality = GetSlotItemQuality(qsNr)
            if slotItemQuality then
                local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, slotItemQuality)
                local colorDef = ZO_ColorDef:New(r, g, b, 1)
                qsNameText = colorDef:Colorize(qsNameText)
            end

            local countText = qsControl.countText:GetText()
            if countText and countText ~= "" then
                qsNameText = qsNameText .. " [" .. countText .. "]"
            end

            --Empty quick slot
        else
            qsNameText = FCOSS.quickSlotEmptyText
        end

        --Add the icon of the quickslot item at the beginning
        if iconPath and iconPath ~= "" and iconPath ~= EMPTY_QUICKSLOT_TEXTURE then
            qsNameText = zo_iconTextFormat(iconPath, FCOSS.quickslotSelectIconSize, FCOSS.quickslotSelectIconSize, qsNameText)
        end

        if qsNameText ~= nil and qsNr ~= nil then

            --Add the level of the quickslot item at the beginning
            if itemLevel and itemLevel ~= "" then
                qsNameText = itemLevel .. qsNameText
            end
            table.insert(qsTable, qsNr, qsNameText)
        end
    end

    --table.sort(qsTable)
    return qsTable
end

function FCOSS.BuildQuickSlotsSettings()
    --Build the quickslots selection dropdown for the addon settings menu
    local quickSlotsTable = {}
    local quickSlotsMappingTable = {}
    local quickSlotsBackwardsMappingTable = {}
    local quickSlotsNameTable = FCOSS.GetQuickslots()

    for	i=1, ACTION_BAR_UTILITY_BAR_SIZE, 1 do
        if quickSlotsNameTable[ACTION_BAR_FIRST_UTILITY_BAR_SLOT+i] and quickSlotsNameTable[ACTION_BAR_FIRST_UTILITY_BAR_SLOT+i] ~= "" then
            table.insert(quickSlotsTable, quickSlotsNameTable[ACTION_BAR_FIRST_UTILITY_BAR_SLOT+i])
        else
            table.insert(quickSlotsTable, FCOSS.localizationVars.fco_ss_loc["quickslot_nr" .. i])
        end
        quickSlotsMappingTable[i] = ACTION_BAR_FIRST_UTILITY_BAR_SLOT+i
        quickSlotsBackwardsMappingTable[ACTION_BAR_FIRST_UTILITY_BAR_SLOT+i] = i
    end
    FCOSS.quickSlots					= quickSlotsTable
    FCOSS.quickSlotsNameTable			= quickSlotsNameTable
    FCOSS.quickSlotsMapping				= quickSlotsMappingTable
    FCOSS.quickSlotsBackwardsMapping 	= quickSlotsBackwardsMappingTable
end

function FCOSS.updateQuickslotsSettingsDropdown()
    --Rebuild the quickslots for the addon settings menu
    FCOSS.BuildQuickSlotsSettings()

    --Update the addon menu dropdowns with the actual quickslots
    if     FCOSS.quickSlots
            and FCOStarveStop_Settings_PvE_Select and FCOStarveStop_Settings_PvE_Combat_Select
            and FCOStarveStop_Settings_PvP_Select and FCOStarveStop_Settings_PvP_Combat_Select
            and FCOStarveStop_Settings_Delve_PvE_Select and FCOStarveStop_Settings_Delve_PvE_Combat_Select
            and FCOStarveStop_Settings_Delve_PvP_Select and FCOStarveStop_Settings_Delve_PvP_Combat_Select
            and FCOStarveStop_Settings_PublicDungeon_PvE_Select and FCOStarveStop_Settings_PublicDungeon_PvE_Combat_Select
            and FCOStarveStop_Settings_PublicDungeon_PvP_Select and FCOStarveStop_Settings_PublicDungeon_PvP_Combat_Select
            and FCOStarveStop_Settings_GroupDungeon_PvE_Select and FCOStarveStop_Settings_GroupDungeon_PvE_Combat_Select
            and FCOStarveStop_Settings_GroupDungeon_PvP_Select and FCOStarveStop_Settings_GroupDungeon_PvP_Combat_Select
            and FCOStarveStop_Settings_RaidDungeon_PvE_Select and FCOStarveStop_Settings_RaidDungeon_PvE_Combat_Select
            and FCOStarveStop_Settings_RaidDungeon_PvP_Select and FCOStarveStop_Settings_RaidDungeon_PvP_Combat_Select
            and FCOStarveStop_Settings_FoodBuff_PvE_Select and FCOStarveStop_Settings_FoodBuff_PvP_Select
    then

        --Clear and add new entries from current quickslots
        --PVE
        FCOStarveStop_Settings_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PvE_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_Delve_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_Delve_PvE_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PublicDungeon_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PublicDungeon_PvE_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_GroupDungeon_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_GroupDungeon_PvE_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_RaidDungeon_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_RaidDungeon_PvE_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_FoodBuff_PvE_Select:UpdateChoices(FCOSS.quickSlots)
        --PVP
        FCOStarveStop_Settings_PvP_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PvP_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_Delve_PvP_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_Delve_PvP_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PublicDungeon_PvP_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_PublicDungeon_PvP_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_GroupDungeon_PvP_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_GroupDungeon_PvP_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_RaidDungeon_PvP_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_RaidDungeon_PvP_Combat_Select:UpdateChoices(FCOSS.quickSlots)
        FCOStarveStop_Settings_FoodBuff_PvP_Select:UpdateChoices(FCOSS.quickSlots)

        --Set the current selected entry again
        --PVE
        FCOStarveStop_Settings_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPVE]])
        FCOStarveStop_Settings_PvE_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPVEInCombat]])
        FCOStarveStop_Settings_Delve_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToDelvePVE]])
        FCOStarveStop_Settings_Delve_PvE_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToDelvePVEInCombat]])
        FCOStarveStop_Settings_PublicDungeon_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVE]])
        FCOStarveStop_Settings_PublicDungeon_PvE_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVEInCombat]])
        FCOStarveStop_Settings_GroupDungeon_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVE]])
        FCOStarveStop_Settings_GroupDungeon_PvE_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVEInCombat]])
        FCOStarveStop_Settings_RaidDungeon_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVE]])
        FCOStarveStop_Settings_RaidDungeon_PvE_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVEInCombat]])
        FCOStarveStop_Settings_FoodBuff_PvE_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVE]])
        --PVP
        FCOStarveStop_Settings_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPVP]])
        FCOStarveStop_Settings_PvP_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPVPInCombat]])
        FCOStarveStop_Settings_Delve_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToDelvePVP]])
        FCOStarveStop_Settings_Delve_PvP_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToDelvePVPInCombat]])
        FCOStarveStop_Settings_PublicDungeon_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVP]])
        FCOStarveStop_Settings_PublicDungeon_PvP_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToPublicDungeonPVPInCombat]])
        FCOStarveStop_Settings_GroupDungeon_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVP]])
        FCOStarveStop_Settings_GroupDungeon_PvP_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToGroupDungeonPVPInCombat]])
        FCOStarveStop_Settings_RaidDungeon_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVP]])
        FCOStarveStop_Settings_RaidDungeon_PvP_Combat_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToRaidDungeonPVPInCombat]])
        FCOStarveStop_Settings_FoodBuff_PvP_Select:UpdateValue(false, FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[FCOSS.settingsVars.settings.quickSlotChangeToFoodBuffPVP]])
    end
end

function FCOSS.checkIfOtherQuickslotAddonsArePreferred()
    local retVar = false
    --Is the addon "AutoSlotSwitch" prefered?
    retVar = FCOSS.otherAddons.autoSlotSwitch["isLoaded"] and FCOSS.settingsVars.settings.preferAutoSlotSwitch
    return retVar
end

