-- MMetaClass

local MMetaObject = require('mmetaobject')
local MMetaObjectSkeleton = MMetaObject.MMetaObjectSkeleton
local findMemberForClass = MMetaObject.findMemberForClass

-- Class skeletons
local function VerifyClassDefination(class)

   for name, value in pairs(class.M_public) do
      if (value.M_collectorType == "method" and value.M_virtual == false) and
         (type(class.M_defPublic[name]) == "nil" or (type(class.M_defPublic[name]) == "table" and type(class.M_defPublic[name].value) ~= "function")) then
         error("Non-virtual method '" .. class.M_className .. ":" .. name .. "()' is not defined.", 3)
      end
   end
   
   for name, value in pairs(class.M_protected) do
      if (value.M_collectorType == "method" and value.M_virtual == false)
         and (type(class.M_defProtected[name]) == "nil" or (type(class.M_defProtected[name]) == "table" and type(class.M_defProtected[name].value) ~= "function")) then
         error("Non-virtual method '" .. class.M_className .. ":" .. name .. "()' is not defined.", 3)
      end
   end
   
   for name, value in pairs(class.M_static) do
      if (value.M_collectorType == "method" and value.M_virtual == false) and
         (type(class.M_defStatic[name]) == "nil" or (type(class.M_defStatic[name]) == "table" and type(class.M_defStatic[name].value) ~= "function")) then
         error("Non-virtual method '" .. class.M_className .. ":" .. name .. "()' is not defined.", 3)
      end
   end

   return
   
end

local MClassSkeleton = {
   new = function(self, ...)
      --- Constructs object
      local object = {}
      --print("NEW:")
      --print_r(self)

      VerifyClassDefination(self)
      
      object.M_type = "object"
      object.M_className = self.M_className
      object.M_class = self
      object.M_protectedOpen = 0
      object.M_defPublic = {}
      object.M_defProtected = {}

      setmetatable(object, MMetaObjectSkeleton)

      object[self.M_className](object, unpack(arg))
      
      return object
   end,
   instanceOf = function(self, ...)
      local result = false
      local continue = true
      
      if #arg < 1 then
         error(self.M_className .. ".instanceOf(): No classes were given.")
      end

      function checkOne(class, sample)
         if class.M_className == sample.M_className then
            return true
         else
            local found = false
            for i, v in ipairs(class.M_parents) do
               found = found or checkOne(v, sample)
            end

            return found
         end
      end

      for i, v in ipairs(arg) do
         result = result or checkOne(self, v)
      end

      return result
   end
}

local function ClassMethodWrapper(class, method)
   local class = class
   local method = method
   local wrapper = function(...)
      return method(class, unpack(arg))
   end

   return wrapper
end

local MMetaClassSkeleton = {
   __index = function(self, name)
      --- Index getter for class.
      --- Used to call 'new' method.
      
      --print("MMetaClassSkeleton __index: " .. tostring(name))

      if MClassSkeleton[name] ~= nil then
         return ClassMethodWrapper(self, MClassSkeleton[name])
      end

      if self.M_static[name] ~= nil then
         if self.M_static[name].M_collectorType ~= "method" and self.M_defStatic[name] ~= nil then
            return self.M_defStatic[name].value
         elseif self.M_static[name].M_collectorType ~= "method" and self.M_static[name].M_value ~= nil then
            return self.M_static[name].M_value
         elseif self.M_static[name].M_collectorType == "method" then
            return ClassMethodWrapper(self, self.M_defStatic[name].value)
         else
            return
         end
      end

      local response = findMemberForClass(self, name)

      if response.scope == "static" and response.collector.M_collectorType ~= "method" then
         return response.member
      end
      
   end,
   __newindex = function(self, name, value)
      --- Index setter for class.
      --- Used to set method definations.

      --mDebug("MMetaClassSkeleton __newindex: " .. tostring(name) .. " -- " .. tostring(value))

      if self.M_public[name] ~= nil then
         if self.M_defPublic[name] ~= nil then
            error("Redefination attempt of " .. self.M_className .. ":" .. name, 2)
         end
         self.M_defPublic[name] = {value = value}
      elseif self.M_protected[name] ~= nil then
         if self.M_defProtected[name] ~= nil then
            error("Redefination attempt of " .. self.M_className .. ":" .. name, 2)
         end
         self.M_defProtected[name] = {value = value}
      elseif self.M_static[name] ~= nil then
         if self.M_defStatic[name] ~= nil and self.M_static[name].M_collectorType == "method" then
            error("Redefination attempt of " .. self.M_className .. ":" .. name, 2)
         end

         if self.M_static[name].M_collectorType == "class" then
            if self.M_static[name].M_className == "MNumber" or self.M_static[name].M_className == "MString" or self.M_static[name].M_className == "MBoolean" or self.M_static[name].M_className == "MTable" or self.M_static[name].M_className == "MUserdata" then
               if not self.M_static[name].M_class.validate(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "' : " .. tostring(value), 2)
               end
            else
               if not self.M_static[name].M_class.instanceOf(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "'. Should be '" .. self.M_static[name].M_className .."' object.", 2)
               end               
            end
         end
         
         self.M_defStatic[name] = {value = value}
      else
         local response = findMemberForClass(self, name)

         if response.scope == "static" and response.collector.M_collectorType ~= "method" then
            -- Validation
            if response.collector.M_className == "MNumber" or response.collector.M_className == "MString" or response.collector.M_className == "MBoolean" or response.collector.M_className == "MTable" or response.collector.M_className == "MUserdata" then
               if not response.collector.M_class.validate(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "' : " .. tostring(value), 2)
               end
            else
               if not response.collector.M_class.instanceOf(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "'. Should be '" .. response.collector.M_className .."' object.", 2)
               end               
            end

            -- Assignment
            response.class.M_defStatic[name] = {value = value}
         end
      end
   end,
   __call = function(self, ...)
      return {
         M_type = "collector",
         M_collectorType = "class",
         M_className = self.M_className,
         M_class = self
             }
   end
}

