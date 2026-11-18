local shenkun = fk.CreateSkill {
  name = "haoo__shenkun",
  tags = { Skill.Charge },
  dynamic_desc = function(self, player, lang)
    if not player then return "haoo__shenkun" end
    local d = player:getMark("haoo__sk_deleted")
    if d >= 1 and d <= 4 then
      return "haoo__shenkun_d" .. d
    end
    return "haoo__shenkun"
  end,
}

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
  ["haoo__shenkun"] = "神坤",
  [":haoo__shenkun"] = "蓄力技（2/4），①出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。" ..
    "②锁定技，当你于此回合内减少蓄力点后，若以下剩余选项数不小于X（X为你于此回合内累计减少的蓄力点数），" ..
    "你执行第X个选项：1.摸一张牌；2.弃置两张牌（不足则全弃）；3.失去1点体力；" ..
    "4.你于此回合内使用的下一张【杀】或【决斗】的伤害值基数+1，删去第一个选项，〖神坤〗于此回合内无效。",
  [":haoo__shenkun_d1"] = "蓄力技（2/4），①出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。" ..
    "②锁定技，当你于此回合内减少蓄力点后，若以下剩余选项数不小于X（X为你于此回合内累计减少的蓄力点数），" ..
    "你执行第X个选项：1.弃置两张牌（不足则全弃）；2.失去1点体力；" ..
    "3.你于此回合内使用的下一张【杀】或【决斗】的伤害值基数+1，删去第一个选项，〖神坤〗于此回合内无效。",
  [":haoo__shenkun_d2"] = "蓄力技（2/4），①出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。" ..
    "②锁定技，当你于此回合内减少蓄力点后，若以下剩余选项数不小于X（X为你于此回合内累计减少的蓄力点数），" ..
    "你执行第X个选项：1.失去1点体力；" ..
    "2.你于此回合内使用的下一张【杀】或【决斗】的伤害值基数+1，删去第一个选项，〖神坤〗于此回合内无效。",
  [":haoo__shenkun_d3"] = "蓄力技（2/4），①出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。" ..
    "②锁定技，当你于此回合内减少蓄力点后，若以下剩余选项数不小于X（X为你于此回合内累计减少的蓄力点数），" ..
    "你执行第X个选项：1.你于此回合内使用的下一张【杀】或【决斗】的伤害值基数+1，删去第一个选项，〖神坤〗于此回合内无效。",
  [":haoo__shenkun_d4"] = "蓄力技（2/4），出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。",
  ["#haoo__shenkun-active"] = "神坤：你可以减少1点蓄力点，视为使用一张无次数限制的普【杀】或【决斗】",
  ["#haoo__shenkun-discard"] = "神坤：你须弃置两张牌",
}

shenkun:addAcquireEffect(function(self, player)
  U.skillCharged(player, 2, 4)
end)

shenkun:addLoseEffect(function(self, player)
  U.skillCharged(player, -2, -4)
  if player.room then
    player.room:setPlayerMark(player, "haoo__sk_deleted", 0)
    player.room:setPlayerMark(player, "haoo__sk_buff-turn", 0)
    player.room:setPlayerMark(player, "haoo__sk_disabled-turn", 0)
  end
end)

shenkun:addEffect("active", {
  anim_type = "offensive",
  prompt = "#haoo__shenkun-active",
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  can_use = function(self, player)
    if player:getMark("skill_charge") <= 0 or player:getMark("haoo__sk_disabled-turn") > 0 then
      return false
    end
    local slash = Fk:cloneCard("slash")
    slash.skillName = shenkun.name
    local duel = Fk:cloneCard("duel")
    duel.skillName = shenkun.name
    return not (player:prohibitUse(slash) and player:prohibitUse(duel))
  end,
  interaction = function(self, player)
    local all_choices = { "slash", "duel" }
    local choices = table.filter(all_choices, function(name)
      local card = Fk:cloneCard(name)
      card.skillName = shenkun.name
      return not player:prohibitUse(card)
    end)
    if #choices == 0 then return nil end
    return UI.CardNameBox { choices = choices, all_choices = all_choices }
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local name = self.interaction.data or "slash"
    local card = Fk:cloneCard(name)
    card.skillName = shenkun.name
    -- bypass_times 允许连续视为使用【杀】，实际 useVirtualCard 不传 extra=true 以计入出牌阶段使用【杀】次数
    return player:canUseTo(card, to_select, { bypass_times = true })
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    U.skillCharged(player, -1)
    local name = self.interaction.data
    if name ~= "slash" and name ~= "duel" then
      name = room:askToChoice(player, {
        choices = { "slash", "duel" },
        skill_name = shenkun.name,
      })
    end
    if not player.dead and to and not to.dead then
      room:useVirtualCard(name, nil, player, to, shenkun.name)
    end
  end,
})

-- 回合内累计减少蓄力点后，按当前剩余选项依次结算（原第1/2/3/4档：摸1/弃2/失1/加伤+删首项+本回合失效）
shenkun:addEffect(U.SkillChargeChanged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shenkun.name) and
      data.num < 0 and player.room:getCurrent() == player and
      player:getMark("haoo__sk_disabled-turn") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local old = player:getMark("haoo__sk_spent-turn")
    local spent = old - data.num
    room:setPlayerMark(player, "haoo__sk_spent-turn", spent)
    for step = old + 1, spent do
      if player.dead then break end
      local deleted = player:getMark("haoo__sk_deleted")
      local tier = step + deleted
      if tier > 4 then break end
      if tier == 1 then
        player:drawCards(1, shenkun.name)
      elseif tier == 2 then
        local n = #player:getCardIds("he")
        if n > 0 then
          room:askToDiscard(player, {
            min_num = math.min(2, n),
            max_num = math.min(2, n),
            include_equip = true,
            skill_name = shenkun.name,
            prompt = "#haoo__shenkun-discard",
            cancelable = false,
          })
        end
      elseif tier == 3 then
        room:loseHp(player, 1, shenkun.name)
      elseif tier == 4 then
        room:setPlayerMark(player, "haoo__sk_buff-turn", 1)
        room:setPlayerMark(player, "haoo__sk_deleted", deleted + 1)
        room:setPlayerMark(player, "haoo__sk_disabled-turn", 1)
        break
      end
    end
  end,
})

-- 末档延时效果：本回合内使用的下一张【杀】或【决斗】的伤害值基数+1
shenkun:addEffect(fk.PreCardUse, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("haoo__sk_buff-turn") > 0 and
      (data.card.trueName == "slash" or data.card.trueName == "duel")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "haoo__sk_buff-turn", 0)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

return shenkun
