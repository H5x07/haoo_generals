local U = require "packages.utility.utility"

local luoze = fk.CreateSkill {
  name = "huang__luoze",
}

Fk:loadTranslationTable {
  ["huang__luoze"] = "洛择",
  [":huang__luoze"] = "当你需要使用或打出牌时，你可声明牌名：选择一名其他角色/翻开牌堆顶一张牌；若：该角色手牌中有此牌名/翻开的牌牌名相同；则你如手牌般使用或打出该牌；否则〖洛择〗于此回合失效。",

  ["#huang__luoze"] = "洛择：声明一种牌名，然后选择一名其他角色或翻开牌堆顶一张牌",
  ["#huang__luoze-resp"] = "洛择：选择一名其他角色或翻开牌堆顶一张牌，若其中有你需要的牌则视为使用或打出之",
  ["#huang__luoze-name"] = "洛择：声明一种牌名",
  ["#huang__luoze-choice"] = "洛择：选择一名其他角色或翻开牌堆顶一张牌",
  ["#huang__luoze-target"] = "洛择：选择一名其他角色",
  ["#huang__luoze-pick"] = "洛择：选择要使用的牌",
  ["#huang__luoze-use"] = "洛择：视为使用该牌",
  ["huang__luoze-pick-player"] = "选择一名其他角色",
  ["huang__luoze-pick-pile"] = "翻开牌堆顶一张牌",
}

local function name_match(card, declared)
  return card.name == declared or card.trueName == declared
end

luoze:addEffect("viewas", {
  pattern = ".",
  anim_type = "control",
  prompt = "#huang__luoze",
  card_filter = Util.FalseFunc,
  view_as = Util.DummyFunc,
  feasible = Util.TrueFunc,
  enabled_at_play = function(self, player)
    return player:getMark("huang__luoze-failed-turn") == 0
  end,
  -- 需要响应（打出/使用）时都能发动：回合外，以及自己回合内需要打出【无懈可击】等时
  enabled_at_response = function(self, player, response)
    return player:getMark("huang__luoze-failed-turn") == 0
  end,
  -- 锦囊结算询问无懈时也能发动（否则手里没有【无懈可击】的角色不会进入候选名单）
  enabled_at_nullification = function(self, player, data)
    return player:getMark("huang__luoze-failed-turn") == 0 and not player.dead
  end,
  on_use = function(self, room, cardUseEvent, _, params)
    local player = cardUseEvent.from
    -- 响应窗口的判断以 Fk.currentResponsePattern 为准，params.is_response 只是补充
    local pattern = (params and params.pattern) or Fk.currentResponsePattern
    local is_response = (params and params.is_response) or pattern ~= nil

    -- 回合内：声明牌名；回合外：不声明，直接以“本次需要的牌”为准
    local declared
    if not is_response then
      local all_names = Fk:getAllCardNames("btd")
      local names = U.askForChooseCardNames(room, player, all_names, 1, 1, luoze.name,
        "#huang__luoze-name", nil, true)
      if #names == 0 then return luoze.name end
      declared = names[1]
      room:sendLog {
        type = "#Choice",
        from = player.id,
        arg = declared,
        toast = true,
      }
    end

    --- 这张牌是否可用（回合内看牌名，回合外看本次请求需要的牌）
    local function usable(card)
      if declared then
        return name_match(card, declared)
      end
      if pattern and not card:matchPattern(pattern) then return false end
      if is_response and player:prohibitResponse(card) then return false end
      return true
    end

    -- 选择一名其他角色 / 翻开牌堆顶一张牌
    local others = room:getOtherPlayers(player, false)
    local choice = room:askToChoice(player, {
      choices = { "huang__luoze-pick-player", "huang__luoze-pick-pile" },
      skill_name = luoze.name,
      prompt = is_response and "#huang__luoze-resp" or "#huang__luoze-choice",
      cancelable = false,
    })

    local found = {}
    if choice == "huang__luoze-pick-player" and #others > 0 then
      local tos = room:askToChoosePlayers(player, {
        targets = others,
        min_num = 1,
        max_num = 1,
        skill_name = luoze.name,
        prompt = "#huang__luoze-target",
      })
      local target = tos and tos[1]
      if target and not target.dead then
        local ids = table.filter(target:getCardIds("h"), function(id)
          return usable(Fk:getCardById(id))
        end)
        if #ids == 1 then
          found = ids
        elseif #ids > 1 then
          local pick = room:askToChooseCard(player, {
            target = target,
            flag = { card_data = { { "$Hand", ids } } },
            skill_name = luoze.name,
            prompt = "#huang__luoze-pick",
          })
          if type(pick) == "number" then
            found = { pick }
          elseif type(pick) == "table" and #pick > 0 then
            found = { pick[1] }
          end
        end
      end
    else
      local ids = room:getNCards(1)
      if #ids > 0 then
        room:turnOverCardsFromDrawPile(player, ids, luoze.name)
        -- 亮出给所有人看
        room:showCards(ids, player, player)
        local matched = table.filter(ids, function(id)
          return usable(Fk:getCardById(id))
        end)
        -- 亮出后放回牌堆顶；命中时再从牌堆使用这张牌
        room:returnCardsToDrawPile(player, ids, luoze.name)
        found = matched
      end
    end

    if #found == 0 then
      room:setPlayerMark(player, "huang__luoze-failed-turn", 1)
      -- 技能上打失效标记，回合结束后自动恢复
      room:invalidateSkill(player, luoze.name, "-turn")
      return luoze.name
    end

    local card = Fk:getCardById(found[1])
    if is_response then
      return {
        from = player,
        tos = {},
        card = card,
      }
    end

    -- 主动使用：以这张实体牌为子牌构造虚拟牌，自行询问目标后按“你使用”结算
    -- （不走 askToUseRealCard：它默认 bypass_times/extraUse，且对牌堆中的牌目标预判会失败）
    local vcard = Fk:cloneCard(card.name)
    vcard:addSubcards(found)
    vcard.skillName = luoze.name
    local card_skill = vcard.skill
    -- 用 canUseTo 判定：它同时检查 useTarget 限制（如【桃】【闪电】只能对自己），
    -- 不能用 modTargetFilter，那只是“修正目标”，不判合法性
    local cand = {}
    for _, p in ipairs(room.alive_players) do
      if player:canUseTo(vcard, p, { bypass_times = false }) then
        table.insert(cand, p)
      end
    end
    local max_num = card_skill:getMaxTargetNum(player) or 0
    local tos = {}
    -- 先看牌自己固定的目标（【桃】【酒】【无中生有】【闪电】等只能对自己）
    local fixed = vcard:getFixedTargets(player, { bypass_times = false })
    if fixed and #fixed > 0 then
      tos = fixed
    elseif max_num > 0 then
      local min_num = card_skill:getMinTargetNum(player) or 1
      if min_num < 1 then min_num = 1 end
      if #cand < min_num then return luoze.name end
      if #cand == 1 and min_num == 1 then
        -- 唯一合法目标，不再多问一次
        tos = { cand[1] }
      else
        tos = room:askToChoosePlayers(player, {
          targets = cand,
          min_num = min_num,
          max_num = max_num,
          skill_name = luoze.name,
          prompt = "#huang__luoze-use",
          cancelable = true,
        })
        if #tos == 0 then return luoze.name end
      end
    end
    return {
      from = player,
      tos = tos,
      card = vcard,
      extraUse = false,
    }
  end,
})

return luoze
