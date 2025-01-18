-- CREDITS https://github.com/logan-mcgee/discord_perms

-- REWORKED BY @silkiauskas, Cache system, error handling, code structure, better performance

local Config = Config or {}
local FormattedToken = "Bot " .. Config.DiscordToken
local cachedMembers = {}
local CACHE_DURATION = 300

local DiscordRequest = function(method, endpoint, payload)
    local response = promise.new()

    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(statusCode, resultData, resultHeaders)
        response:resolve({
            data = resultData and json.decode(resultData) or {},
            code = statusCode,
            headers = resultHeaders
        })
    end, method, payload and json.encode(payload) or "", {
        ["Content-Type"] = "application/json",
        ["Authorization"] = FormattedToken
    })

    return Citizen.Await(response)
end

local GetDiscordId = function(source)
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if id:match("^discord:") then
            return id:gsub("discord:", "")
        end
    end
    return nil
end

local SetCachedMember = function(discordId, memberData)
    cachedMembers[discordId] = {
        data = memberData,
        timestamp = os.time()
    }
end

local GetCachedMember = function(discordId)
    local cached = cachedMembers[discordId]
    if cached and (os.time() - cached.timestamp) < CACHE_DURATION then
        return cached.data
    end
    return nil
end

local GetMemberData = function(source)
    local discordId = GetDiscordId(source)
    if not discordId then
        return false, "Missing Discord identifier"
    end

    local cached = GetCachedMember(discordId)
    if cached then
        return true, cached
    end

    local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
    local response = DiscordRequest("GET", endpoint, nil)

    if response.code == 200 and response.data then
        SetCachedMember(discordId, response.data)
        return true, response.data
    end

    return false, "Failed to fetch member data: " .. (response.data.message or "Unknown error")
end

GetRoles = function(source)
    local success, result = GetMemberData(source)
    if success then
        return result.roles
    end
    print("Error getting roles:", result)
    return false
end

IsRolePresent = function(source, role)
    local roleId = type(role) == "number" and tostring(role) or Config.Roles[role]
    if not roleId then
        return false, "Invalid role specified"
    end

    local success, memberData = GetMemberData(source)
    if not success then
        return false, memberData
    end

    for _, userRole in pairs(memberData.roles) do
        if userRole == roleId then
            return true
        end
    end

    return false
end

CreateThread(function()
    local response = DiscordRequest("GET", "guilds/" .. Config.GuildId, nil)
    if response.code == 200 then
        local guild = response.data
        print(string.format("Permission system initialized for guild: %s (%s)", guild.name, guild.id))
    else
        print("Failed to initialize permission system:", response.data.message or "Unknown error")
    end
end)

exports('GetRoles', GetRoles)
exports('IsRolePresent', IsRolePresent)
