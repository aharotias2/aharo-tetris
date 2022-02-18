Aharo-Tetris
====================================================================================================
![screenshot](docs/images/screenshot-1.png)

A very simple Tetris implementation using the GTK + 3 toolkit.

It operates in cascading mode by default.

[Cascading mode specifications](https://tetris.wiki/Cascade_mode) (reference example, not strictly
followed) 

Scoring Specification
----------------------------------------------------------------------------------------------------
The scoring rules for this app are as shown in the table below. 

| Conditions                        | Score                    |
|-----------------------------------|--------------------------|
| Erase one line (Single)           | 40                       |
| Erase two lines (Double)          | 100                      |
| Erase three lines (Triple)        | 300                      |
| Erase four lines (Tetris)         | 1200                     |
| Erase more than five lines        | 2000 x (number of lines) |
| Single & Double at the same time  | 1000                     |
| Two Singles (one line in between) | 600                      |
| Two Singles (two line in between) | 900                      |

You can score in multiples for each chain. 

I'm sorry if I made a mistake. 

Build
----------------------------------------------------------------------------------------------------
You can build using Meson as usual.

    $ meson --prefix=/usr/local build
	$ cd build
	$ ninja
	$ sudo ninja install

prerequisite
* Gtk+3
* Vala
* Meson

License
----------------------------------------------------------------------------------------------------
GPLv3

----------------------------------------------------------------------------------------------------

Author: Takayuki Tanaka

