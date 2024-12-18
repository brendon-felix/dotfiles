# Nushell Tools

A collection of useful Nushell scripts to enhance productivity and streamline workflows.

## Requirements

- [Nushell](https://www.nushell.sh/) version 0.51 or higher.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/brendon-felix/nushell-tools.git
   ```

2. Navigate to the cloned repository:

   ```bash
   cd nushell-tools
   ```

3. Make the scripts executable (if needed):

   ```bash
   chmod +x *.nu
   ```

## Usage

1. To execute a script, run:

   ```bash
   nu script_name.nu
   ```

   Replace `script_name.nu` with the name of the script you want to use.

## Available Scripts 

- `bfm.nu`: Build, save and flash bootleg BIOS binaries using DediProg's CLI.
- `siofw.nu`: Replace SIO firmware with a debug firmware binary.
