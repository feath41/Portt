--[[
    ╔══════════════════════════════════════════════════════════╗
    ║  FischTes Public Loader                                  ║
    ║  Author : Rifqy                                          ║
    ║  Base   : https://porttiii.vercel.app/loader/shield/     ║
    ║  Source : github.com/KAN-FISCH/FischTes                  ║
    ║  Desc   : Loader publik — fetch payload dari Vercel.     ║
    ║           Jangan taruh logic utama di sini.              ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- Tunggu game siap
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- =========================================================
-- KONFIGURASI
-- =========================================================
local BASE_URL = "https://porttiii.vercel.app/loader/shield/"

-- Urutan load: library dulu, baru main
local FILES_ORDER = {
    "ShielD_UILib.lua",
    "Config.lua",
    "GUIENC.lua",
    "Main_RS.lua",
}

-- Daftar module manual (kalau manifest.json nggak ada)
-- Isi sesuai file yang ada di folder Modules/ kamu, Rifqy
local MODULES_MANUAL = {
    "AntiAFK.lua",
    "AreaTP.lua",
    "AutoBuyBait.lua",
    "AutoBuyRod.lua",
    "AutoCast.lua",
    "AutoConfig.lua",
    "AutoCosmic.lua",
    "AutoHop.lua",
    "AutoMine.lua",
    "AutoMinigames.lua",
    "AutoPotion.lua",
    "AutoQuest.lua",
    "AutoQuestShady.lua",
    "AutoReel.lua",
    -- "AutoReel.obfuscated.lua",
    "AutoSell.lua",
    "AutoShake.lua",
    -- "AutoShake.obfuscated.lua",
    "AutoStorage.lua",
    "AutoTrade.lua",
    "Autos.lua",
    "DisableOxygen.lua",
    "ESP.lua",
    "Exclusive.lua",
    "InstantBobber.lua",
    "MiscFeatures.lua",
    "MiscFishing.lua",
    "PerfectCatch.lua",
    "Shop.lua",
    "TeleportArea.lua",
    "TeleportNPC.lua",
    "TeleportZone.lua",
    "Utils.lua",
    "WalkSpeed.lua",
}

-- =========================================================
-- UTIL
-- =========================================================
local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local StarterGui  = game:GetService("StarterGui")
local LP          = Players.LocalPlayer

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text or "",
            Duration = dur or 4,
        })
    end)
end

local function fetch(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok or type(res) ~= "string" or #res < 5 then
        return nil, res
    end
    return res
end

local function joinUrl(...)
    local parts = { ... }
    return table.concat(parts, "")
end

-- =========================================================
-- DETEKSI EXECUTOR & HWID
-- =========================================================
local function detectExecutor()
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then
            name = tostring(identifyexecutor())
        elseif getexecutorname then
            name = tostring(getexecutorname())
        end
    end)
    return name
end

local EXEC_NAME = detectExecutor()
local HWID = ""
pcall(function()
    if gethwid then
        HWID = tostring(gethwid())
    elseif game:GetService("RbxAnalyticsService") then
        HWID = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    end
end)

-- =========================================================
-- CACHE GLOBAL
-- =========================================================
_G.FischTes = _G.FischTes or {}
_G.FischTes.Cache    = _G.FischTes.Cache or {}
_G.FischTes.Modules  = _G.FischTes.Modules or {}
_G.FischTes.BASE_URL = BASE_URL
_G.FischTes.EXEC     = EXEC_NAME
_G.FischTes.HWID     = HWID

-- =========================================================
-- LOADER CORE
-- =========================================================
local function loadFile(path, isModule)
    local url = joinUrl(BASE_URL, path, "?t=", tostring(os.time()))
    local code, err = fetch(url)

    if not code then
        warn("[FischTes] Fetch failed:", path, err)
        return false, "fetch"
    end

    -- Deteksi HTML (Vercel 404 page) — bukan Lua
    if code:sub(1, 1) == "<" or code:find("<!DOCTYPE") or code:find("<html") then
        warn("[FischTes] Bukan Lua (kemungkinan 404/HTML):", path)
        return false, "notlua"
    end

    _G.FischTes.Cache[path] = code

    local fn, compileErr = loadstring(code, "@" .. path)
    if not fn then
        warn("[FischTes] Compile error:", path, compileErr)
        return false, "compile"
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[FischTes] Runtime error:", path, runErr)
        return false, "runtime"
    end

    if isModule then
        table.insert(_G.FischTes.Modules, path)
    end

    return true
end

-- =========================================================
-- AUTO-DISCOVER MODULES
-- =========================================================
local function discoverModules()
    local manifestUrl = joinUrl(BASE_URL, "Modules/manifest.json?t=", tostring(os.time()))
    local ok, raw = pcall(function() return game:HttpGet(manifestUrl, true) end)

    if ok and type(raw) == "string" and #raw > 2 and raw:sub(1,1) ~= "<" then
        local decOk, list = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if decOk and type(list) == "table" then
            return list
        end
    end

    if #MODULES_MANUAL > 0 then
        return MODULES_MANUAL
    end

    return {}
end

-- =========================================================
-- MAIN
-- =========================================================
notify("FischTes", "Loading... [" .. EXEC_NAME .. "]", 3)

for _, file in ipairs(FILES_ORDER) do
    -- Sisipkan modules SEBELUM Main_RS.lua
    if file == "Main_RS.lua" then
        local modules = discoverModules()
        if #modules > 0 then
            notify("FischTes", "Loading " .. #modules .. " modules...", 2)
            for _, mod in ipairs(modules) do
                local modPath = "Modules/" .. mod
                local okMod = loadFile(modPath, true)
                if not okMod then
                    warn("[FischTes] Module gagal:", mod)
                end
            end
        end
    end

    local ok = loadFile(file, false)
    if not ok then
        notify("FischTes", "Gagal load: " .. file, 5)
        return
    end
end

notify("FischTes", "Loaded! " .. #_G.FischTes.Modules .. " module aktif.", 4)