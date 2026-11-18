local xuanjian = fk.CreateSkill {
  name = "haoo__xuanjian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["haoo__xuanjian"] = "悬剑",
  [":haoo__xuanjian"] = "锁定技，摸牌阶段，你多摸一张牌。出牌阶段开始时，交给任意名其他角色各一张牌（称为“谏”），" ..
    "其使用其中的装备牌。得到“谏”的角色回合结束时，若“谏”不因弃置进入弃牌堆，你可摸两张牌并令其回复1点体力。" ..
    "否则，其弃置“谏”并失去1点体力。每回合结束时，你弃置一张牌。",
  ["#haoo__xuanjian-give"] = "悬剑：请交给其他角色一张牌（称为“谏”）",
  ["#haoo__xuanjian-discard"] = "悬剑：每回合结束时，你须弃置一张牌",
  ["#haoo__xuanjian-reward"] = "悬剑：是否摸两张牌并令其回复1点体力？",
  ["@haoo__jian"] = "谏",
}

local JIAN_MARK = "@haoo__jian" -- @开头=卡面可见标记，显示为“谏”
local TO_MARK = "haoo__jian_to" -- 无@=隐藏标记，值为得到“谏”的角色的 id
local DISCARD_MARK = "haoo__jian_discarded" -- 无@=隐藏标记：0=未进弃牌堆，1=因弃置进弃牌堆，2=非因弃置进弃牌堆
local GOT_MARK = "haoo__got_jian" -- 无@=隐藏玩家标记，“得到过谏”，供矢节查询

local function markJian(room, id, toId)
  local card = Fk:getCardById(id, true)
  room:setCardMark(card, JIAN_MARK, 1)
  room:setCardMark(card, TO_MARK, toId)
  room:setCardMark(card, DISCARD_MARK, 0)
end

local function clearJian(room, id)
  local card = Fk:getCardById(id, true)
  room:setCardMark(card, JIAN_MARK, 0)
  room:setCardMark(card, TO_MARK, 0)
  room:setCardMark(card, DISCARD_MARK, 0)
end

-- 找出指定得到者（或 receiverId 为 nil 时全房间）名下所有未结算的“谏”
local function findJianCards(room, receiverId)
  local found = {}
  local seen = {}
  local function checkList(ids)
    for _, id in ipairs(table.simpleClone(ids)) do
      if not seen[id] then
        local card = Fk:getCardById(id, true)
        if card:getMark(JIAN_MARK) > 0 and (receiverId == nil or card:getMark(TO_MARK) == receiverId) then
          seen[id] = true
          table.insert(found, id)
        end
      end
    end
  end
  checkList(room.discard_pile)
  checkList(room.draw_pile)
  checkList(room.void)
  for _, p in ipairs(room.players) do
    checkList(p:getCardIds("hej"))
    for _, pile in pairs(p.special_cards or Util.DummyTable) do
      checkList(pile)
    end
  end
  return found
end

-- 判定一张“谏”在得到者回合结束时的结算分支：
-- "reward" 不因弃置进入弃牌堆，或装备/判定区中；"discard_penalty" 因弃置进入弃牌堆；
-- "hand_penalty" 仍在得到者手里；nil 在其他角色手里或未定牌区中，暂不结算
local function judgeJian(room, id, receiver)
  local card = Fk:getCardById(id, true)
  local discardState = card:getMark(DISCARD_MARK)
  if discardState == 1 then
    return "discard_penalty"
  elseif discardState == 2 then
    return "reward"
  end
  for _, p in ipairs(room.alive_players) do
    if table.contains(p:getCardIds("e"), id) or table.contains(p:getCardIds("j"), id) then
      return "reward"
    end
    if p.id == receiver.id and table.contains(p:getCardIds("h"), id) then
      return "hand_penalty"
    end
  end
  return nil
end

-- 无人持有【悬剑】时清理残留的“谏”标记
xuanjian:addLoseEffect(function(self, player, is_death)
  local room = player.room
  if table.every(room.alive_players, function(p)
    return not p:hasSkill(xuanjian.name, true)
  end) then
    for _, id in ipairs(findJianCards(room, nil)) do
      clearJian(room, id)
    end
  end
end)

