SMODS.Atlas({
	key = "pemdas",
	path = "j_pemdas.png",
	px = 71,
	py = 95,
})

-- Hook to prevent mult jokers from triggering in joker_main if they were already counted
local eval_card_ref = eval_card
function eval_card(card, context)
	if context.joker_main and not context.blueprint and card.ability.set == "Joker" then
		if card.ability.pemdas_skip then
			card.ability.pemdas_skip = nil
			return {}, {}
		end
	end
	return eval_card_ref(card, context)
end

SMODS.Joker({
	key = "pemdas",
	atlas = "pemdas",
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 1,
	cost = 4,
	config = { extra = { mult_bonus = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_bonus } }
	end,
	calculate = function(self, card, context)
		-- In the "before" phase, add joker mult to the hand's base mult
		if context.before and not context.blueprint then
			local total_mult = 0
			local has_mult_jokers = false
			
			-- First check if there are any mult jokers
			for i = 1, #G.jokers.cards do
				local other_joker = G.jokers.cards[i]
				if other_joker ~= card and not other_joker.debuff then
					if (other_joker.ability.mult and other_joker.ability.mult > 0) or 
					   (other_joker.ability.t_mult and other_joker.ability.t_mult > 0) then
						has_mult_jokers = true
						break
					end
				end
			end
			
			if has_mult_jokers then
				-- Show this joker activating FIRST
				card_eval_status_text(card, 'jokers', nil, nil, nil, {
					message = localize('k_active_ex'),
					colour = G.C.FILTER,
				})
				
				-- Now collect mult from all mult jokers
				for i = 1, #G.jokers.cards do
					local other_joker = G.jokers.cards[i]
					if other_joker ~= card and not other_joker.debuff then
						local mult_to_add = 0
						
						if other_joker.ability.mult and other_joker.ability.mult > 0 then
							mult_to_add = mult_to_add + other_joker.ability.mult
						end
						
						if other_joker.ability.t_mult and other_joker.ability.t_mult > 0 then
							mult_to_add = mult_to_add + other_joker.ability.t_mult
						end
						
						if mult_to_add > 0 then
							total_mult = total_mult + mult_to_add
							
							-- Mark this joker to skip later
							other_joker.ability.pemdas_skip = true
							
							-- Show the other joker triggering
							card_eval_status_text(other_joker, 'jokers', nil, nil, nil, {
								message = localize({type = 'variable', key = 'a_mult', vars = {mult_to_add}}),
								colour = G.C.MULT,
							})
						end
					end
				end
				
				-- Add the mult to the hand's base mult so it persists through the reset
				local hand_name = context.scoring_name
				if hand_name and G.GAME.hands[hand_name] then
					card.ability.extra.original_mult = G.GAME.hands[hand_name].mult
					G.GAME.hands[hand_name].mult = G.GAME.hands[hand_name].mult + total_mult
				end
			end
		end
		
		-- After scoring, restore the original hand mult
		if context.after and not context.blueprint and card.ability.extra.original_mult then
			local hand_name = G.GAME.last_hand_played
			if hand_name and G.GAME.hands[hand_name] then
				G.GAME.hands[hand_name].mult = card.ability.extra.original_mult
				card.ability.extra.original_mult = nil
			end
			
			-- Clean up any remaining skip flags
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].ability.pemdas_skip then
					G.jokers.cards[i].ability.pemdas_skip = nil
				end
			end
		end
	end,
	mp_include = function(self)
		return (MP.UTILS.is_standard_ruleset() or MP.LOBBY.config.ruleset == "ruleset_mp_sandbox") and MP.LOBBY.code
	end,
})
