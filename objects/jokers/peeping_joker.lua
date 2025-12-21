SMODS.Atlas({
	key = "peeping_joker",
	path = "j_peeping_joker.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = "peeping_joker",
	atlas = "peeping_joker",
	rarity = 1,
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { dollars = 1, nemesis_dollars = 3 } },
	loc_vars = function(self, info_queue, card)
		MP.UTILS.add_nemesis_info(info_queue)
		return { vars = { card.ability.extra.dollars, card.ability.extra.nemesis_dollars } }
	end,
	in_pool = function(self)
		return MP.GAME.pincher_unlock -- do NOT replace this with G.GAME.round_resets.ante >= 3, order sets ante to 0
	end,
	mp_include = function(self)
		return MP.LOBBY.code and MP.LOBBY.config.multiplayer_jokers
	end,
	calc_dollar_bonus = function(self, card)
		local spent = MP.GAME.enemy.spent_in_shop[MP.GAME.pincher_index]
		local money = 0
		if spent then money = math.floor(spent / card.ability.extra.nemesis_dollars) end
		if money > 0 then return money end
	end,
	calculate = function(self, card, context)
		-- Peeping joker has no calculate effect - triggered by click instead
	end,
	update = function(self, card, dt)
		-- Store initial click state if not already done
		if not card.ability._peeping_click_initialized then
			card.ability._peeping_click_initialized = true
			card.ability._peeping_last_hover = false
		end
		
		-- Check if card is currently being hovered/selected
		if card.hovering then
			if not card.ability._peeping_last_hover then
				-- Just started hovering
				card.ability._peeping_last_hover = true
			end
		else
			card.ability._peeping_last_hover = false
		end
	end,
	add_to_deck = function(self, card, from_debuffed)
		if not from_debuffed and (not card.edition or card.edition.type ~= "mp_phantom") then
			MP.ACTIONS.send_phantom("j_mp_peeping_joker")
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not from_debuff and (not card.edition or card.edition.type ~= "mp_phantom") then
			MP.ACTIONS.remove_phantom("j_mp_peeping_joker")
		end
	end,
	mp_credits = {
		idea = { "Nxkoozie" },
		art = { "Coo29" },
		code = { "Virtualized" },
	},
})
