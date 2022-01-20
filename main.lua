-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
-- https://wowpedia.fandom.com/wiki/UI_escape_sequences

local BuyItemIndex, BuyItemQuantity, IsBuying = 0, 0, false

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
    local itemIndex, quantity = msg:match("^(%d+)%s+(%d+)%s*$")
    if  itemIndex ~= "" and quantity ~= "" then
        if tonumber(quantity) > 0 and tonumber(quantity) < 11 then
            if tonumber(itemIndex) > 0 then
                IsBuying = true
                BuyItemIndex, BuyItemQuantity = itemIndex, tonumber(quantity)
            else
                DisplayError("Index must be greater than zero (1 based index)");
            end
        else
            DisplayError("Quantity did not match expected values (1 to 10)");
        end
    else
        DisplayError('item index or quantity was empty');
    end
    print('\124cFFeb8034NoRepair Help \124rbuying item:'..BuyItemIndex..' with quantity: '..BuyItemQuantity)
end

SLASH_NOREPAIRBUYORDER1, SLASH_NOREPAIRBUYORDER2 = '/nrbo', '/norepairbuyorder';
function SlashCmdList.NOREPAIRBUYORDER(msg, editBox)
    print('(NoRepair) Order Check:'..tostring(IsBuying)..' buying item index:'..BuyItemIndex..' with quantity: '..tostring(BuyItemQuantity))
end

SLASH_NOREPAIRBUYORDERCANCEL1, SLASH_NOREPAIRBUYORDERCANCEL2 = '/nrbc', '/norepairbuycancel';
function SlashCmdList.NOREPAIRBUYORDERCANCEL(msg, editBox)
    print('(NoRepair) Cancelling order!')
    BuyItemIndex, BuyItemQuantity, IsBuying = '', 0, false
end

local function BuyItemsViaOrder(self, event)
    if(CanMerchantRepair()) then
        if(IsBuying) then
            --execute check do they have it?
            local merchantItemMax = GetMerchantNumItems()
            if BuyItemIndex <= merchantItemMax then
                BuyMerchantItem(BuyItemIndex, tonumber(BuyItemQuantity))
            else
                print('\124rERROR That index is too high! cancelling order')
            end
            CloseMerchant()
            BuyItemIndex, BuyItemQuantity, IsBuying = '', 0, false
        else
            local numItems = GetMerchantNumItems();
            print('NoRepair: This vendor sells the following items. ')
            print('| I:Index | N:Name | P:Price | S:Stack_Size |')
            for i= 1, numItems do
                local name, texture, price, quantity, numAvailable, isPurchasable = GetMerchantItemInfo(i);
                if isPurchasable == 'true' and numAvailable > 0 then
                    print('| I:'..i..' | N:'..name..' | P:'..GetCoinTextureString(price)..' | S:'..quantity..' |')
                else
                    print('| I:'..i..' | N:'..name..' | \124rUnavailable for Purchase |')
                end
            end
            CloseMerchant()
            print('NoRepair: Make a buy order using /nrb or /norepairbuy with the index and quantity');
        end
    end
end

local event = CreateFrame("Frame")
event:SetScript("OnEvent", BuyItemsViaOrder);
event:RegisterEvent("MERCHANT_SHOW")

local function printHello (self, event)
    print('NoRepair loaded - Gear is now one time use!')
end

local login = CreateFrame("Frame")
login:SetScript("OnEvent", printHello);
login:RegisterEvent("PLAYER_LOGIN")
