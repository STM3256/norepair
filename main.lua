-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- https://developer.school/developing-world-of-warcraft-addons-hello-world-part-one
-- https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
-- https://wowpedia.fandom.com/wiki/UI_escape_sequences

--debugging script
--/script name, texture, price, stackSize, numAvailable, isPurchasable, isUsable = GetMerchantItemInfo(6); print(isUsable)

local version = '2.3.classictest'
local maxCharactersInItemName = 25
local BuyItemIndex, BuyItemQuantity, IsBuying = 0, 0, false

local function DisplayError(errormessage)
    print('\124cFFFF0000NoRepair ERROR - '..errormessage)
    print('\124cFFFF0000NoRepair ERROR - type '..SLASH_NOREPAIR1..' help or '..SLASH_NOREPAIRHELP1..' or '..SLASH_NOREPAIRHELP2..' or '..SLASH_NOREPAIRHELP3..' for HELP');
end

local function DisplayHelp()
     print('\124cFFeb8034NoRepair Help \124rAny merchant that can repair gear will auto close and print their inventory')
     print('\124cFFeb8034NR \124rIf you have a buy order, you can auto buy safely')
     print('\124cFFeb8034NR \124r/nr <COMMAND> where commands are: \124cFF32CD32check cancel')
     print('\124cFFeb8034NR \124rTo place a buy order use either '..SLASH_NOREPAIRBUY1..' or '..SLASH_NOREPAIRBUY2..' in the following syntax: ')
     print('\124cFFeb8034NR \124rSYNTAX: /nrb   <ITEM INDEX>   <QUANTITY>')
     print('\124cFFeb8034NR \124r<ITEM INDEX> is the index number of the item in that vendor\'s inventory')
     print('\124cFFeb8034NR \124r<QUANTITY> is between (and including) 1 and 100 ')
     print('\124cFFeb8034NR \124rEXAMPLE: /nrb 2 5 ')
     print('\124cFFeb8034NR \124rThis will buy five of the second item (left to right, top to bottom)')
     print('\124cFFeb8034NR \124rAfter creating your buy order, open vendor to auto buy')
     print('\124cFFeb8034NR \124rTo check your current order use '..SLASH_NOREPAIR1..' check or '..SLASH_NOREPAIRCHECKORDER1..' or '..SLASH_NOREPAIRCHECKORDER2..' or '..SLASH_NOREPAIRCHECKORDER3)
     print('\124cFFeb8034NR \124rTo cancel your current order use '..SLASH_NOREPAIR1..' cancel or '..SLASH_NOREPAIRCANCEL1..' or '..SLASH_NOREPAIRCANCEL2..' or '..SLASH_NOREPAIRCANCEL3)
     print('\124cFFeb8034NR \124rThis message can be seen again by invoking one of '..SLASH_NOREPAIRHELP1..' '..SLASH_NOREPAIRHELP2..' '..SLASH_NOREPAIRHELP3)
end

--TODO
--'/nr COMMAND '
--'/nr buyindex '
--'/nr buyindex 3 1'
--'/nr COMMAND NAME<SPACE>NAME QUANTITY'
--'/nr buyname weak flux 1'
-- function SlashCmdList.NOREPAIR(msg, editBox)
--     local command itemIndex, quantity = msg:match("^(%d+)%s+(%d+)%s*$")
-- end

SLASH_NOREPAIRHELP1, SLASH_NOREPAIRHELP2, SLASH_NOREPAIRHELP3 = '/norepair', '/norepairhelp', '/nrhelp'
function SlashCmdList.NOREPAIRHELP(msg, editBox)
    DisplayHelp()
end

SLASH_NOREPAIR1 = '/nr'
function SlashCmdList.NOREPAIR(msg, editBox)
    local command = msg:match("^(%a+)%s*$")
    if command ~= "" and command ~= nil then
        local lowerCommand = string.lower(command)
        if lowerCommand == 'cancel' then
            print('\124cFFeb8034NoRepair \124rCancelling order!')
            BuyItemIndex, BuyItemQuantity, IsBuying = 0, 0, false
        elseif lowerCommand == 'check' then
            if IsBuying == true then
                print('\124cFFeb8034NoRepair: \124rOrder Check: buying item index:'..BuyItemIndex..' with quantity: '..tostring(BuyItemQuantity))
            else
                print('\124cFFeb8034NoRepair: \124rNo buy order set')
                print('\124cFFeb8034NoRepair: \124rMake a buy order using /nrb with the index and quantity');
                print('\124cFFeb8034NoRepair: \124r/nrb   <ITEM INDEX>   <QUANTITY>')
            end
        elseif lowerCommand == 'help' then
            DisplayHelp()
        else
            DisplayError('command not recognized; showing help instead')
            DisplayHelp()
        end
    else
        DisplayError('no command entered - showing help')
        DisplayHelp()
    end
end

