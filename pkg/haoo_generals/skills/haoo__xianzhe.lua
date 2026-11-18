local xianzhe = fk.CreateSkill {
  name = "haoo__xianzhe",
}

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
  ["haoo__xianzhe"] = "贤者",
  [":haoo__xianzhe"] = "结束阶段，若你本回合未翻面，你可以翻面，摸三张牌并获得2点蓄力点。",
  ["#haoo__xianzhe-invoke"] = "贤者：你可以翻面，摸三张牌并获得2点蓄力点",
}

xianzhe:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianzhe.name) and
      player.phase == Player.Finish and player:getMark("haoo__xz_turned-turn") == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xianzhe.name,
      prompt = "#haoo__xianzhe-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:turnOver()
    if not player.dead then
      player:drawCards(3, xianzhe.name)
    end
    if not player.dead then
      U.skillCharged(player, 2)
    end
  end,
})

-- 记录本回合内是否翻面过（使用全局 refresh，防止回合内曾失技或后获技时漏记，且不触发无意义发动事件）
xianzhe:addEffect(fk.TurnedOver, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player.room:getCurrent() == player and
      player:getMark("haoo__xz_turned-turn") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "haoo__xz_turned-turn", 1)
  end,
})

return xianzhe
