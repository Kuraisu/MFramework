# MFramework
Prototype of object-oriented framework for Lua.

# Features
- Strongly typed
- Supports protected members
- Multiple inheritance
- Static methods
- Virtual methods
- Operators overload

# Simple usage

```lua
local Animal = MClass("Animal")
   {
      public = {
         Animal = MMethod(MString),        -- Constructor
         name = MString("Josh"),
         
         getSpecies = MMethod() (MString), -- Takes no arguments, returns string
         setSpecies = MMethod(MString)     -- Takes one string argument, returns none
      },
      protected = {
         species = MString("animal"),
         age = MNumber(0)
      }
   }

   function self.Animal:Animal(species)
      self.species = species
   end

   function self.Animal:getSpecies()
      return self.species
   end

   function self.Animal:setSpecies(species)
      self.species = species
   end
```

# Advanced usage

For more please check [test.lua](../../blob/master/test.lua)