SLASH_NOREPAIRBUY1, SLASH_NOREPAIRBUY2 = '/nrb', '/norepairbuy';
function SlashCmdList.NOREPAIRBUY(msg, editBox)
    local itemIndex, quantity = msg:match("^(%d+)%s+(%d+)%s*$")
    if  itemIndex ~= "" and itemIndex ~= nil and quantity ~= "" and quantity ~= nil then
        if tonumber(quantity) > 0 and tonumber(quantity) < 101 then
            if tonumber(itemIndex) > 0 then
                IsBuying = true
                BuyItemIndex, BuyItemQuantity = tonumber(itemIndex), tonumber(quantity)
            else
                DisplayError("Index must be greater than zero (1 based index)");
            end
        else
            DisplayError("Quantity did not match expected values (1 to 100)");
        end
    else
        DisplayError('item index or quantity was empty');
    end
    print('\124cFFeb8034NoRepair \124rbuying item:'..BuyItemIndex..' with quantity: '..BuyItemQuantity)
end

SLASH_NOREPAIRCHECKORDER1, SLASH_NOREPAIRCHECKORDER2, SLASH_NOREPAIRCHECKORDER3 = '/nrch', '/norepaircheck', '/norepaircheckorder';
function SlashCmdList.NOREPAIRBUYORDER(msg, editBox)
    if IsBuying == true then
        print('\124cFFeb8034NoRepair: \124rOrder Check: buying item index:'..BuyItemIndex..' with quantity: '..tostring(BuyItemQuantity))
    else
        print('\124cFFeb8034NoRepair: No buy order set')
        print('\124cFFeb8034NoRepair: Make a buy order using /nrb with the index and quantity');
        print('\124cFFeb8034NoRepair: /nrb   <ITEM INDEX>   <QUANTITY>')
    end
end

SLASH_NOREPAIRCANCEL1, SLASH_NOREPAIRCANCEL2, SLASH_NOREPAIRCANCEL3 = '/nrc', '/nrcancel', '/norepairbuycancel';
function SlashCmdList.NOREPAIRBUYORDERCANCEL(msg, editBox)
    print('\124cFFeb8034NoRepair \124rCancelling order!')
    BuyItemIndex, BuyItemQuantity, IsBuying = 0, 0, false
end

local function BuyItemsViaOrder(self, event)
    if(CanMerchantRepair()) then
        if(IsBuying) then
            local merchantItemMax = GetMerchantNumItems()
            if BuyItemIndex <= merchantItemMax then
                BuyMerchantItem(BuyItemIndex, tonumber(BuyItemQuantity))
            else
                print('\124rERROR That index is too high! cancelling order')
            end
            CloseMerchant()
            BuyItemIndex, BuyItemQuantity, IsBuying = 0, 0, false
        else
            local numItems = GetMerchantNumItems();
            print('NoRepair: This vendor sells '..numItems..' items')
            print('| Index | Price |           Name')
            print('|----------------------------------------------------------------')
            for i = 1, numItems do
                local name, texture, price, stackSize, numAvailable, isPurchasable, isUsable = GetMerchantItemInfo(i); --extendedCost, currencyID not using
                local priceDigits = string.len(tostring(price))
                local numberOfSpacesPriceBuffer = (6 - priceDigits)*3

                --add space if zero in tens place because GetCoinTextureString won't show zero in 1 silver 07 copper
                if priceDigits > 2 then
                    if string.sub(tostring(price), -2, -2) == '0' then
                        numberOfSpacesPriceBuffer = numberOfSpacesPriceBuffer + 1
                    end
                end

                --add space if zero in tens place because GetCoinTextureString won't show zero in 1 gold 03 silver
                if priceDigits > 4 then
                    if string.sub(tostring(price), -4, -4) == '0' then
                        numberOfSpacesPriceBuffer = numberOfSpacesPriceBuffer + 1
                    end
                end

                --if price contains any 1s, add a space cause they have small width
                for k in string.gmatch(tostring(price), "(1)") do
                    numberOfSpacesPriceBuffer = numberOfSpacesPriceBuffer + 1
                end
                local priceBuffer = string.rep(' ', numberOfSpacesPriceBuffer)
                --print('DEBUG>'..priceBuffer..'< priceBuffer')
                local limitedStock = ''
                if numAvailable > 0 then
                    limitedStock = ' \124cFF8A2BE2LIMITED STOCK of ' + numAvailable
                end

                if isPurchasable == true and numAvailable ~= 0 then
                    print('| '..i..' | '..priceBuffer..GetCoinTextureString(price)..' | '..name..' '..limitedStock)
                else
                    print('| '..i..' | '..priceBuffer..GetCoinTextureString(price)..' | '..name..' | \124cFFFF0000Unavailable for Purchase')
                end
            end
            CloseMerchant()
            print('|----------------------------------------------------------------')
            print('NoRepair: Autoclosed this vendor because they can repair.');
            print('NoRepair: Make a buy order using /nrb with the index and quantity');
            print('NoRepair: /nrb   <ITEM INDEX>   <QUANTITY>')
        end
    end
end

local event = CreateFrame("Frame")
event:SetScript("OnEvent", BuyItemsViaOrder);
event:RegisterEvent("MERCHANT_SHOW")

local function printHello (self, event)
    print('NoRepair '..version..' loaded - Gear is now one time use! see \124cFFFF0000/nrhelp')
end

local login = CreateFrame("Frame")
login:SetScript("OnEvent", printHello);
login:RegisterEvent("PLAYER_LOGIN")