-- 摸牌阶段，你多摸一张牌
xuanjian:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xuanjian.name) and data.n > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

-- 记录“谏”首次进入弃牌堆时是否因弃置，并锁定结论防止洗牌或捡牌覆写
xuanjian:addEffect(fk.AfterCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId, true)
          if card:getMark(JIAN_MARK) > 0 and card:getMark(DISCARD_MARK) == 0 then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId, true)
          if card:getMark(JIAN_MARK) > 0 and card:getMark(DISCARD_MARK) == 0 then
            room:setCardMark(card, DISCARD_MARK, move.moveReason == fk.ReasonDiscard and 1 or 2)
          end
        end
      end
    end
  end,
})

-- 得到“谏”的角色阵亡后清理其名下未结算的“谏”标记
xuanjian:addEffect(fk.Deathed, {
  global = true,
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target and player == player.room.alive_players[1] and
      #findJianCards(player.room, target.id) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(findJianCards(room, target.id)) do
      clearJian(room, id)
    end
  end,
})

-- 出牌阶段开始时：交给任意名其他角色各一张牌
xuanjian:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xuanjian.name) and
      player.phase == Player.Play and not player:isNude() and #player.room.alive_players > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local chosenIds = {}
    local first = true
    while not player.dead and not player:isNude() do
      local candidates = table.filter(room.alive_players, function(p)
        return p ~= player and not table.contains(chosenIds, p.id)
      end)
      if #candidates == 0 then break end
      local tos, cards = room:askToChooseCardsAndPlayers(player, {
        min_num = 1,
        max_num = 1,
        min_card_num = 1,
        max_card_num = 1,
        targets = candidates,
        pattern = ".",
        skill_name = xuanjian.name,
        prompt = "#haoo__xuanjian-give",
        cancelable = not first,
      })
      if #tos == 0 or #cards == 0 then break end
      first = false
      local to = tos[1]
      table.insert(chosenIds, to.id)
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, xuanjian.name, nil, false, player)
      room:setPlayerMark(to, GOT_MARK, 1)
      for _, id in ipairs(cards) do
        markJian(room, id, to.id)
        -- “谏”为装备牌时，其立即使用之
        if not to.dead and table.contains(to:getCardIds("h"), id) then
          local card = Fk:getCardById(id)
          if card.type == Card.TypeEquip and to:canUse(card) and to:canUseTo(card, to) then
            room:useCard{
              from = to,
              tos = { to },
              card = card,
            }
          end
        end
      end
    end
  end,
})

-- 得到“谏”的角色回合结束时：结算其名下的“谏”
xuanjian:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    if not target or target.dead then return false end
    if not player:hasSkill(xuanjian.name) or player.dead then return false end
    for _, id in ipairs(findJianCards(player.room, target.id)) do
      if judgeJian(player.room, id, target) ~= nil then
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(findJianCards(room, target.id)) do
      if player.dead or not player:hasSkill(xuanjian.name) or target.dead then break end
      local verdict = judgeJian(room, id, target)
      if verdict == "reward" then
        if room:askToSkillInvoke(player, {
          skill_name = xuanjian.name,
          prompt = "#haoo__xuanjian-reward",
        }) then
          player:drawCards(2, xuanjian.name)
          if not target.dead and target:isWounded() then
            room:recover{
              who = target,
              num = 1,
              recoverBy = player,
              skillName = xuanjian.name,
            }
          end
        end
        clearJian(room, id)
      elseif verdict == "discard_penalty" then
        clearJian(room, id)
        room:loseHp(target, 1, xuanjian.name)
      elseif verdict == "hand_penalty" then
        clearJian(room, id)
        room:throwCard(id, xuanjian.name, target, target)
        if not target.dead then
          room:loseHp(target, 1, xuanjian.name)
        end
      elseif table.contains(room.void, id) then
        clearJian(room, id)
      end
    end
  end,
})

-- 每回合结束时：你弃置一张牌
xuanjian:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xuanjian.name) and not player.dead and not player:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xuanjian.name,
      prompt = "#haoo__xuanjian-discard",
      cancelable = false,
    })
  end,
})

return xuanjian
