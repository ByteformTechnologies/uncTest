-- sUNC/UNC Capability + Optional Stress Test
-- Made by pveps | https://pveps.xyz

local apiGroups = {
    ["CLOSURES"] = {
        "hookfunction", "hookmetamethod", "newcclosure", "iscclosure", "islclosure",
        "isexecutorclosure", "clonefunction", "getfunctionhash"
    },
    ["DEBUG"] = {
        "debug.getconstants", "debug.getconstant", "debug.setconstant",
        "debug.getupvalues", "debug.getupvalue", "debug.setupvalue",
        "debug.getstack", "debug.setstack", "debug.getprotos", "debug.getproto"
    },
    ["CRYPTOGRAPHY"] = {
        "crypt.base64encode", "crypt.base64decode"
    },
    ["DRAWING"] = {
        "Drawing", "Drawing.new", "cleardrawcache",
        "getrenderproperty", "setrenderproperty", "isrenderobj"
    },
    ["ENVIRONMENT"] = {
        "getgenv", "getrenv", "getgc", "filtergc"
    },
    ["FILESYSTEM"] = {
        "appendfile", "writefile", "readfile", "listfiles",
        "isfile", "delfile", "loadfile", "makefolder"
    }
}

-- Utility to resolve nested API paths like 'debug.getupvalue'
local function resolvePath(path)
    if not path:find("%.") then
        return getfenv()[path]
    end
    local parts = {}
    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    local base = getfenv()[parts[1]]
    for i = 2, #parts do
        base = base and base[parts[i]]
    end
    return base
end

-- === [1] CAPABILITY TEST ===
local total, passed = 0, 0
print("🔍 Checking sUNC/UNC capability...\n")

for category, funcs in pairs(apiGroups) do
    print("─── " .. category .. " ───")
    for _, name in ipairs(funcs) do
        total += 1
        local fn = resolvePath(name)
        local exists = typeof(fn) == "function" or typeof(fn) == "table"
        if exists then
            passed += 1
            print("✅ " .. name)
        else
            print("❌ " .. name)
        end
    end
end

print(("\n✅ Finished Capability Test: %d / %d supported\n"):format(passed, total))

-- === [2] STRESS TEST (safe functions only) ===
local stressIterations = 10000
local stressTargets = {
    "getgenv", "getrenv", "getgc", "iscclosure", "islclosure", "newcclosure"
}

print("🚀 Beginning stress test on selected safe APIs...")
local stressStart = tick()
for _, funcName in ipairs(stressTargets) do
    local func = resolvePath(funcName)
    if typeof(func) == "function" then
        local ok, msg = pcall(function()
            for i = 1, stressIterations do
                pcall(func)
            end
        end)
        if ok then
            local timeTaken = tick() - stressStart
            print(("✅ %s: %d iterations (%.2f ms total)"):format(funcName, stressIterations, timeTaken * 1000))
        else
            print("⚠️ " .. funcName .. " failed during stress test: " .. tostring(msg))
        end
    else
        print("❌ " .. funcName .. " not available for stress test")
    end
end
local stressEnd = tick()
local totalStressTime = stressEnd - stressStart
print(("\n📈 Stress test completed in %.2f seconds\n"):format(totalStressTime))

-- Attribution
print("🔧 Made by pveps | https://pveps.xyz")
