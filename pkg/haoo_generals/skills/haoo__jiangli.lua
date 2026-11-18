local jiangli = fk.CreateSkill {
  name = "haoo__jiangli",
  related_skills = { "haoo__shenxu" },
}

Fk:loadTranslationTable {
  ["haoo__jiangli"] = "奖励",
  [":haoo__jiangli"] = "你使用牌指定目标或成为牌的目标后，可以失去1点体力并摸一张牌，然后令此牌无效。" ..
    "若你以此法进入濒死状态，你获得【肾虚】。",
  ["#haoo__jiangli-invoke"] = "奖励：你可以失去1点体力并摸一张牌，令此牌无效",
}

-- 每张牌的一次使用只询问一次，询问过（无论是否发动）即不再询问
local HANDLED = "__haoo_jiangli_done"

local function nullifyWholeCard(use)
  use.nullifiedTargets = use.nullifiedTargets or {}
  for _, to in ipairs(use.tos or Util.DummyTable) do
    table.insertIfNeed(use.nullifiedTargets, to)
  end
end

local function askInvoke(room, player, data)
  data.use[HANDLED] = true
  return room:askToSkillInvoke(player, {
    skill_name = jiangli.name,
    prompt = "#haoo__jiangli-invoke",
  })
end

local function executeEffect(room, player, use)
  room:loseHp(player, 1, jiangli.name)
  local dyingEvents = room.logic:getEventsByRule(GameEvent.Dying, 1, function(e)
    return e.data.who == player and e.data.hpLost and e.data.hpLost.skillName == jiangli.name
  end)
  if not player.dead then
    player:drawCards(1, jiangli.name)
  end
  nullifyWholeCard(use)
  if not player.dead and #dyingEvents > 0 and not player:hasSkill("haoo__shenxu", true) then
    room:handleAddLoseSkills(player, "haoo__shenxu", jiangli.name)
  end
end

jiangli:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiangli.name) and not player.dead and
      data.use and not data.use[HANDLED] and data.to and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    return askInvoke(player.room, player, data)
  end,
  on_use = function(self, event, target, player, data)
    executeEffect(player.room, player, data.use)
  end,
})

jiangli:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiangli.name) and not player.dead and
      data.use and not data.use[HANDLED]
  end,
  on_cost = function(self, event, target, player, data)
    return askInvoke(player.room, player, data)
  end,
  on_use = function(self, event, target, player, data)
    executeEffect(player.room, player, data.use)
  end,
})

return jiangli
