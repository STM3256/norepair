-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
--message?
print('I can haxxor code3!')

local function DisableRepair(self, event)
    --check if vendor is a repairer
    if(CanMerchantRepair()) then
        local repairAllCost, canRepair = GetRepairAllCost();
        DEFAULT_CHAT_FRAME:AddMessage('this vendor can repair')
        DEFAULT_CHAT_FRAME:AddMessage('repair cost='..GetCoinTextureString(repairAllCost)..',  canRepair='..tostring(canRepair))
        DEFAULT_CHAT_FRAME:AddMessage(canRepair)
        CloseMerchant()
    end
end

-- create frame
local event = CreateFrame("Frame")

--register the event
event:SetScript("OnEvent", DisableRepair);
event:RegisterEvent("MERCHANT_SHOW")

--could try intercepting the HW event if repair is clicked ?