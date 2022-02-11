extends Node

enum challenges {TROPHY, GEM, CRYSTAL, RELIC}
var selectedChallenge:Vector2 = Vector2(0,0)


var levelRules:Dictionary = {
	"Level0":{
		"Challenge0":{
			"WinCondition":{
				"Wins":2,
				"InstantFail":true
			},
			"Player":{
				"Hp":3,
				"Abilities": ["ForcePush"]
			},
			"Npc":{
				"Hp":1,
				"Abilities": ["ForcePush"]
			},
			"Arena":{
				"Objects": ["Wall"]
			}
		}
	},
	"Level1":{
		"Challenge1":{
			"WinCondition":{
				"Wins":3,
				"InstantFail":false
			},
			"Player":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Arena":{
				"Objects": []
			}
		},
		"Challenge2":{
			"WinCondition":{
				"Wins":1,
				"InstantFail":true
			},
			"Player":{
				"Hp":8,
				"Abilities": ["ForcePush"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Arena":{
				"Objects": []
			}
		},
		"Challenge3":{
			"WinCondition":{
				"Wins":1,
				"InstantFail":true
			},
			"Player":{
				"Hp":15,
				"Abilities": []
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Arena":{
				"Objects": []
			}
		},
		"Challenge4":{
			"WinCondition":{
				"Wins":3,
				"InstantFail":true
			},
			"Player":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush"]
			},
			"Arena":{
				"Objects": []
			}
		}
	},
	"Level2":{
		"Challenge1":{
			"WinCondition":{
				"Wins":3,
				"InstantFail":false
			},
			"Player":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Arena":{
				"Objects": []
			}
		},
		"Challenge2":{
			"WinCondition":{
				"Wins":1,
				"InstantFail":true
			},
			"Player":{
				"Hp":8,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Arena":{
				"Objects": []
			}
		},
		"Challenge3":{
			"WinCondition":{
				"Wins":1,
				"InstantFail":true
			},
			"Player":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Arena":{
				"Objects": ["Wall"]
			}
		},
		"Challenge4":{
			"WinCondition":{
				"Wins":3,
				"InstantFail":true
			},
			"Player":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Npc":{
				"Hp":15,
				"Abilities": ["ForcePush", "ForceMagnet"]
			},
			"Arena":{
				"Objects": []
			}
		}
	}
}
