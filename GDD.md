# Alchemy Shop Simulator Game Design Document
Pirate Software Game Jam 15  
July 2024  
By Baro
## Introduction
You are an alchemist opening your new store in the city. Craft potions and keep the business running in an increasingly unstable kingdom. Alchemy is generally seen as a noble profession, producing items that can cure illness and aid those in more dangerous professions. But there is a darker side to the alchemic arts, potentially more profitable should the alchemist be willing to create concoctions that can cause harm alongside those that heal.
### Inspiration
#### Slay the Spire
Cards as randomisation, recharging resources each turn
#### Cultist Simulator
Boardgame style, abstraction between gameplay and story/themes
### Player Experience
Player is dealt a number of materials each turn. They must process these materials into potions in order to fulfil requests. Requests reward gold and renown, which are used to purchase upgrades (and pay taxes) and unlock better requests.
### Genre
Single Player, Board Game
### Target Platform
Web Browser
### Development Software
- **Game Engine:** Godot 
- **Source Control:** Git
- **3D Modelling:** Blender
## Concept
### Gameplay Overview
Game view is laid out like a board game, with card/tokens that can be moved around with the mouse. The player converts these cards into others using the refining and distilling stations on the board. Finished potions can then be placed on requests to complete them at the end of the turn.
### Theme Interpretation (Shadows and Alchemy)
Simple interpretation of alchemy, taking raw materials, processing and refining them into potions or tinctures, combining reagents in different ways to produce different results. 

Shadow interpretation is in two aspects, the first being the decline of the kingdom and the potential for the player to get involved with shady dealings to undermine or assassinate the king. The second is in the darker side of alchemy, the creation of poisons to harm rather than potions to heal.
### Gameplay Mechanics
#### Processing Materials
The board has two sections for converting resources. Refining takes a Material and converts it into a Reagent. Distilling takes two Reagents and converts them into a Potion.

Each processing operation costs Energy, which is recharged at the start of each turn.

As you progress you can find upgrade cards that will improve the functionality of one of the Processing Stations. These can do things like give one free craft each turn, or add a chance to generate an additional output.
#### Energy
Energy is spent each time a Processing Operation is performed. It recharges at the start of each turn. Upgrades to Processing Stations can allow for one or more free crafts each turn.
#### Requests
Requests are customer orders for a specific Potion. They include a Gold and Renown reward for filling the order. Requests have a duration time (number of turns) that they are available for, if you take too long to fill an order the customer will go elsewhere.

It is also possible to fill an order with a potion the customer did not ask for. This results in the same Gold reward but a negative Renown reward, as the customer later discovering they have been tricked negatively affects your shops reputation.
#### Renown
Your reputation as an alchemist. Renown grows when you fulfil requests with the correct item, and falls when you try to sell whatever you have for a quick buck. Higher renown means more lucrative requests will become available.
#### Gold
Rewarded by completing Requests. Used to pay for Processing Station upgrades, taxes, and Event outcomes.
#### Tax
Acts as loss condition. Introduced via Event in early turns and increases over the course of the game. Additional Events can potentially manipulate the tax rate as the status of the kingdom changes.
#### Events
Events drive the story and randomisation of the game. They have a chance to appear at the start of each turn. They can be simple Info updates on the state of the kingdom, or player decisions, or variations in the next turn, such as higher rewards or specific limitations. 

As you get further into the game the events start to reveal the dire state of the kingdom. Tax increases and limited resources make it hard to make gold and keep the shop open. Eventually a number of options present themselves. Earn enough to purchase passage out of the country, or aid the shadowy patrons and help them overthrow the king.
## Game Experience
### User Interface
UI is mostly built into the game board itself, with the exception of popup windows for the Turn Summary, Events, and Game End. The board has regions for cards to be placed, text elements with information, and buttons to perform actions (processing, removing objects, ending the turn, etc).
### Controls
- **LEFT MOUSE:** Select cards and slots to move them to, select buttons on board and popups.
- **RIGHT MOUSE:** Deselect the selected card.
## Art
Game board appears like a wooden table or counter. 

Cards and game elements looks like low poly style board game tokens, rough, almost carved or whittled appearance.

Requests are pieces of crumpled parchment with order details written on them.

