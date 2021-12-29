-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
-- https://wowpedia.fandom.com/wiki/UI_escape_sequences


local function DisplayHelp()
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) Any merchant that can repair gear will auto close unless you have a buy order ')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) To place a buy order use either '..SLASH_NOREPAIRBUY1..' or '..SLASH_NOREPAIRBUY2..' in the following syntax: ')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) SYNTAX: /nrb   <ITEM>   <QUANTITY>')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) EXAMPLE: /nrb coal 3 ')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) <ITEM> is one of: wflux, sflux, eflux, coal, hammer, pick ')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) <QUANTITY> is between (and including) 1 and 10 ')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) After your buy order is fufilled, default behavior is resumed')
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) To check your current order use '..SLASH_NOREPAIRBUYORDER1..' or '..SLASH_NOREPAIRBUYORDER2)
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) To cancel your current order use '..SLASH_NOREPAIRBUYORDERCANCEL1..' or '..SLASH_NOREPAIRBUYORDERCANCEL2)
     DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) This message can be seen again by invoking one of '..SLASH_NOREPAIR1..' or '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR3)
end

SLASH_NOREPAIR1, SLASH_NOREPAIR2, SLASH_NOREPAIR3 = '/nr', '/norepair', '/norepairhelp'
function SlashCmdList.NOREPAIR(msg, editBox)
    DisplayHelp()
end

local BuyItemName, BuyItemQuantity, IsBuying = '', 0, false

SLASH_NOREPAIRBUY1, SLASH_NOREPAIRBUY2 = '/nrb', '/norepairbuy';
function SlashCmdList.NOREPAIRBUY(msg, editBox)
    local itemname, quantity = msg:match("^(%S*)%s+(%d+)$")
    if quantity ~= "" and itemname ~= "" then
        if tonumber(quantity) > 0 and tonumber(quantity) < 11 then
            IsBuying = true
            if itemname == "wflux" then
                BuyItemName, BuyItemQuantity = 'Weak Flux', tonumber(quantity)
            elseif itemname == "sflux" then
                BuyItemName, BuyItemQuantity = 'Strong Flux', tonumber(quantity)
            elseif itemname == "coal" then
                BuyItemName, BuyItemQuantity = 'Coal', tonumber(quantity)
            elseif itemname == "eflux" then
                BuyItemName, BuyItemQuantity = 'Elemental Flux', tonumber(quantity)
            elseif itemname == "hammer" then
                BuyItemName, BuyItemQuantity = 'Blacksmith Hammer', tonumber(quantity)
            elseif itemname == "pick" then
                BuyItemName, BuyItemQuantity = 'Mining Pick', tonumber(quantity)
            else
                IsBuying = false
                print("(NoRepair ERROR) - item name did not match expected values");
                print('\124cFFFF0000(NoRepair ERROR) - type '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR2..' for HELP');
            end
        else
            print("(NoRepair ERROR) - quantity did not match expected values");
            print('\124cFFFF0000(NoRepair ERROR) - type '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR2..' for HELP');
        end
    else
        print('(NoRepair ERROR) - item name or quantity was empty');
        print('\124cFFFF0000(NoRepair ERROR) - type '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR2..' for HELP');
    end
    DEFAULT_CHAT_FRAME:AddMessage('(NoRepair Help) buying item:'..BuyItemName..' with quantity: '..BuyItemQuantity)
end

SLASH_NOREPAIRBUYORDER1, SLASH_NOREPAIRBUYORDER2 = '/nrbo', '/norepairbuyorder';
function SlashCmdList.NOREPAIRBUYORDER(msg, editBox)
    DEFAULT_CHAT_FRAME:AddMessage('(NoRepair) Order Check:'..tostring(IsBuying)..' buying item:'..BuyItemName..' with quantity: '..tostring(BuyItemQuantity))
end

SLASH_NOREPAIRBUYORDERCANCEL1, SLASH_NOREPAIRBUYORDERCANCEL2 = '/nrbc', '/norepairbuycancel';
function SlashCmdList.NOREPAIRBUYORDERCANCEL(msg, editBox)
    DEFAULT_CHAT_FRAME:AddMessage('(NoRepair) Cancelling order!')
    BuyItemName, BuyItemQuantity, IsBuying = '', 0, false
end

local function DisableRepair(self, event)
    if(CanMerchantRepair()) then
        if(IsBuying) then
            --execute check do they have it?
            local merchantItemMax = GetMerchantNumItems()
            local saveindex = 0
            for i= 1, merchantItemMax do
                saveindex = i
                local name, texture, price, quantity, numAvailable, isPurchasable = GetMerchantItemInfo(i);
                if name == BuyItemName then
                    --attempt buy
                    if tostring(isPurchasable) == 'true' then
                        BuyMerchantItem(i, tonumber(BuyItemQuantity))
                        CloseMerchant()
                        DEFAULT_CHAT_FRAME:AddMessage('(NoRepair) Order fufilled!')
                        break
                    else
                        print('Found it but it was unavailable for purchase')
                    end
                else
                    --print(name..' did not match '..BuyItemName)
                end
            end
            CloseMerchant()
            if merchantItemMax == saveindex then
                DEFAULT_CHAT_FRAME:AddMessage('\124cFFFF0000(NoRepair ERROR) Item not found, cancelling order')
            end
            BuyItemName, BuyItemQuantity, IsBuying = '', 0, false
        else
            local repairAllCost, canRepair = GetRepairAllCost();
            CloseMerchant()
            DEFAULT_CHAT_FRAME:AddMessage('(NoRepair) Mom: It costs HOW MUCH to repair your gear? '..GetCoinTextureString(repairAllCost))
            DEFAULT_CHAT_FRAME:AddMessage('(NoRepair) Mom: We can repair at home. Lets go.')
            DEFAULT_CHAT_FRAME:AddMessage('(NoRepair if you want to place an order use \124cFFeb8034/nrb\124r )')
        end
    end
end

local event = CreateFrame("Frame")
event:SetScript("OnEvent", DisableRepair);
event:RegisterEvent("MERCHANT_SHOW")
