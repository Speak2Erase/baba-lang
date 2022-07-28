# keke

keke is a compiled scripting language in the vain of [baba](https://github.com/Astrabit-ST/baba) that compiles down to the code the RPG Maker XP event interpreter uses.
It's essentially a textual representation of RMXP events, which unfortunately limits it to the capabilities of an RMXP event.

keke when compiled is injected into an RMXP map's events, or is compiled at runtime inside an event, then executed.