Popups are a cleaner parchment look, like a bulletin that has been pinned to a wall.
## Audio
### Music
Setting is loosely medieval. Simple string instruments. Something appropriate for a quiet tavern or shop, with faint ambience of small flames, bubbling liquids, grinding of a mortar and pestle, indistinct quiet conversation, etc.
### Sound Effects
- Moving cards should have a light metallic sound effect as they are placed in new slots. 
- Activating Processing Stations should play an appropriate sound for that stations functions (grinding or chopping for Refining, fire and bubbling for distilling).
- Event popups should play a relevant sound for their event:
	- Indistinct conversation/muttering or Info/Rumours
	- Clatter of coins for Taxes and Gold related events
## Future Elements (Out of scope for Game Jam)
### Additional Event Types
There's a lot of potential to increase replayability by adding more Event types and expanding the possibility space of each run.
### Branching / Multi stage storytelling
Would require a refactor of the Event system. Better tracking of player choices to tailor future events. Maintain a list of story factors and adjust the pool of events based on previous choices/state of the board.
### Additional Materials (Poisons)
Would be required for the darker story paths. Introduces a second layer to distilling by requiring Reagents be combined in specific ways to produce Potions or Poisons. Would likely require a change to board layout to accommodate more cards being held in each stage.
### Material Potency
The Potency of a Material would factor into bonuses when it is used in crafting (such as a multiplier on Request rewards). This Potency would degrade each turn. Adding an additional factor to consider when deciding how to spend energy each turn, and opening up additional Event options and Upgrades.
- Events that reduce the number of cards drawn, but increase potency.
- Upgrades that reduce the rate of potency decay on the board.
- Requests that require a minimum Potency to receive full Renown reward.
### Alternative Processing Station Upgrades
Upgraded stations produce more complex reagents. T2 stations produces an additional reagent from healing herb, T2 distillery can take extra reagents to modify the result, adding effects/ailments to fulfil more specific requests.
## Development
### Task List
| Task                                                   | Type               | Status      | Completion Date | Notes |
| ------------------------------------------------------ | ------------------ | ----------- | --------------- | ----- |
| Design Document - Initial Draft                        | Documentation      | COMPLETE    | 30/7/24         |       |
| Project Creation - Create Godot Project, Init Git repo | Project Management | COMPLETE    | 21/7/24         |       |
| Create Main Menu - Transition to Game View             | Coding             | COMPLETE    | 21/7/24         |       |
| Select Assets -                                        | Art                |             |                 |       |
| Game Loss State and Restart                            | Coding             | COMPLETE    | 24/4/24         |       |
| Design Document - Finalise Submission Version          | Documentation      | COMPLETE    | 30/7/24         |       |
| Create submission build                                | Project Management | COMPLETE    | 30/7/24         |       |
| Victory Condition -                                    | Coding             | COMPLETE    | 30/7/24         |       |
| Game Feel - Add effects                                | Design             |             |                 |       |
| Game Feel - Background music                           | Audio              |             |                 |       |
| Game Balance -                                         | Coding             | IN PROGRESS |                 |       |
| Add a "how to play" section to title screen            | Game Design        |             |                 |       |
| Add credits page                                       | Coding             |             |                 |       |
### Work Log
#### 2024-07-18
- Theme introduction, brainstorming
#### 2024-07-20
- Started Design Doc
#### 2024-07-21
- Started Godot project, set up git repo
- Set up title scene and transition to game scene
- Tested export to Web and upload to itch.io
#### 2024-07-25
- Added Card object
- Implemented mouse detection and hover/select highlight states
#### 2024-07-26
- Added Card Slots
- Created Initial Game Board layout
- Refactored selection code to use slots rather than cards
- Added card categories and types (and functions to easily generate new cards)
- Implemented Refining (converts materials into reagents)
#### 2024-07-27
- Decided on "Alchemy Shop Simulator" as working title
- Implemented Distilling (converts 2 reagents into a potion)
- Implemented Requests (contracts that ask for a specific potion type in exchange for gold and renown)
- Implemented Turn Loop
	- Refining and Distilling require energy, which regenerates each turn
	- Fulfilled requests are processed, generating gold and renown
	- Additional materials and requests are generated for turn 2
#### 2024-07-28
- Implement turn summary and event popups
- Refactored card and request generation
- Implemented upgrades for Refine and Distill Stations
#### 2024-07-29
- Added Tax increase events
#### 2024-07-30
- Added Request generation events
- Added victory condition checks and victory screen
- Finished filling out Design Document

