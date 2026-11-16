local ziyuan = fk.CreateSkill {
  name = "ts__ziyuan",
}

Fk:loadTranslationTable {
  ["ts__ziyuan"] = "资源",
  [":ts__ziyuan"] = "当你因其他技能获得牌时，你可以摸双倍的牌，然后将其中一半交给一名其他角色。",

  ["#ts__ziyuan-ask"] = "资源：是否摸%arg张牌，然后将一半交给其他角色？",
  ["#ts__ziyuan-give"] = "资源：选择要交给其他角色的牌",
  ["#ts__ziyuan-target"] = "资源：选择获得这些牌的角色",
}

local function is_player_skill_gain(name)
  local sk = Fk.skills[name]
  if not sk or sk.cardSkill or sk:isInstanceOf(CardSkill) then return false end
  local skel = sk:getSkeleton()
  return not (skel and type(skel.attached_equip) == "string")
end

-- 只统计“因其他技能获得”的牌：排除卡牌效果、装备技能、摸牌及本技能的移动
local function count_gain(data, player)
  local n = 0
  for _, move in ipairs(data) do
    if move.to == player and move.toArea == Card.PlayerHand and move.skillName and
      move.skillName ~= ziyuan.name and move.moveReason ~= fk.ReasonDraw and
      is_player_skill_gain(move.skillName) then
      n = n + #move.moveInfo
    end
  end
  return n
end

ziyuan:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ziyuan.name) and count_gain(data, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local n = count_gain(data, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = ziyuan.name,
      prompt = "#ts__ziyuan-ask:::" .. (2 * n),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = count_gain(data, player)
    if n <= 0 then return end

    local drawn = player:drawCards(2 * n, ziyuan.name)
    drawn = table.filter(drawn, function(id)
      return room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player
    end)

    local others = room:getOtherPlayers(player, false)
    if player.dead or #others == 0 or #drawn == 0 then return end

    local give = math.min(n, #drawn)
    local cards = room:askToChooseCards(player, {
      target = player,
      flag = { card_data = { { "$Hand", drawn } }, visible_data = {} },
      min = give,
      max = give,
      skill_name = ziyuan.name,
      prompt = "#ts__ziyuan-give",
      cancelable = false,
    })
    if #cards == 0 then return end

    local to = room:askToChoosePlayers(player, {
      targets = others,
      min_num = 1,
      max_num = 1,
      skill_name = ziyuan.name,
      prompt = "#ts__ziyuan-target",
      cancelable = false,
    })
    if #to == 0 then return end

    room:moveCardTo(cards, Player.Hand, to[1], fk.ReasonGive, ziyuan.name, nil, false, player)
  end,
})

return ziyuan
