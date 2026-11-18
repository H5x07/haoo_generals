local shijie = fk.CreateSkill {
  name = "haoo__shijie",
}

Fk:loadTranslationTable {
  ["haoo__shijie"] = "矢节",
  [":haoo__shijie"] = "当你进入濒死状态时，你可弃置所有牌并选择一名得到过“谏”的角色，其须依次弃置X张牌；" ..
    "若其以此法失去所有牌，你与其各失去1点体力；若其以此法弃置的牌数小于X，你发动〖矢节〗" ..
    "（X为你本局游戏弃置的牌数）。",
  ["#haoo__shijie-invoke"] = "矢节：是否弃置所有牌并选择一名得到过“谏”的角色？",
  ["#haoo__shijie-choose"] = "矢节：请选择一名得到过“谏”的角色",
  ["#haoo__shijie-discard"] = "矢节：请依次弃置一张牌（%src 进入濒死，须弃置X张）",
  ["$haoo__shijie1"] = "如谏不从，吾自悬死于此！",
}

local DISCARD_COUNT_MARK = "haoo__sj_discards"

-- 矢节造成的自身体力流失不触发嵌套濒死（王累已在濒死流程中，由外层濒死结算继续）
shijie:addEffect(fk.BeforeHpChanged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shijie.name) and
      data.num < 0 and data.hpLostEvent and data.hpLostEvent.skillName == shijie.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.preventDying = true
  end,
})

-- 统计你本局游戏弃置的牌数（全局 refresh，确保获技前弃置的牌也会计入本局弃牌数）
shijie:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard and #move.moveInfo > 0 then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark(DISCARD_COUNT_MARK)
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        n = n + #move.moveInfo
      end
    end
    room:setPlayerMark(player, DISCARD_COUNT_MARK, n)
  end,
})

shijie:addEffect(fk.EnterDying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(shijie.name) or player.dead then
      return false
    end
    local totalDiscards = player:getMark(DISCARD_COUNT_MARK) + #player:getCardIds("he")
    if totalDiscards <= 0 then return false end
    return table.find(player.room.alive_players, function(p)
      return p ~= player and p:getMark("haoo__got_jian") > 0
    end) ~= nil
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shijie.name,
      prompt = "#haoo__shijie-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local processed = {}
    while not player.dead do
      local all = player:getCardIds("he")
      if #all > 0 then
        room:throwCard(all, shijie.name, player, player)
      end
      if player.dead then break end
      local X = player:getMark(DISCARD_COUNT_MARK)
      if X <= 0 then break end
      local candidates = table.filter(room.alive_players, function(p)
        return p ~= player and p:getMark("haoo__got_jian") > 0 and
          not table.contains(processed, p.id)
      end)
      if #candidates == 0 then break end
      local tos = room:askToChoosePlayers(player, {
        targets = candidates,
        min_num = 1,
        max_num = 1,
        skill_name = shijie.name,
        prompt = "#haoo__shijie-choose",
        cancelable = false,
      })
      if #tos == 0 then break end
      local to = tos[1]
      table.insert(processed, to.id)
      local hadCards = not to:isNude()
      local discarded = 0
      local lostAll = false
      for _ = 1, X do
        if to.dead or to:isNude() then break end
        local ret = room:askToDiscard(to, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = shijie.name,
          prompt = "#haoo__shijie-discard:" .. player.id,
          cancelable = false,
        })
        if #ret == 0 then break end
        discarded = discarded + #ret
        if to:isNude() then
          lostAll = true
        end
      end
      if hadCards and (lostAll or to:isNude()) then
        room:loseHp(player, 1, shijie.name)
        if not to.dead then
          room:loseHp(to, 1, shijie.name)
        end
      end
      if discarded >= X then break end
    end
  end,
})

return shijie
