-- 洪楷南（haoo__hongkainan2）的客户端表现钩子。
-- 「和梦」是否在武将牌上由隐藏标记 haoo__hemeng_drunk 表达（见 haoo__tongnan.lua）。
-- 仅在玩家详情读取 Ltk.getPlayerSkills 时按具体角色的标记过滤 related_skills，
-- 避免直接篡改全局骨架 SkillSkeleton.related_skills 影响武将一览或其他角色。

local MARK = "haoo__hemeng_drunk"
local HOST_SKILL = "haoo__tongnan"
local RELATED_SKILL = "haoo__hemeng"
local HOST_GENERAL = "haoo__hongkainan2"

local function hookClientUtil(modName)
  local ok, util = pcall(require, modName)
  if not ok or type(util) ~= "table" or type(util.getPlayerSkills) ~= "function" then
    return false
  end
  if util.haoo__hongkainan_client then
    return true
  end
  util.haoo__hongkainan_client = true

  local origGetPlayerSkills = util.getPlayerSkills
  util.getPlayerSkills = function(self, id)
    local skills = origGetPlayerSkills(self, id)
    local p = ClientInstance and ClientInstance:getPlayerById(id)
    if p and p:getMark(MARK) > 0 then
      for _, entry in ipairs(skills) do
        if entry.orig_name == HOST_SKILL and type(entry.related_skills) == "table" then
          entry.related_skills = table.filter(entry.related_skills, function(s)
            return s ~= RELATED_SKILL
          end)
        end
      end
    end
    return skills
  end
  return true
end

local function setRelated(present)
  local skel = Fk.skill_skels[HOST_SKILL]
  if not skel then return end
  skel.related_skills = skel.related_skills or {}
  local exists = table.contains(skel.related_skills, RELATED_SKILL)
  if present and not exists then
    table.insert(skel.related_skills, RELATED_SKILL)
  elseif not present and exists then
    skel.related_skills = table.filter(skel.related_skills, function(s)
      return s ~= RELATED_SKILL
    end)
  end
end

return function(base)
  local utilHooked = hookClientUtil("packages.freekill-core.ltk.client.util")
  utilHooked = hookClientUtil("ltk.client.util") or utilHooked
  if utilHooked or not base then return end

  if base.haoo__hongkainan_client then return end
  base.haoo__hongkainan_client = true

  local notifyUI = base.notifyUI
  base.notifyUI = function(self, command, data)
    -- 仅在无法挂接 client.util 时的兜底：主将或副将分到洪楷南 / 对局结束时恢复〖和梦〗
    if command == "PropertyUpdate" and
      (data[2] == "general" or data[2] == "deputyGeneral") and data[3] == HOST_GENERAL then
      setRelated(true)
    elseif command == "GameOver" then
      setRelated(true)
    end
    return notifyUI(self, command, data)
  end

  -- 兜底：喝掉 / 回归的标记同步
  local setMark = base.handleSetPlayerMark
  base.handleSetPlayerMark = function(self, data)
    local result = table.pack(setMark(self, data))
    if data[2] == MARK then
      setRelated((data[3] or 0) == 0)
    end
    return table.unpack(result, 1, result.n)
  end
end
