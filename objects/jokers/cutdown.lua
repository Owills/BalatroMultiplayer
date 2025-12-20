SMODS.Atlas({
	key = "cutdown",
	path = "j_cutdown.png",
	px = 71,
	py = 95,
})

SMODS.Joker({
	key = "cutdown",
	atlas = "cutdown",
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 3,
	cost = 5,
	config = { extra = 1, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card)
		-- Calculate current retrigger amount for display
		local starting_hand_size = (G.GAME and G.GAME.starting_params and G.GAME.starting_params.hand_size) or 8
		local current_hand_size = (G.hand and G.hand.cards and #G.hand.cards) or 8
		local retrigger_amount = math.max(0, starting_hand_size - current_hand_size) * 2
		
		return { vars = {
			retrigger_amount,
		} }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition then
			-- Only retrigger the first card in the scoring hand
			if context.other_card == context.scoring_hand[1] then
				-- Calculate based on hand size at start of playing
				-- Cards in G.play have already been removed from G.hand, so add them back
				local starting_hand_size = G.GAME.starting_params.hand_size or 8
				local cards_remaining_in_hand = #G.hand.cards
				local cards_being_played = #G.play.cards
				local hand_size_before_playing = cards_remaining_in_hand + cards_being_played
				local retrigger_amount = math.max(0, starting_hand_size - hand_size_before_playing) * 2
				
				if retrigger_amount > 0 then
					return {
						message = localize("k_again_ex"),
						repetitions = retrigger_amount,
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
