local skill = fk.CreateSkill{name = "cha__qice"}
Fk:loadTranslationTable{
  ["cha__qice"] = "奇策",
  ["#cha__qice"] = "北智：将所有手牌当一张普通锦囊牌使用",
}
skill:addEffect("viewas", {
  prompt = "#cha__qice",
  filter_pattern = function(self, player)
    return {max_num = 0, min_num = 0, pattern = ".|.|.|hand", subcards = player:getCardIds("h")}
  end,
  interaction_helper = function(self, player)
    local names = Fk:getAllCardNames("t")
    return UI.CardNameBox{
      choices = player:isKongcheng() and {} or
        player:getViewAsCardNames(skill.name, names, player:getCardIds("h")),
      all_choices = names,
    }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player)
    if player:isKongcheng() or not table.contains(Fk:getAllCardNames("t"), self.interaction.data) then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(player:getCardIds("h"))
    card.skillName = skill.name
    return card
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = Util.FalseFunc,
})
return skill
