if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Other addons
------------------------------------------------------------------------------------------------------------
--Check for other addons
local function checkForOtherAddons()
    --Is addon AutoSlotSwitch loaded?
    if     FCOSS.otherAddons.autoSlotSwitch ~= nil
            and (FCOSS.otherAddons.autoSlotSwitch["name"] ~= nil and FCOSS.otherAddons.autoSlotSwitch["name"] ~= "")
            and (FCOSS.otherAddons.autoSlotSwitch["version"] ~= nil) then
        local isLoaded, versionNum = FCOSS.libLA:IsAddonLoaded(FCOSS.otherAddons.autoSlotSwitch["name"])
        if versionNum == nil then versionNum = 0 end
        if versionNum >= FCOSS.otherAddons.autoSlotSwitch["version"] then
            if not isLoaded then
                isLoaded = (ASS ~= nil)
            end
            FCOSS.otherAddons.autoSlotSwitch["isLoaded"] = isLoaded
        end
    end
end

--Check if other addons are currently active
function FCOSS.checkIfOtherAddonsAreActive()
    --Check for other loaded addons
    checkForOtherAddons()
end
