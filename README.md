# MFramework
Prototype of object-oriented framework for Lua writen in TDD paradigm.

# Rationale
This project was started as an exercise and a research if such task could be done in Lua and if yes, then how. It is purely academic, but while developing it, I understood how to design a much lighter real-life OOP framework for Lua. Unfortunately I wasn't able to even start it, due to lack of free time.

# Features
- Simple type validation
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

## Protected members
```lua
local Mika = self.Animal.new("cat")

assertEquals(Mika:getSpecies(), "cat")
assertError(
   function()
      local temp = Mika.species -- unaccessable
   end)

Mika:setSpecies("owl")
assertEquals(Mika:getSpecies(), "owl")
assertError(
   function()
      local temp = Mika.species -- unaccessable
   end)
```

## Multiple inheritance
```lua
local Tool = MClass("Tool", MObject)
{
   Tool = MMethod(),
   repair = MMethod() (MString),
   sound = MMethod() (MString),

   toolType = MString(),
   material = MString("wood")
}

function Tool:Tool()
   self.toolType = "tool"
end

function Tool:repair()
   return "Repaired"
end

function Tool:sound()
   return "Wush!"
end

local Weapon = MClass("Weapon", MObject)
{
   Weapon = MMethod(),
   attack = MMethod() (MString),
   sound = MMethod() (MString),

   weaponType = MString(),
   material = MString("steel")
}

function Weapon:Weapon()
   self.weaponType = "weapon"
end

function Weapon:attack()
   return "Attacked"
end

function Weapon:sound()
   return "Bash!"
end

local Hammer = MClass("Hammer", Tool, Weapon)
{
   Hammer = MMethod()
}

function Hammer:Hammer()
   self:Tool()
   self:Weapon()
end

local aHammer = Hammer.new()
   
assertEquals(aHammer:repair(), "Repaired")
assertEquals(aHammer:attack(), "Attacked")
assertEquals(aHammer:sound(), "Wush!")
assertEquals(aHammer.toolType, "tool")
assertEquals(aHammer.weaponType, "weapon")
assertEquals(aHammer.material, "wood")
```

## Static methods
```lua
local Bird = MClass("Bird", MObject)
{
   Bird = MMethod(),
   static = {
      spotedABird = MMethod(),
      birdsSpoted = MNumber(0)
   }
}

function Bird:spotedABird()
   self.birdsSpoted = self.birdsSpoted + 1
end

assertEquals(Bird.birdsSpoted, 0)
Bird.spotedABird()
assertEquals(Bird.birdsSpoted, 1)
Bird.spotedABird()
assertEquals(Bird.birdsSpoted, 2)
```

## Virtual methods
```lua
local Pants = MClass("Pants", MObject)
{
   Pants = MMethod(),
   zip = MMethodVirtual() (MString),
   unzip = MMethodVirtual() (MString),
   rezip = MMethodVirtual() (MString)
}

function Pants:Pants()
end

function Pants:zip()
   return("pants-zip")
end

function Pants:unzip()
   return("pants-unzip")
end

local Jeans = MClass("Jeans", Pants)
{
   Jeans = MMethod(),
   unzip = MMethod() (MString),
   rezip = MMethod() (MString)
}

function Jeans:Jeans()
   self:Pants()
end

function Jeans:unzip()
   return("jeans-unzip")
end

function Jeans:rezip()
   return("jeans-rezip")
end

local aPants = Pants.new()
local aJeans = Jeans.new()   

assertError(function() aPants:rezip() end) -- Call to undefined virtual method
assertEquals(aPants:zip(), "pants-zip")
assertEquals(aPants:unzip(), "pants-unzip")

assertEquals(aJeans:zip(), "pants-zip")
assertEquals(aJeans:unzip(), "jeans-unzip")
assertEquals(aJeans:rezip(), "jeans-rezip")
```

## Operators overload
```lua
local Integer = MClass("Integer", MObject)
{
   Integer = MMethod(MNumber),
   value = MNumber(0),
   __add = MMethod(MClass) (MClass),
   __sub = MMethod(MClass) (MClass),
   __mul = MMethod(MClass) (MClass),
   __div = MMethod(MClass) (MClass),
   __mod = MMethod(MClass) (MClass),
   __pow = MMethod(MClass) (MClass),
   __concat = MMethod(MClass) (MClass),
   __eq = MMethod(MClass) (MBoolean),
   __lt = MMethod(MClass) (MBoolean),
   __le = MMethod(MClass) (MBoolean)
}

function Integer:Integer(value)
   self.value = value
end

function Integer:__add(otherInt)
   return Integer.new(self.value + otherInt.value)
end
   
function Integer:__sub(otherInt)
   return Integer.new(self.value - otherInt.value)
end
   
function Integer:__mul(otherInt)
   return Integer.new(self.value * otherInt.value)
end
   
function Integer:__div(otherInt)
   return Integer.new(self.value / otherInt.value)
end
   
function Integer:__mod(otherInt)
   return Integer.new(self.value % otherInt.value)
end
   
function Integer:__pow(otherInt)
   return Integer.new(self.value ^ otherInt.value)
end

function Integer:__concat(otherInt)
   return Integer.new(self.value + otherInt.value)
end
   
function Integer:__eq(otherInt)
   return self.value == otherInt.value
end

function Integer:__lt(otherInt)
   return self.value < otherInt.value
end
   
function Integer:__le(otherInt)
   return self.value <= otherInt.value
end
   
local firstInteger = Integer.new(10)
local secondInteger = Integer.new(7)

assertEquals((firstInteger + secondInteger).value, 10 + 7)
assertEquals((firstInteger - secondInteger).value, 10 - 7)
assertEquals((firstInteger * secondInteger).value, 10 * 7)
assertEquals((firstInteger / secondInteger).value, 10 / 7)
assertEquals((firstInteger % secondInteger).value, 10 % 7)
assertEquals((firstInteger ^ secondInteger).value, 10 ^ 7)
assertEquals((firstInteger .. secondInteger).value, 10 + 7)
assertEquals(firstInteger == secondInteger, 10 == 7)
assertEquals(firstInteger < secondInteger, 10 < 7)
assertEquals(firstInteger <= secondInteger, 10 <= 7)
assertEquals(firstInteger > secondInteger, 10 > 7)
assertEquals(firstInteger >= secondInteger, 10 >= 7)
```

## More
For more please check [test.lua](../../blob/master/test.lua)
