-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)

local function DisableRepair(self, event)
    --check if vendor is a repairer
    if(CanMerchantRepair()) then
        local repairAllCost, canRepair = GetRepairAllCost();
        DEFAULT_CHAT_FRAME:AddMessage('Mom: It costs HOW MUCH to repair your gear? '..GetCoinTextureString(repairAllCost))
        DEFAULT_CHAT_FRAME:AddMessage('Mom: We can repair at home. Lets go.')
        CloseMerchant()
    end
end

local event = CreateFrame("Frame")
event:SetScript("OnEvent", DisableRepair);
event:RegisterEvent("MERCHANT_SHOW")

--could try intercepting the HW event if repair is clicked ?