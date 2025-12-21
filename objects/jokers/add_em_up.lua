SMODS.Atlas({
	key = "add_em_up",
	path = "j_add_em_up.png",
	px = 71,
	py = 95,
})


SMODS.Joker({
    key = "add_em_up",
    atlas = "add_em_up",
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 1,
    cost = 4,
	config = { extra = 1, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra,
		} }
	end,
	calculate = function(self, card, context)
		-- Transform the first card before scoring happens
		if context.before and context.main_eval then
			if G.GAME.current_round and G.GAME.current_round.hands_played == 0 and context.full_hand and #context.full_hand == 2 then
				local first_card = context.full_hand[1]
				local second_card = context.full_hand[2]

				if not first_card or not second_card or not first_card.base or not second_card.base then return end

				-- Only apply once, check if either card has been modified
				if not first_card.ability._add_em_up_applied and not second_card.ability._add_em_up_applied then
					-- Add second card's printed number to first card's printed number
					local first_id = first_card.base.id == 14 and 1 or first_card.base.id
					local second_id = second_card.base.id == 14 and 1 or second_card.base.id
					local wrap_adder = first_id + second_id > 13 and 1 or 0
					local new_id = (first_id + second_id) % 14 + wrap_adder
					if new_id == 0 then new_id = 14 end  -- Handle modulo edge case
					
					-- Convert numeric id to card value string
					local id_to_value = {
						[1] = "Ace",
						[2] = "2", [3] = "3", [4] = "4", [5] = "5",
						[6] = "6", [7] = "7", [8] = "8", [9] = "9",
						[10] = "10", [11] = "Jack", [12] = "Queen",
						[13] = "King"
					}
					
					local new_value = id_to_value[new_id]
					local suit = first_card.base.suit
					
					-- Create the new card key for P_CARDS lookup
					-- P_CARDS uses suit abbreviation and rank code (J, Q, K, A, T for 10)
					local suit_to_abbrev = {
						Hearts = "H", Diamonds = "D", Clubs = "C", Spades = "S"
					}
					local rank_to_code = {
						Ace = "A",
						["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5",
						["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9",
						["10"] = "T", Jack = "J", Queen = "Q", King = "K"
					}
					local suit_abbrev = suit_to_abbrev[suit]
					local rank_code = rank_to_code[new_value]
					
					if rank_code and suit_abbrev then
						local new_card_key = suit_abbrev .. "_" .. rank_code
						local new_card_def = G.P_CARDS[new_card_key]
						
						if new_card_def then
							-- Update the card to the new base definition
							first_card:set_base(new_card_def)
							
							-- Set nominal value for chip calculation
							-- Face cards (J, Q, K) are worth 10, Ace is worth 1 (low)
							local chip_value = new_id
							if new_id >= 11 and new_id <= 13 then
								chip_value = 10  -- Jack, Queen, King
							elseif new_id == 1 then
								chip_value = 1   -- Ace (low)
							end
							first_card.base.nominal = chip_value
							
							-- Update orig_id to track the modification
							if not first_card.orig_id then first_card.orig_id = first_card.base.id end
							first_card.orig_id = new_id
						end
					end
					
					-- Mark BOTH cards as applied so it doesn't happen twice
					first_card.ability._add_em_up_applied = true
					second_card.ability._add_em_up_applied = true
				end
			end
		end
	end,
	mp_include = function(self)
		return (MP.UTILS.is_standard_ruleset() or MP.LOBBY.config.ruleset == "ruleset_mp_sandbox") and MP.LOBBY.code
	end,
	add_to_deck = function(self, card, from_debuffed)
		if not from_debuffed and (not card.edition or card.edition.type ~= "mp_phantom") then
			MP.ACTIONS.send_phantom("j_mp_add_em_up")
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not from_debuff and (not card.edition or card.edition.type ~= "mp_phantom") then
			MP.ACTIONS.remove_phantom("j_mp_add_em_up")
		end
	end,
	mp_credits = {
		idea = { "Jonah Jaffe" },
		art = { "Jonah Jaffe" },
		code = { "Jonah Jaffe" },
	},
})
