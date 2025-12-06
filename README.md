# nvim-csharp-runner

A Neovim plugin to run C# code snippets using CS-Script that I Vibecoded using Claude.

## Requirements

- Neovim 0.5+
- [CS-Script](https://github.com/oleg-shilo/cs-script) (css command must be in PATH)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'TheAjaykrishnanR/nvim-csharp-runner',
  config = function()
    require('csharp_runner')
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'TheAjaykrishnanR/nvim-csharp-runner',
  config = function()
    require('csharp_runner')
  end
}
```

### Manual

Clone to your Neovim config directory:
```bash
git clone https://github.com/yourusername/nvim-csharp-runner ~/.config/nvim/pack/plugins/start/nvim-csharp-runner
```

Then add to your `init.lua`:
```lua
require('csharp_runner')
```

## Usage

### Commands

- `:Run` - Execute the current C# buffer
- `:Kill` - Stop the running C# process

### Features

- Live output streaming
- Animated loading indicator
- Automatic output buffer management
- Process termination support

## Example
```csharp
using System;
class _ {	
    static void Main() {
        Console.WriteLine("Hello, World!");
    }
}
```

Run `:Run` to execute!
