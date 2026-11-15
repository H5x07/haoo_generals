local F = require "packages.haoo_generals.fuban"
local skill = fk.CreateSkill { name = "fb__hufu" }

skill:addEffect("viewas", {
  card_num = 1,
  pattern = "vine,women_dress,silver_lion",
  prompt = "#fb__hufu",
  include_equip = true,
  card_filter = function(self, player, to_select, selected)
    if #selected ~= 0 or not F.material(player, to_select) then return false end
    local card = self:viewAs(player, { to_select })
    return card ~= nil and player:canUseOrResponseInCurrent(card)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not F.material(player, cards[1]) then return end
    local original = Fk:getCardById(cards[1])
    local card = Fk:cloneCard(F.name(original.suit), original.suit, original.number)
    if not card then return end
    card:addSubcard(cards[1])
    card.skillName = skill.name
    return card
  end,
  enabled_at_response = function(self, player, response) return not response end,
  before_use = function(self, player, use)
    if #use.card.subcards ~= 1 or not F.material(player, use.card.subcards[1]) then return skill.name end
    player.room:setCardMark(Fk:getCardById(use.card.subcards[1]), F.mark, { Card.Processing, Card.PlayerEquip })
  end,
  after_use = function(self, player, use)
    for _, id in ipairs(use.card.subcards) do
      if player.room:getCardArea(id) ~= Card.PlayerEquip then player.room:setCardMark(Fk:getCardById(id), F.mark, 0) end
    end
  end,
})

skill:addAcquireEffect(function(self, player)
  if player:getMark("fb__hufu_slot") == 0 then
    player.room:setPlayerMark(player, "fb__hufu_slot", 1)
    player.room:addPlayerEquipSlots(player, Player.ArmorSlot)
  end
end)

Fk:loadTranslationTable {
  ["fb__hufu"] = "祜服",
  [":fb__hufu"] = "你拥有一个额外防具栏。你可将一张手牌或装备区里的非防具装备牌，按花色♠/♥♦/♣当【藤甲】/【女装】/【白银狮子】使用，且转化的防具附带【英姿】。每件防具提供的【英姿】分别生效。",
  ["#fb__hufu"] = "祜服：将一张手牌或装备区的非防具装备牌按花色当防具使用（附带英姿）",
}

return skill
