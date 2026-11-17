local daoshi = fk.CreateSkill {
  name = "huang__daoshi",
}

Fk:loadTranslationTable {
  ["huang__daoshi"] = "祷师",
  [":huang__daoshi"] = "出牌阶段限一次，你可以将任意张手牌依次置于牌堆顶，然后视为依次使用等量的【推心置腹】（每张须各自选择目标）。",

  ["#huang__daoshi"] = "祷师：将任意张手牌依次置于牌堆顶，视为依次使用等量的【推心置腹】",
  ["#huang__daoshi-put"] = "祷师：选择第 %arg 张置于牌堆顶的手牌（点取消即结束）",
  ["#huang__daoshi-use"] = "祷师：视为使用一张【推心置腹】（剩余 %arg 张）",
}

daoshi:addEffect("active", {
  anim_type = "special",
  prompt = "#huang__daoshi",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(daoshi.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local x = 0

    -- 一张一张地放：每次选一张手牌置顶，取消即结束
    while not player.dead and not player:isKongcheng() do
      local cards = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = daoshi.name,
        prompt = "#huang__daoshi-put:::" .. (x + 1),
        cancelable = true,
      })
      if #cards == 0 then break end
      if room:getCardArea(cards[1]) ~= Card.PlayerHand then break end
      room:moveCardTo(cards[1], Card.DrawPile, nil, fk.ReasonPut, daoshi.name, nil, true, player)
      x = x + 1
    end

    if x == 0 then return end

    -- 视为依次使用等量的【推心置腹】，每张各自选择目标
    for i = x, 1, -1 do
      if player.dead then break end
      local use = room:askToUseVirtualCard(player, {
        name = "sincere_treat",
        skill_name = daoshi.name,
        prompt = "#huang__daoshi-use:::" .. i,
        cancelable = true,
      })
      if not use then break end
    end
  end,
})

return daoshi