-- Class structure
local function MClassCollector(template)
   --- Returns callable collector for
   --- class members collection
   
   local collector = {
      M_template = template,
      __call = function(self, members)
         --- Creates class instance and
         --- populates it with members
         
         local class = {}

         --- Member definations
         class.M_defPublic = {}
         class.M_defProtected = {}
         class.M_defStatic = {}
         
         --- Member declarations
         class.M_public = {}
         class.M_protected = {}
         class.M_static = {}

         -- Template filling
         class.M_type = self.M_template.M_type
         class.M_className = self.M_template.M_className
         class.M_parents = self.M_template.M_parents
         
         -- Member collection function
         local function collectMembers(src, dest)
            for k, v in pairs(src) do
               if type(v) == "table" and v.M_type == "collector" then
                  dest[k] = v
               end
            end
         end

         local function validateMembers(className, list)
            for k, v in pairs(list) do
               if v.M_collectorType == "class" and (v.M_className == "MNumber" or v.M_className == "MString" or v.M_className == "MBoolean" or v.M_className == "MTable" or v.M_className == "MUserdata") then
                  if v.M_value ~= nil and not v.M_class.validate(v.M_value) then
                     error("Bad default value for '" .. className .. "." .. k .. "' : " .. tostring(v.M_value), 3)
                  end
               end
            end
         end

         local function preprocessSelfReferences(table)
            for name, value in pairs(table) do
               if value.M_template ~= nil then -- MClass reference
                  table[name] = MMetaClassSkeleton.__call(class)
               elseif value.M_collectorType == "method" then
                  preprocessSelfReferences(value.M_arguments)
                  preprocessSelfReferences(value.M_results)
               end
            end
         end
         
         -- Checking 'protected' namespace
         if type(members) == "table" and members.protected ~= nil and (type(members.protected) ~= "table" or members.protected.M_type ~= nil) then
            error("In " .. self.M_template.M_className .. " class defination 'protected' keyword missused.", 2)
         end

         -- Collect protected members
         if type(members) == "table" and type(members.protected) == "table" then
            preprocessSelfReferences(members.protected)
            collectMembers(members.protected, class.M_protected)
            members.protected = nil

            -- Validate members
            validateMembers(self.M_template.M_className, class.M_protected)
         end

         
         -- Checking 'public' namespace
         if type(members) == "table" and members.public ~= nil and (type(members.public) ~= "table" or members.public.M_type ~= nil) then
            error("In " .. self.M_template.M_className .. " class defination 'public' keyword missused.", 2)
         end

         -- Collect public members
         if type(members) == "table" and type(members.public) == "table" then
            preprocessSelfReferences(members.public)
            collectMembers(members.public, class.M_public)
            members.public = nil

            -- Members will be validated after implicitly public members collection
         end

         
         -- Checking 'static' namespace
         if type(members) == "table" and members.static ~= nil and (type(members.static) ~= "table" or members.static.M_type ~= nil) then
            error("In " .. self.M_template.M_className .. " class defination 'static' keyword missused.", 2)
         end

         -- Collect static members
         if type(members) == "table" and type(members.static) == "table" then
            preprocessSelfReferences(members.static)
            collectMembers(members.static, class.M_static)
            members.static = nil

            -- Validate members
            validateMembers(self.M_template.M_className, class.M_static)
         end
         
         
         -- Collect all other implicitly public members
         if type(members) == "table" then
            preprocessSelfReferences(members)
            collectMembers(members, class.M_public)

            -- Validate members
            validateMembers(self.M_template.M_className, class.M_public)
         end         

         -- Setting up a default constructor
         local function createDefaultConstructor(class)
            local constructor = function(self)
               for i, parent in ipairs(class.M_parents) do
                  if parent.M_className ~= "MObject" then
                     self[parent.M_className](self)
                  end
               end
            end

            return constructor
         end


         if class.M_public[class.M_className] == nil then
            -- Inject default constructor
            class.M_public[class.M_className] = MMethod()
            class.M_defPublic[class.M_className] = {value = createDefaultConstructor(class)}
         end

         setmetatable(class, MMetaClassSkeleton)

         -- Check name collisions of public with protected and static
         for name, value in pairs(class.M_public) do
            if class.M_protected[name] ~= nil or class.M_static[name] ~= nil then
               error(class.M_className .. " class has member name collision in public/protected/static namespaces: " .. name, 2)
            end
         end

         -- Check name collisions of protected and static namespaces
         for name, value in pairs(class.M_static) do
            if class.M_protected[name] ~= nil then
               error(class.M_className .. " class has member name collision in public/protected/static namespaces: " .. name, 2)
            end
         end

         return class
      end
   }
   setmetatable(collector, collector)

   return collector
end

local function MClass(name, ...)
   --- Passes template to collector with
   --- type = class, className and parents properly defined
   
   local parents = arg
   if #arg <= 0 then
      parents = {MObject}
   end

   local template = {
      M_type = "class",
      M_className = name,
      M_parents = parents
   }

   return MClassCollector(template)
end

local MMetaClass = {
   MClass = MClass,
   findMemberForClass = findMemberForClass
}

return MMetaClass
