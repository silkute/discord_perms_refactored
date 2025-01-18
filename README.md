# Discord_perms REFACTORED by discord: @silkiauskas
## FiveM Discord Role Verification System

A lightweight and efficient FiveM resource for Discord role-based permissions management.

## Features

- 🚀 Efficient caching system to minimize API calls
- 🛡️ Better error handling
- 🔄 Cache system for better performance
- 🔌 Exported functions for external resource usage


## Installation

1. Create a `config.lua` file and add your configuration:

```lua
Config = {}
Config.DiscordToken = 'your-bot-token'
Config.GuildId = 'your-guild-id'
Config.Roles = {
    admin = "role-id-here",
    moderator = "role-id-here",
    vip = "role-id-here"
}
```

2. Add the resource to your `server.cfg`:
```cfg
ensure discord_roles
```

## Usage

### Checking for Roles

```lua
-- Check if player has a specific role
local hasRole = exports.discord_roles:IsRolePresent(source, "admin")
if hasRole then
    -- Do something for admins
end

-- Get all roles for a player
local roles = exports.discord_roles:GetRoles(source)
if roles then
    for _, roleId in pairs(roles) do
        -- Process roles
    end
end
```

### Integrating with Other Resources

```lua
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    
    local hasRole = exports.discord_roles:IsRolePresent(source, "vip")
    if not hasRole then
        deferrals.done("You need VIP role to join this server!")
        return
    end
    
    deferrals.done()
end)
```

### Caching System
- Member data is cached for 5 minutes by default
- Automatically refreshes expired cache entries
- Significantly reduces API calls to Discord
- Cache duration can be modified via `CACHE_DURATION` variable

## Credits

Orginal creators no longer maintained this resource (GITHUB: vecchiotom, logan-mcgee) so I refactored discord: @silkiauskas, github: silkute

You can use this and contribute as well, the code is still not the best, but just please don't think of reselling this


OLD CREATORS README: 
# discord_perms
Link discord roles to in game permission thingies

# This resource is unstable and no longer maintained. if you want a better, more reliable version, check out [the new solution](https://forum.cfx.re/t/discordroles-a-proper-attempt-this-time/1579427)


