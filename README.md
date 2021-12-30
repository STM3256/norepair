# NoRepair

## WOW Game version
Classic (bcc Burning Crusade Classic). There are other versions of this addon.

## Summary
This is an Addon for SOM wow to disable repairing for the ephemeral achievement in classic hard core. See www.classichc.net for details on the achievement.
All gear is now one-time use.

## Requirements/Dependencies
* None

## Installation
Put the NoRepair folder containing main.lua and norepair.toc files into the Interface\AddOns folder.

## Changelog

### Version 2.2 2021-12-29
Added on login message
Cleaned up messages
Added some color

### Version 2.0 2021-12-28
Added slash commands for:
1. Help             = '/nr', '/norepair', '/norepairhelp'
2. Create Buy order = '/nrb', '/norepairbuy'
3. Check Buy order  = '/nrbo', '/norepairbuyorder'
4. Cancel Buy order = '/nrbc', '/norepairbuycancel'

Added concept of "buy orders". A buy order can be placed by executing a slash command. Now you can purchase specific supplies from a vendor that can repair without ever seeing the repair button.

### Version 1.0 2021-12-27
This version will auto-close any vendor that can repair. Interactions with other addons are not tested, and any that "auto-repair" might execute their script first.
