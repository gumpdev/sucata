# 🔩 Sucata Game Engine

An open-source 2D game engine made with Odin programming language and Lua as scripting language, inspired by Love2D and Godot Engine.

<br>

[Website/Documentation](https://sucata.dev) | [Discord](https://discord.com/invite/Rv9EavmaJQ)

<br>

### ✨ Features ✨

- Render images and texts with GPU acceleration (using native libraries like D11X, Metal, OpenGL)
- Audio playback and manipulation
- Input handling (keyboard, mouse)
- Scene management
- Lua scripting
- Cross-platform support (Windows, macOS, Linux)
- Simple and intuitive file system for asset management


#### Future plans

- Make the features better and more optimized
- More animation features
- Multiple Shader support
- Network multiplayer support
- Particle system
- Controller support
- Maybe 3D support in the future
- Support with [Tiled](https://www.mapeditor.org)
- Native call support for C/C++ functions


<br>
<br>

## Table of Contents

- [🔩 What is Sucata?](#what-is-sucata)
- [🔧 Installation](#installation)
- [📝 Getting Started](#getting-started)
- [🌱 Examples](#examples)
- [📚 Libraries](#libraries)
- [🙏 Special Thanks](#special-thanks)
- [🤔 FAQ](#faq)

<br>
<a id="what-is-sucata"></a>

## 🔩 What is Sucata?

Sucata game engine is a 2D game engine made to be simple and easy to use, with a lot of features to make your game development experience better.

The goal is to make a create game experience similar good and smooth using only Lua scripting language.


<a id="installation"></a>

## 🔧 Installation

1. Install [Odin](https://odin-lang.org)
2. Clone the repository:
	 ```bash
	 git clone https://github.com/gumpdev/sucata.git
	 ```
3. Run installer script:
	 ### For Linux and macOS
	 ```bash
	 cd sucata; ./install_unix.sh
	 ```
	 ### For Windows
	 ```powershell
	 cd sucata; ./install_windows.cmd
	 ```
4. Restart your terminal, then sucata command will be available
5. Install the [Sucata Lua addon](https://github.com/gumpdev/sucata-lua-addon) on [Lua Sumneko extension](https://luals.github.io/#vscode-install) for better Sucata autocompletion on IDE 

<br>
<a id="getting-started"></a>

## 📝 Getting Started

### How it works?

Sucata game engine is data-driven, which means that you can create your game using only Lua scripts. The engine will load the scripts and run them, and you can create relational entities that will interact with each other.

#### Entity

An entity is a table that contains functions that will be called by the engine. The most important functions are:
- `init(self)`: Called when the scene is loaded
- `update(self)`: Called every frame to update the entity
- `draw(self)`: Called every frame to draw the entity
- `free(self)`: Called when the scene is unloaded

> _self_ parameter is a reference to the entity itself, so you can store variables in it.

> Entity when spawned will have an id property that can be used to identify the entity.

> Sucata works with [classic](https://github.com/rxi/classic) by default

#### Scene

A scene is a pool of entities that will be loaded and unloaded together. You can load a scene using the `sucata.scene.load_scene(entities)` function, where _entities_ is an array of entities.

> By default Entities don't have childrens and parents, but you can create your own system to manage that with ids.

You can find entities by:
```lua
sucata.scene.find_by_id(id) -- Find entity by id
sucata.scene.get_entities() -- Get all entities in the scene
```

#### Spawn and Destroy

You can spawn and destroy entities at runtime using the following functions:

```lua
sucata.scene.spawn(entity_or_id) -- Spawn a new entity
sucata.scene.spawns(entities_or_ids) -- Spawn new entities

sucata.scene.destroy(entity_or_id) -- Destroy an entity
sucata.scene.destroys(entities_or_ids) -- Destroy entities  
```

#### Tags

You can add tags to entities to categorize them. To add a tag to an entity, just add a `tags` property to the entity table, which is an array of strings.

```lua
sucata.scene.add_tag(entity_or_id, tag) -- Add a tag to an entity
sucata.scene.remove_tag(entity_or_id, tag) -- Remove a tag from an entity
sucata.scene.get_entities_by_tag(tag) -- Get entities by tag
```

#### Drawing

In Sucata, you can draw a rect or a text using the `sucata.graphic` module. Here are some examples:

```lua
sucata.graphic.draw_rect({ -- Draws a rectangle
	x = 100, -- X position
	y = 100, -- Y position
	width = 50, -- Width of the rectangle
	height = 50, -- Height of the rectangle
	color = "#ff0000" -- Color of the rectangle
	texture = "path/to/texture.png" -- Optional texture
})

sucata.graphic.draw_text({ -- Draws a text
	x = 200, -- X position
	y = 200, -- Y position
	text = "Sucateado", -- Text to draw
	font_size = 24, -- Font size
	color = "#00ff00" -- Color of the text
	font = "path/to/font.ttf", -- Optional font
})
```

#### File System

In Sucata we have some prefix to access some paths easily:

`src://` - Path to the source folder of the project

`data://` - Path to the data folder of the user
> Windows: %appdata%

> Linux: ~/.local/share

> macOS: ~/Library/Application Support

`build://` - Path to the project build folder (where the executable is located)


### Creating a White Square

To create a simple white square on the screen, you can use the following code:

```lua
sucata.window.set_window_size(512, 512) -- Defines the window size
sucata.window.set_window_title("Empty Sucata") -- Sets the window title
sucata.window.set_keep_aspect(true) -- Maintains the aspect ratio
sucata.window.show_debug_info(true) -- Shows debug information

local white_square = {
	init = function(self) -- Called when the scene is loaded
		self.x = 200
		self.y = 200
		self.width = 100
		self.height = 100
	end,
	draw = function(self) -- Called every frame to draw the entity
		sucata.graphic.draw_rect({ -- Draws a rectangle
			x = self.x,
			y = self.y,
			width = self.width,
			height = self.height,
			color = "#ffffff"
		})
	end
}

sucata.scene.load_scene({ white_square }) -- Loads the scene with the white square entity
```

### How to run the project?

To run your Sucata project, use the following command in your terminal:

```bash
sucata run . 
```

> Will run the default project file there is `main.lua` in the current directory.

You also can run an specific entity to test only it:

```lua
-- Sucata Entity File Example
local Object = require("classic")

local Meteor = Object:extend()
function Meteor:new()
	self.x = math.random(16, 496)
	self.y = -16
	self.speed = math.random(100, 200)
	self.health = math.random(1, 5)
end

function Meteor:init()
	sucata.scene.add_tag(self, "meteor")
end

function Meteor:update()
	local dt = sucata.time.get_delta()
	self.y = self.y + self.speed * dt
	if self.y > 528 then
		Life = Life - 1
		sucata.scene.destroy(self)
	end
end

function Meteor:draw()
	sucata.graphic.draw_rect({
		x = self.x,
		y = self.y,
		width = 32,
		height = 32,
		texture = "src://sprites/meteor.png",
		origin = 0.5,
		atlas_size = 8,
		atlas_x = self.health - 1
	})
end

return Meteor
```

```bash
sucata run . --entity entity_file_name
```

>entity_file_name needs to be in the lua require format, for example: `entities.player` for `entities/player.lua` file.

### How to build the project?

To build your Sucata project, use the following command in your terminal:

```bash
sucata build . 
```

> Will build the project for the OS you are currently using.

> The build files will be located in the `build/` folder inside your project directory.

> The project assets will be bundle to `assets.sucata` file inside the build folder.

> Windows builds needs the `lua54.dll` file to run the project

<br>
<a id="examples"></a>

## 🌱 Examples

### Meteors

A game inspired by the classic Asteroids game, where you need to survive as long as possible avoiding meteors.

[Link](https://github.com/gumpdev/meteors-sucata)

<br>
<a id="libraries"></a>

## 📚 Libraries

Some libraries used in Sucata Game Engine:

- [odin](https://odin-lang.org/) - Programming language used to build the engine
- [lua](https://www.lua.org/) - Scripting language used in the engine
- [sokol](https://github.com/floooh/sokol) - Cross-platform development libraries for graphics, audio, and input handling
- [miniaudio](https://github.com/mackron/miniaudio) - Single file audio playback and capture library
- [lz4](https://github.com/lz4/lz4) - Fast compression algorithm for asset compression

<br>
<a id="special-thanks"></a>

## 🙏 Special Thanks

- [Ellora](https://github.com/elloramir)
- [ThornDuck](https://github.com/MuriloMGrosso)

<br>
<a id="faq"></a>

## 🤔 FAQ

- **I Found a BUG!** _[Click here](https://github.com/gumpdev/sucata/issues) and open an issue_
- **Can I help with the project?** _Sure! just send your PR or idea_
- **Can I contact you?** _Yep, send email to contact@gump.dev_
