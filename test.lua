--

require("mframework")
local LuaUnit = require("luaunit/luaunit")

TestMFramework = {}

function TestMFramework:setUp()
   self:resetClass()
end

function TestMFramework:resetClass()
   self.Animal = MClass("Animal")
   {
      public = {
         Animal = MMethod(MString),
         name = MString("Josh"),
         
         getSpecies = MMethod() (MString),
         setSpecies = MMethod(MString)
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
end

function TestMFramework:test01PublicAndProtected()
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
end

function TestMFramework:test02Inheritance()
   local Animal = self.Animal
   local Dog = MClass("Dog", Animal)
   {
      Dog = MMethod(MString),
      bark = MMethod(),

      translate = MMethod(MString) (MString),
      
      getBreed = MMethod() (MString),
      setBreed = MMethod(MString),

      protected = {
         breed = MString("Mongrel")
      }
   }

   function Dog:Dog(breed)
      self:Animal("dog")
      self.breed = breed
   end

   function Dog:bark()
      return "Whoouf"
   end

   function Dog:translate(message)
      return Dog:bark()
   end

   function Dog:getBreed()
      return self.breed
   end

   function Dog:setBreed(breed)
      self.breed = breed
   end

   local Tosha = Dog.new("mongrel")

   assertEquals(Tosha:getSpecies(), "dog")
   assertError(
      function()
         local temp = Tosha.species -- unaccessable
      end)
   assertEquals(Tosha:getBreed(), "mongrel")
   assertError(
      function()
         local temp = Tosha.breed -- unaccessable
      end)
end

function TestMFramework:test03MultipleInheritance()
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

   --mDebugTable(Hammer)
   
   local aHammer = Hammer.new()
   
   assertEquals(aHammer:repair(), "Repaired")
   assertEquals(aHammer:attack(), "Attacked")
   assertEquals(aHammer:sound(), "Wush!")
   assertEquals(aHammer.toolType, "tool")
   assertEquals(aHammer.weaponType, "weapon")
   assertEquals(aHammer.material, "wood")
end

function TestMFramework:test04NestedInheritance()
   local Food = MClass("Food", MObject)
   {
      Food = MMethod(),
      healthy = MBoolean(true)
   }

   function Food:Food()
   end
   
   local Fruit = MClass("Fruit", Food)
   {
      Fruit = MMethod(),
      juicy = MBoolean(true)
   }

   function Fruit:Fruit()
      self:Food()
   end

   local Vegetable = MClass("Vegetable", Food)
   {
      Vegetable = MMethod(),
      tasty = MBoolean(true)
   }

   function Vegetable:Vegetable()
      self:Food()
   end

   local Tomato = MClass("Tomato", Fruit, Vegetable)
   {
      Tomato = MMethod()      
   }

   function Tomato:Tomato()
      self:Fruit()
      self:Vegetable()
   end
   
   local aTomato = Tomato.new()

   assertEquals(aTomato.juicy, true)
   assertEquals(aTomato.tasty, true)
   assertEquals(aTomato.healthy, true)
end

function TestMFramework:test05IsInstance()
   local Food = MClass("Food", MObject)
   {
      Food = MMethod(),
      healthy = MBoolean(true)
   }

   function Food:Food()
   end
   
   local Fruit = MClass("Fruit", Food)
   {
      Fruit = MMethod(),
      juicy = MBoolean(true)
   }

   function Fruit:Fruit()
      self:Food()
   end

   local Vegetable = MClass("Vegetable", Food)
   {
      Vegetable = MMethod(),
      tasty = MBoolean(true)
   }

   function Vegetable:Vegetable()
      self:Food()
   end

   local Peach = MClass("Peach", Fruit)
   {
      Peach = MMethod()
   }

   function Peach:Peach()
   end
   
   local Onion = MClass("Onion", Vegetable)
   {
      Onion = MMethod()
   }

   function Onion:Onion()
      self.tasty = false
   end

   local aPeach = Peach.new()
   local anOnion = Onion.new()

   assertError(function() Peach.instanceOf() end)
   assertEquals(Peach.instanceOf(Peach), true)
   assertEquals(aPeach:instanceOf(Peach), true)
   assertEquals(Peach.instanceOf(Fruit), true)
   assertEquals(aPeach:instanceOf(Fruit), true)
   assertEquals(Peach.instanceOf(Food), true)
   assertEquals(aPeach:instanceOf(Food), true)
   assertEquals(Peach.instanceOf(MObject), true)
   assertEquals(aPeach:instanceOf(MObject), true)
   assertEquals(Peach.instanceOf(Vegetable), false)
   assertEquals(aPeach:instanceOf(Vegetable), false)
   assertEquals(Peach.instanceOf(Onion), false)
   assertEquals(aPeach:instanceOf(Onion), false)

   assertEquals(Onion.instanceOf(Onion), true)
   assertEquals(anOnion:instanceOf(Onion), true)
   assertEquals(Onion.instanceOf(Vegetable), true)
   assertEquals(anOnion:instanceOf(Vegetable), true)
   assertEquals(Onion.instanceOf(Food), true)
   assertEquals(anOnion:instanceOf(Food), true)
   assertEquals(Onion.instanceOf(MObject), true)
   assertEquals(anOnion:instanceOf(MObject), true)
   assertEquals(Onion.instanceOf(Fruit), false)
   assertEquals(anOnion:instanceOf(Fruit), false)
   assertEquals(Onion.instanceOf(Peach), false)
   assertEquals(anOnion:instanceOf(Peach), false)
end

function TestMFramework:test06MembersRedefination()
   local Animal = self.Animal

   local Turtle = MClass("Turtle", Animal)
   {
      Turtle = MMethod(),
      crawl = MMethod()
   }
   
   function Turtle:Turtle()
      self:Animal("turtle")
   end

   function Turtle:crawl()
      mDebug("Turtle: I'm crawling..")
   end

   function testRedefination()
      Turtle.crawl = function(self)
         mDebug("Turtle: I'm crawling the other way...")
      end
   end

   assertError(testRedefination)
      
end

function TestMFramework:test07PublicProtectedNamespaceCollision()
   assertError(
      function()

         local Chair = MClass("Chair", MObject)
         {
            legs = MNumber(4),
            protected = {
               legs = MNumber(3)
            }
         }

      end)
   
end

function TestMFramework:test08PublicProtectedReserved()
   assertError(
      function()

         local Spoon = MClass("Spoon", MObject)
         {
            public = MMethod()
         }
      end)

   assertError(
      function()

         local Fork = MClass("Fork", MObject)
         {
            protected = MNumber()
         }
      end)
   
end

function TestMFramework:test09StaticMethods()
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

end


function TestMFramework:test10ClassMethodsDefinationsValidation()
   local Shoe = MClass("Shoe", MObject)
   {
      Shoe = MMethod(),
      stomp = MMethod()
   }

   function Shoe:Shoe()
   end

   local aShoe

   assertError(function() aShoe = Shoe.new() end)
   
end

function TestMFramework:test11VirtualMethods()
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
end

function TestMFramework:test12DefaultValuesForStandardTypes()
   -- MNumber

   local NumberTestGood = MClass("NumberTestGood", MObject)
   {
      NumberTestGood = MMethod(),
      number = MNumber(12)
   }

   function NumberTestGood:NumberTestGood()
   end
   
   local aNumberTest = NumberTestGood.new()
   assertEquals(aNumberTest.number, 12)
   
   assertError(
      function()
         local NumberTestBad = MClass("NumberTestBad", MObject)
         {
            NumberTestBad = MMethod(),
            number = MNumber("bla")
         }
      end)
   
   -- MString

   local StringTestGood = MClass("StringTestGood", MObject)
   {
      StringTestGood = MMethod(),
      string = MString("bla")
   }

   function StringTestGood:StringTestGood()
   end
   
   local aStringTest = StringTestGood.new()
   assertEquals(aStringTest.string, "bla")
   
   assertError(
      function()
         local StringTestBad = MClass("StringTestBad", MObject)
         {
            StringTestBad = MMethod(),
            string = MString(false)
         }
      end)
   
   -- MBoolean

   local BooleanTestGood = MClass("BooleanTestGood", MObject)
   {
      BooleanTestGood = MMethod(),
      boolean = MBoolean(true)
   }

   function BooleanTestGood:BooleanTestGood()
   end
   
   local aBooleanTest = BooleanTestGood.new()
   assertEquals(aBooleanTest.boolean, true)
   
   assertError(
      function()
         local BooleanTestBad = MClass("BooleanTestBad", MObject)
         {
            BooleanTestBad = MMethod(),
            boolean = MBoolean({})
         }
      end)
   
   -- MTable

   local TableTestGood = MClass("TableTestGood", MObject)
   {
      TableTestGood = MMethod(),
      table = MTable({})
   }

   function TableTestGood:TableTestGood()
   end
   
   local aTableTest = TableTestGood.new()
   assertEquals(aTableTest.table, {})
   
   assertError(
      function()
         local TableTestBad = MClass("TableTestBad", MObject)
         {
            TableTestBad = MMethod(),
            table = MTable(12)
         }
      end)
   
end

function TestMFramework:test13ValidationOfModificationOfNonMethodStandardMembers()
   local Variant = MClass("Variant", MObject)
   {
      Variant = MMethod(),
      number = MNumber(),
      string = MString(),
      boolean = MBoolean(),
      table = MTable()
   }

   function Variant:Variant()
   end

   local aVariant = Variant.new()

   aVariant.number = 12
   assertError(
      function()
         aVariant.number = "bla"
      end)

   aVariant.string = "bla"
   assertError(
      function()
         aVariant.string = false
      end)

   aVariant.boolean = false
   assertError(
      function()
         aVariant.boolean = {}
      end)

   aVariant.table = {}
   assertError(
      function()
         aVariant.table = 12
      end)

end

function TestMFramework:test14AssignmentValidationOfCustomClassAsAClassMember()
   local Wing = MClass("Wing", MObject)
   {
      Wing = MMethod()
   }

   function Wing:Wing()
   end

   local Plane = MClass("Plane", MObject)
   {
      Plane = MMethod(),
      leftWing = Wing(),
      rightWing = Wing()
   }

   function Plane:Plane()
   end

   local Hat = MClass("Hat", MObject)
   {
      Hat = MMethod()
   }

   function Hat:Hat()
   end
   
   local aPlane = Plane.new()

   assertError(
      function()
         aPlane.leftWing = Hat.new()
      end)         

   assertError(
      function()
         aPlane.rightWing = {"just garbage"}
      end)
   
end

function TestMFramework:test15AssignmentValidationOfStaticMember()

   local Sample = MClass("Sample", MObject)
   {
      Sample = MMethod()
   }

   function Sample:Sample()
   end
   
   local Variant = MClass("Variant", MObject)
   {
      Variant = MMethod(),

      static = {
         number = MNumber(),
         string = MString(),
         boolean = MBoolean(),
         table = MTable(),
         object = Sample()
      }
   }

   function Variant:Variant()
   end

   Variant.number = 12
   assertError(
      function()
         Variant.number = "bla"
      end)

   Variant.string = "bla"
   assertError(
      function()
         Variant.string = false
      end)

   Variant.boolean = false
   assertError(
      function()
         Variant.boolean = {}
      end)

   Variant.table = {}
   assertError(
      function()
         Variant.table = 12
      end)

   Variant.object = Sample.new()
   assertError(
      function()
         Variant.object = {'bla'}
      end)
   assertError(
      function()
         Variant.object = 'bla'
      end)
   
end

function TestMFramework:test16ParentClassesStaticMembersAccess()
   local Car = MClass("Car", MObject)
   {
      Car = MMethod(),
      static = {
         wheels = MNumber(4)
      }
   }

   function Car:Car()
   end

   local Humvee = MClass("Humvee", Car)
   {
      Humvee = MMethod()
   }

   function Humvee:Humvee()
   end

   local SUV = MClass("SUV", Car)
   {
      SUV = MMethod()
   }

   function SUV:SUV()
   end

   assertEquals(Car.wheels, 4)
   assertEquals(Humvee.wheels, 4)
   assertEquals(SUV.wheels, 4)

   Car.wheels = 8
   assertEquals(Car.wheels, 8)
   assertEquals(Humvee.wheels, 8)
   assertEquals(SUV.wheels, 8)
   
   Humvee.wheels = 12
   assertEquals(Car.wheels, 12)
   assertEquals(Humvee.wheels, 12)
   assertEquals(SUV.wheels, 12)
   
   SUV.wheels = 16
   assertEquals(Car.wheels, 16)
   assertEquals(Humvee.wheels, 16)
   assertEquals(SUV.wheels, 16)
   
end

function TestMFramework:test17UndeclaredMembersAccess()
   local Lizard = MClass("Lizard", MObject)
   {
      Lizard = MMethod()
   }

   function Lizard:Lizard()
   end
   
   local aLizard = Lizard.new()
   
   assertError(
      function()
         temp = aLizard.wings
      end)

   assertError(
      function()
         aLizard.wings = 2
      end)

   assertError(
      function()
         aLizard:fly()
      end)
   
end

function TestMFramework:test18MethodArgumentsValidation()
   local Person = MClass("Person", MObject)
   {
      Person = MMethod(),
      setName = MMethod(MString),
      addRelative = MMethod(MObject)
   }

   function Person:Person()
   end

   function Person:setName()
   end
   
   function Person:addRelative()
   end

   local aPerson = Person.new()

   assertError(
      function()
         aPerson:setName("foo", "bar")
      end)
   
   assertError(
      function()
         aPerson:setName()
      end)
   
   assertError(
      function()
         aPerson:setName(12)
      end)
   
   aPerson:addRelative(Person.new())
   assertError(
      function()
         aPerson:addRelative({})
      end)
   
end

function TestMFramework:test19MethodResultsValidation()
   local Arm = MClass("Arm", MObject)
   {
      Arm = MMethod(),
      getFingerLengths = MMethod() (MNumber, MNumber, MNumber, MNumber, MNumber),
      getFingerLengthsRight = MMethod() (MNumber, MNumber, MNumber, MNumber, MNumber),
      isLeft = MMethod() (MBoolean),
      isLeftRight = MMethod() (MBoolean),
      otherHand = MMethod() (MObject)
   }

   function Arm:Arm()
   end

   function Arm:getFingerLengths()
      return 6, 6, 7
   end

   function Arm:getFingerLengthsRight()
      return 6, 6, 7, 6.5, 5.5
   end

   function Arm:isLeft()
      return "right"
   end

   function Arm:isLeftRight()
      return true
   end

   function Arm:otherHand()
      return "left"
   end

   local anArm = Arm.new()

   local temp
   
   assertError(
      function()
         temp = anArm:getFingerLengths()
      end)

   assertEquals({anArm:getFingerLengthsRight()}, {6, 6, 7, 6.5, 5.5})
   
   assertError(
      function()
         temp = anArm:isLeft()
      end)

   assertEquals(anArm:isLeftRight(), true)
   
   assertError(
      function()
         temp = anArm:otherHand()
      end)
   
end

function TestMFramework:test20DefaultClassConstructor()
   local Property = MClass("Property", MObject)
   {
      Property = MMethod(),
      owner = MString()
   }

   function Property:Property()
      self.owner = "SomeOwner"
   end

   local RealEstate = MClass("RealEstate", Property)
   {
      address = MString()
   }

   local Home = MClass("Home", MObject)
   {
      Home = MMethod(),
      primary = MBoolean()
   }

   function Home:Home()
      self.primary = false
   end

   local Cottage = MClass("Cottage", RealEstate, Home)
   {
   }

   local aCottage = Cottage.new()

   assertEquals(aCottage.owner, "SomeOwner")
   assertEquals(aCottage.primary, false)

   local Hut = MClass("Hut", MObject)
   {      
   }

   local aHut = Hut.new()
end

function TestMFramework:test21ClassReferenceInClassDefinition()
   local Leg = MClass("Leg", MObject)
   {
      otherLeg = MClass(),
      setOtherLeg = MMethod(MClass())
   }

   function Leg:setOtherLeg(otherLeg)
      self.otherLeg = otherLeg
   end
   
   local leftLeg = Leg.new()
   local rightLeg = Leg.new()

   leftLeg.otherLeg = rightLeg
   rightLeg.otherLeg = leftLeg
   
   assertEquals(leftLeg.otherLeg == rightLeg, true)
   assertEquals(rightLeg.otherLeg == leftLeg, true)

   local anotherLeftLeg = Leg.new()
   local anotherRightLeg = Leg.new()

   --mDebugTable(Leg, "Leg")
   --mDebugTable(anotherRightLeg, "anotherRightLeg")
   
   anotherLeftLeg:setOtherLeg(anotherRightLeg)
   anotherRightLeg:setOtherLeg(anotherLeftLeg)
   
   assertEquals(anotherLeftLeg.otherLeg == anotherRightLeg, true)
   assertEquals(anotherRightLeg.otherLeg == anotherLeftLeg, true)
end

function TestMFramework:test22DotInsteadOfColonInMethodCall()
   local Lion = MClass("Lion", MObject)
   {
      roar = MMethod() (MString)
   }

   function Lion:roar()
      return "Rwooorrw!!!"
   end
   
   local aLion = Lion.new()

   assertEquals(aLion:roar(), "Rwooorrw!!!")
   assertError(
      function()
         aLion.roar()
      end)
   
end

function TestMFramework:test23ClassMetamethods()
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
   
end

function TestMFramework:test24AssignNilToMembers()
   local Variant = MClass("Variant", MObject)
   {
      number = MNumber(),
      string = MString(),
      boolean = MBoolean(),
      table = MTable(),
      object = MObject()
   }

   local aVariant = Variant.new()

   aVariant.number = 12
   assertEquals(aVariant.number, 12)
   aVariant.number = nil
   assertEquals(aVariant.number, nil)
   
   aVariant.string = "bla"
   assertEquals(aVariant.string, "bla")
   aVariant.string = nil
   assertEquals(aVariant.string, nil)
   
   aVariant.boolean = false
   assertEquals(aVariant.boolean, false)
   aVariant.boolean = nil
   assertEquals(aVariant.boolean, nil)
   
   aVariant.table = {}
   assertEquals(aVariant.table, {})
   aVariant.table = nil
   assertEquals(aVariant.table, nil)
   
   aVariant.object = Variant.new()
   assertEquals(aVariant.object:instanceOf(Variant), true)
   aVariant.object = nil
   assertEquals(aVariant.object, nil)
   
end

function TestMFramework:test25Signals()
   local TrafficLight = MClass("TrafficLight", MObject)
   {
      light = MString("red"),
      lightChanged = MSignal(MString),
      changeLight = MMethod(MString)
   }

   function TrafficLight:changeLight(color)
      if color == "red" or color == "yellow" or color == "green" then
         self.light = color
      end
   end

   local ControlPanel = MClass("ControlPanel", MObject)
   {
      ControlPanel = MMethod(),
      pushButton = MMethod(MString),
      greenPushed = MSignal(),
      redPushed = MSignal(),
      setGreen = MMethod(),
      setRed = MMethod(),
      buttonPushed = MSignal(MString)
   }

   function ControlPanel:ControlPanel()
      mConnect(self.greenPushed, self.setGreen)
      mConnect(self.redPushed, self.setRed)
   end
   
   function ControlPanel:pushButton(buttonColor)
      if buttonColor == "green" then
         self:greenPushed()
      elseif buttonColor == "red" then
         self:redPushed()
      end
   end

   function ControlPanel:setGreen()
      self:buttonPushed("green")
   end
   
   function ControlPanel:setRed()
      self:buttonPushed("red")
   end

   local aTrafficLight = TrafficLight.new()
   local aControlPanel = ControlPanel.new()

   mConnect(aControlPanel.buttonPushed, aTrafficLight.changeLight)

   assertEquals(aTrafficLight.light, "red")
   aControlPanel:pushButton("green")
   assertEquals(aTrafficLight.light, "green")
   aControlPanel:pushButton("red")
   assertEquals(aTrafficLight.light, "red")
   
end

LuaUnit:run()

print("\n --- \n")
mFlushDebug()
