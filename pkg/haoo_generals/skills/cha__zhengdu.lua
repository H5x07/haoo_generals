local C = require "packages.haoo_generals.cha"
local skill = fk.CreateSkill{name = "cha__zhengdu", tags = {Skill.Compulsory}}
Fk:loadTranslationTable{
  ["cha__zhengdu"] = "睁踱",
  [":cha__zhengdu"] = "锁定技，一次拼点结束后，你对以红色牌拼点且没赢的角色各造成1点伤害。",
}
skill:addEffect(fk.PindianFinished, {
  global = true,
  priority = -100,
  anim_type = "offensive",
  can_refresh = function(self, event, target, player, data)
    return player == data.from and data.cha__confirmed_pairs ~= nil
  end,
  on_refresh = function(self, event, target, player, data)
    -- The engine passes a separate table to ResultConfirmed and does not
    -- propagate modifiers' edits. Keep references until all those hooks finish.
    for to, pair in pairs(data.cha__confirmed_pairs) do
      local r = data.results[to]
      r.winner, r.toCard = pair.winner, pair.toCard
      r.cha__fromCard = pair.fromCard
      if #data.tos == 1 then data.fromCard = pair.fromCard end
    end
  end,
  can_trigger = function(self, event, target, player, data)
    return not data.cha__replacement and not player.dead and player:hasSkill(skill.name)
      and table.find(C.redLosers(data), function(p) return not p.dead end)
  end,
  on_use = function(self, event, target, player, data)
    local victims = C.redLosers(data)
    for _, p in ipairs(victims) do
      if player.dead then break end
      if not p.dead then
        player.room:damage{from = player, to = p, damage = 1, skillName = skill.name}
      end
    end
  end,
})
skill:addEffect(fk.PindianResultConfirmed, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return player == data.from and table.find(player.room.alive_players, function(p)
      return p:hasSkill("cha__zhengdu", true, true) or p:hasSkill("cha__bifa", true, true)
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local parent = player.room.logic:getCurrentEvent():findParent(GameEvent.Pindian)
    if not parent then return end
    local pd = parent.data
    pd.cha__confirmed_pairs = pd.cha__confirmed_pairs or {}
    pd.cha__confirmed_pairs[data.to] = data
  end,
})
return skill
