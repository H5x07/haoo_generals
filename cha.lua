-- Cha's local helpers; official skills and engine methods remain untouched.
local C = {}

function C.canPindian(a, b)
  return a and b and not a.dead and not b.dead and a:canPindian(b)
end

function C.quhuTargets(player)
  return table.filter(player.room.alive_players, function(p)
    return p.hp > player.hp and C.canPindian(player, p)
  end)
end

function C.quhu(player, target)
  if not C.canPindian(player, target) or target.hp <= player.hp then return end
  local room = player.room
  local pd = player:pindian({target}, "quhu")
  if player.dead or target.dead then return end
  if pd.results[target].winner == player then
    local targets = table.filter(room.alive_players, function(p)
      return target:inMyAttackRange(p)
    end)
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 1, cancelable = false,
      skill_name = "cha__jiaji", prompt = "#cha__jiaji-damage",
    })
    if not target.dead and tos[1] and not tos[1].dead then
      room:damage{from = target, to = tos[1], damage = 1, skillName = "quhu"}
    end
  else
    room:damage{from = target, to = player, damage = 1, skillName = "quhu"}
  end
end

function C.grantJinghua(player)
  local room = player.room
  local turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
  if not turn or player.dead or player:hasSkill("cha__jinghua", true, true) then return end
  room:handleAddLoseSkills(player, "cha__jinghua", "cha__beizhi")
  turn:addCleaner(function()
    -- Source-specific removal preserves native and other derivative ownership.
    room:handleAddLoseSkills(player, "-cha__jinghua", "cha__beizhi")
  end)
end

function C.replace(room, parent, pair, fresh)
  local result = fresh.results[pair.to]
  if not fresh.fromCard or not result or not result.toCard then return false end
  local pd = parent.data
  local original = pd.results[pair.to]
  -- Save displaced cards for cleanup: the engine normally cleans only the
  -- cards still referenced by the final result.
  local old = {pair.fromCard, pair.toCard}
  parent:addCleaner(function()
    local ids = {}
    for _, card in ipairs(old) do
      local id = card:getEffectiveId()
      if id and room:getCardArea(id) == Card.Processing then
        table.insertIfNeed(ids, id)
      end
    end
    if #ids > 0 then
      room:moveCards{ids = ids, toArea = Card.DiscardPile, moveReason = fk.ReasonPindian}
    end
  end)
  pair.fromCard, pair.toCard, pair.winner = fresh.fromCard, result.toCard, result.winner
  original.toCard, original.winner = pair.toCard, pair.winner
  -- Multi-target pindian shares fromCard. Store the replacement on this pair
  -- instead of changing the card used to calculate the other opponents.
  original.cha__fromCard = pair.fromCard
  if #pd.tos == 1 then pd.fromCard = pair.fromCard end
  return true
end

function C.redLosers(data)
  local losers, seen = {}, {}
  local function add(p, card, winner)
    if card and card.color == Card.Red and winner ~= p and not seen[p] then
      seen[p] = true
      table.insert(losers, p)
    end
  end
  for _, to in ipairs(data.tos) do
    local r = data.results[to]
    add(data.from, r.cha__fromCard or data.fromCard, r.winner)
    add(to, r.toCard, r.winner)
  end
  return losers
end

return C
