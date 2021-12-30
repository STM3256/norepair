-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
-- https://wowpedia.fandom.com/wiki/UI_escape_sequences

local BuyItemName, BuyItemQuantity, IsBuying = '', 0, false

local function DisplayError(errormessage)
    print('\124cFFFF0000NoRepair ERROR - '..errormessage)
    print('\124cFFFF0000NoRepair ERROR - type '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR2..' for HELP');
end

local function DisplayHelp()
     print('\124cFFeb8034NoRepair Help \124rAny merchant that can repair gear will auto close unless you have a buy order ')
     print('\124cFFeb8034NoRepair Help \124rTo place a buy order use either '..SLASH_NOREPAIRBUY1..' or '..SLASH_NOREPAIRBUY2..' in the following syntax: ')
     print('\124cFFeb8034NoRepair Help \124rSYNTAX: /nrb   <ITEM>   <QUANTITY>')
     print('\124cFFeb8034NoRepair Help \124rEXAMPLE: /nrb coal 3 ')
     print('\124cFFeb8034NoRepair Help \124r<ITEM> is one of: wflux, sflux, eflux, coal, hammer, pick ')
     print('\124cFFeb8034NoRepair Help \124r<QUANTITY> is between (and including) 1 and 10 ')
     print('\124cFFeb8034NoRepair Help \124rAfter your buy order is fufilled, default behavior is resumed')
     print('\124cFFeb8034NoRepair Help \124rTo check your current order use '..SLASH_NOREPAIRBUYORDER1..' or '..SLASH_NOREPAIRBUYORDER2)
     print('\124cFFeb8034NoRepair Help \124rTo cancel your current order use '..SLASH_NOREPAIRBUYORDERCANCEL1..' or '..SLASH_NOREPAIRBUYORDERCANCEL2)
     print('\124cFFeb8034NoRepair Help \124rThis message can be seen again by invoking one of '..SLASH_NOREPAIR1..' or '..SLASH_NOREPAIR2..' or '..SLASH_NOREPAIR3)
end

SLASH_NOREPAIR1, SLASH_NOREPAIR2, SLASH_NOREPAIR3 = '/nr', '/norepair', '/norepairhelp'
function SlashCmdList.NOREPAIR(msg, editBox)
    DisplayHelp()
end

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
                DisplayError('item name did not match expected values');
            end
        else
            DisplayError("quantity did not match expected values");
        end
    else
        DisplayError('item name or quantity was empty');
    end
    print('\124cFFeb8034NoRepair Help \124rbuying item:'..BuyItemName..' with quantity: '..BuyItemQuantity)
end

SLASH_NOREPAIRBUYORDER1, SLASH_NOREPAIRBUYORDER2 = '/nrbo', '/norepairbuyorder';
function SlashCmdList.NOREPAIRBUYORDER(msg, editBox)
    print('(NoRepair) Order Check:'..tostring(IsBuying)..' buying item:'..BuyItemName..' with quantity: '..tostring(BuyItemQuantity))
end

SLASH_NOREPAIRBUYORDERCANCEL1, SLASH_NOREPAIRBUYORDERCANCEL2 = '/nrbc', '/norepairbuycancel';
function SlashCmdList.NOREPAIRBUYORDERCANCEL(msg, editBox)
    print('(NoRepair) Cancelling order!')
    BuyItemName, BuyItemQuantity, IsBuying = '', 0, false
end

local function BuyItemsViaOrder(self, event)
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
                        print('(NoRepair) Order fufilled!')
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
                print('\124cFFFF0000NoRepair 124rERROR Item not found, cancelling order')
            end
            BuyItemName, BuyItemQuantity, IsBuying = '', 0, false
        else
            local repairAllCost, canRepair = GetRepairAllCost();
            CloseMerchant()
            print('(NoRepair) Mom: It costs HOW MUCH to repair your gear? '..GetCoinTextureString(repairAllCost))
            print('(NoRepair) Mom: We can repair at home. Lets go.')
            print('(NoRepair if you want to place an order use \124cFFeb8034/nrb\124r )')
        end
    end
end

local event = CreateFrame("Frame")
event:SetScript("OnEvent", BuyItemsViaOrder);
event:RegisterEvent("MERCHANT_SHOW")
