local shenkun = fk.CreateSkill {
  name = "haoo__shenkun",
  tags = { Skill.Charge },
}

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
  ["haoo__shenkun"] = "神坤",
  [":haoo__shenkun"] = "蓄力技（2/4），①出牌阶段，若你有蓄力点，你可减少1点蓄力点，" ..
    "使用无对应的实体牌的普【杀】或【决斗】（你以此法使用的【杀】无次数限制且计入出牌阶段使用【杀】的次数）。" ..
    "②锁定技，当你于此回合内减少蓄力点后，若以下剩余选项数不小于X（X为你于此回合内累计减少的蓄力点数），" ..
    "你执行第X个选项：1.摸一张牌；2.弃置两张牌（不足则全弃）；3.失去1点体力；" ..
    "4.你于此回合内使用的下一张【杀】或【决斗】的伤害值基数+1，删去第一个选项，〖神坤〗于此回合内无效。",
  ["#haoo__shenkun-active"] = "神坤：你可以减少1点蓄力点，视为使用一张无次数限制的普【杀】或【决斗】",
  ["#haoo__shenkun-discard"] = "神坤：你须弃置两张牌",
}

-- 判断牌是否为【神坤】使用的牌（兼容朱雀羽扇等改牌技能：changeCard 会继承 skillNames 列表）
local function isShenkunCard(card)
  return card ~= nil and (card.skillName == "haoo__shenkun" or
    (card.skillNames and table.contains(card.skillNames, "haoo__shenkun") or false))
end

shenkun:addAcquireEffect(function(self, player)
  U.skillCharged(player, 2, 4)
end)

shenkun:addLoseEffect(function(self, player)
  U.skillCharged(player, -2, -4)
end)

shenkun:addEffect("active", {
  anim_type = "offensive",
  prompt = "#haoo__shenkun-active",
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  can_use = function(self, player)
    return player:getMark("skill_charge") > 0 and
      player:getMark("haoo__sk_disabled-turn") == 0
  end,
  interaction = function(self, player)
    return UI.CardNameBox { choices = { "slash", "duel" }, all_choices = { "slash", "duel" } }
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 or to_select == player then return false end
    if (self.interaction.data or "slash") == "slash" then
      return player:inMyAttackRange(to_select)
    end
    return true
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
    if not player.dead then
      room:useVirtualCard(name, nil, player, to, shenkun.name)
    end
  end,
})

-- 回合内累计减少1/2/3/4点蓄力点的档位效果
shenkun:addEffect(U.SkillChargeChanged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shenkun.name) and
      data.num < 0 and player.room:getCurrent() == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local old = player:getMark("haoo__sk_spent-turn")
    local spent = old - data.num
    room:setPlayerMark(player, "haoo__sk_spent-turn", spent)
    if old < 1 and spent >= 1 then
      player:drawCards(1, shenkun.name)
    end
    if old < 2 and spent >= 2 then
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
    end
    if old < 3 and spent >= 3 then
      room:loseHp(player, 1, shenkun.name)
    end
    if old < 4 and spent >= 4 then
      room:setPlayerMark(player, "haoo__sk_buff-turn", 1)
      -- 第4档触发后，神坤本回合失效
      room:setPlayerMark(player, "haoo__sk_disabled-turn", 1)
    end
  end,
})

-- 第4档：此伤害+1
shenkun:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shenkun.name) and
      player:getMark("haoo__sk_buff-turn") > 0 and
      (data.skillName == shenkun.name or isShenkunCard(data.card))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "haoo__sk_buff-turn", 0)
    data:changeDamage(1)
  end,
})

return shenkun
