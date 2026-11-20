local C = require "packages.haoo_generals.cha"
local skill = fk.CreateSkill{name = "cha__bifa"}
Fk:loadTranslationTable{
  ["cha__bifa"] = "笔伐",
  [":cha__bifa"] = "当你使用黑色牌拼点失败时，你可再次发起拼点并以此为结果。",
  ["#cha__bifa-invoke"] = "笔伐：是否与 %dest 重新拼点，以新结果替代此次结果？",
}
skill:addEffect(fk.PindianResultConfirmed, {
  priority = -10,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    local other = data.from == player and data.to or data.from
    local card = data.from == player and data.fromCard or data.toCard
    return (data.from == player or data.to == player) and player:hasSkill(skill.name)
      and data.winner ~= player and card and card.color == Card.Black and C.canPindian(player, other)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#cha__bifa-invoke::" .. (data.from == player and data.to.id or data.from.id),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local parent = room.logic:getCurrentEvent():findParent(GameEvent.Pindian)
    if not parent or not C.canPindian(data.from, data.to) then return end
    -- Preserve orientation even when the owner is the target.
    local fresh = {from = data.from, tos = {data.to}, reason = skill.name,
      results = {}, cha__replacement = true}
    room:pindian(fresh)
    C.replace(room, parent, data, fresh)
  end,
})
return skill
