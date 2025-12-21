SMODS.Atlas({
	key = "edging_joker",
	path = "j_edging_joker.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = "edging_joker",
	atlas = "edging_joker",
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 2,
	cost = 6,
	config = { extra = { x_mult = 1, x_mult_gain = 0.5, last_hand_score = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
	end,
	calculate = function(self, card, context)
		-- Store hand score after it's calculated but before round ends
		if context.after and not context.blueprint then
			card.ability.extra.last_hand_score = hand_chips * mult
		end
		
		if context.joker_main then
			-- Only show message and apply mult if X mult is greater than 1
			if card.ability.extra.x_mult > 1 then
				return {
					message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.x_mult } }),
					Xmult_mod = card.ability.extra.x_mult,
				}
			else
				return {
					Xmult_mod = card.ability.extra.x_mult,
				}
			end
		end
		
		-- Check at end of round if we beat the blind with a hand that scored less than required
		if context.end_of_round and context.game_over == false and not context.individual and not context.repetition and not context.blueprint then
			-- Check if we won this round
			if G.GAME.chips >= G.GAME.blind.chips then
				-- Check if the last hand scored less than the blind requirement
				if card.ability.extra.last_hand_score < G.GAME.blind.chips and card.ability.extra.last_hand_score > 0 then
					card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
					return {
						message = localize('k_upgrade_ex'),
						colour = G.C.RED,
						card = card,
					}
				end
			end
		end
	end,
	mp_include = function(self)
		return (MP.UTILS.is_standard_ruleset() or MP.LOBBY.config.ruleset == "ruleset_mp_sandbox") and MP.LOBBY.code
	end,
})
