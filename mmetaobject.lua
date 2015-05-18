-- MMetaObject

-- MMethod base structure
local function MMethodCollector(template, arguments)
   local collector = {}
   collector.M_type = "collector"
   collector.M_collectorType = template.M_collectorType
   collector.M_virtual = template.M_virtual
   collector.M_arguments = {}
   collector.M_results = {}
   for i, v in ipairs(arguments) do
      if v == MClass then
         table.insert(collector.M_arguments, v())
      elseif(v.M_type == "class") then
         table.insert(collector.M_arguments, v())
      elseif(v.M_type == "collector") then
         table.insert(collector.M_arguments, v)
      elseif(v.M_template ~= nil) then -- MClass() self reference
         table.insert(collector.M_arguments, v)
      end
   end

   collector.__call = function(self, ...) -- Should return method collector
      for i, v in ipairs(arg) do
         if v == MClass then
            table.insert(self.M_results, v())
         elseif(v.M_type == "class") then
            table.insert(self.M_results, v())
         elseif(v.M_type == "collector") then
            table.insert(self.M_results, v)
         elseif(v.M_template ~= nil) then -- MClass() self reference
            table.insert(self.M_results, v)
         end
      end

      return self
   end
   
   setmetatable(collector, collector)

   return collector
end

local function MMethod(...)
   return MMethodCollector({M_type = "collector", M_collectorType = "method", M_virtual = false}, arg)
end

local function MMethodVirtual(...)
   return MMethodCollector({M_type = "collector", M_collectorType = "method", M_virtual = true}, arg)
end

-- Object skeleton

-- Class structure traversal
local function findMemberForClass(class, name)
   local result = {
      collector = nil,
      member = nil,
      scope = nil,
      class = nil
   }
   if class.M_className == "MObject" then
      return result
   elseif class.M_public[name] ~= nil then
      result.collector = class.M_public[name]

      if result.collector.M_collectorType == "method" then
         if class.M_defPublic[name] ~= nil then
            result.member = class.M_defPublic[name].value
         end
      else
         result.member = result.collector.M_value
      end
      
      result.scope = "public"
      result.class = class
   elseif class.M_protected[name] ~= nil then
      result.collector = class.M_protected[name]

      if result.collector.M_collectorType == "method" then
         if class.M_defProtected[name] ~= nil then
            result.member = class.M_defProtected[name].value
         end
      else
         result.member = result.collector.M_value
      end
      
      result.scope = "protected"
      result.class = class
   elseif class.M_static[name] ~= nil then
      result.collector = class.M_static[name]

      if result.collector.M_collectorType == "method" then
         if class.M_defStatic[name] ~= nil then
            result.member = class.M_defStatic[name].value
         end
      else
         if class.M_defStatic[name] ~= nil then
            result.member = class.M_defStatic[name].value
         else
            result.member = result.collector.M_value
         end
      end

      result.scope = "static"
      result.class = class
   else
      local continue = true;
      local i = 1;
      
      while continue do
         if i <= #class.M_parents then
            result = findMemberForClass(class.M_parents[i], name)

            if result.collector ~= nil then
               continue = false
            end
         else
            continue = false
         end

         i = i + 1
      end
   end

   return result
end

local function findMemberForObject(object, name)
   local result = findMemberForClass(object.M_class, name)

   if result.collector ~= nil and result.collector.M_collectorType ~= "method" then -- try substitute class vaule by object value
      if result.scope == "public" and object.M_defPublic[name] ~= nil then
         result.member = object.M_defPublic[name].value
      elseif result.scope == "protected" and object.M_defProtected[name] ~= nil then
         result.member = object.M_defProtected[name].value
      end
   end

   return result
end

local function MCreateMethodCaller(object, methodName, method, collector, openProtected)

   local caller = function(...)
      if openProtected then
         object.M_protectedOpen = object.M_protectedOpen + 1
      end

      -- Argument validation
      -- Checking for 'self' as arg[1]
      if #arg == 0 or type(arg[1]) ~= "table" or arg[1].M_type ~= "object" then
         error("Method '" .. object.M_className .. ":" .. methodName .. "()' called with '.' instead of ':'", 2)
      end
      
      if #arg - 1 ~= #collector.M_arguments then
         error("Method '" .. object.M_className .. ":" .. methodName .. "()' called with wrong number of arguments - " .. tostring(#arg - 1) .. " instead of " .. tostring(#collector.M_arguments), 2)
      end

      for i, argumentDefinition in ipairs(collector.M_arguments) do
         local argument = arg[i + 1]

         local argType = type(argument)
         if argType ~= "table" or (argument.M_type == nil) then
            local valid = false
            local typeClassName = ""

            valid = argumentDefinition.M_class.validate(argument)
            
            if argType == "number" then
               typeClassName = MNumber.M_className
            elseif argType == "string" then
               typeClassName = MString.M_className
            elseif argType == "boolean" then
               typeClassName = MBoolean.M_className
            elseif argType == "table" then
               typeClassName = MTable.M_className
            elseif argType == "userdata" then
               typeClassName = MUserdata.M_className
            end

            if not valid then
               error("In '" .. object.M_className .. ":" .. methodName .. "()' call, #" .. tostring(i) .. " argument has wrong type - " .. typeClassName .. " instead of " .. argumentDefinition.M_className, 2)
            end
         else
            if not argument:instanceOf(argumentDefinition.M_class) then
               error("In '" .. object.M_className .. ":" .. methodName .. "()' call, #" .. tostring(i) .. " argument has wrong type - " .. argument.M_className .. " instead of " .. argumentDefinition.M_className, 2)
            end
         end
      end

      -- Call
      local results = {method(unpack(arg))} -- self already passed

      -- Results validation
      if #results ~= #collector.M_results then
         error("Method '" .. object.M_className .. ":" .. methodName .. "()' returned wrong number of results - " .. tostring(#results) .. " instead of " .. tostring(#collector.M_results), 2)
      end

      for i, resultDefinition in ipairs(collector.M_results) do
         local result = results[i]

         local resType = type(result)
         if resType ~= "table" or (result.M_type == nil) then
            local valid = false
            local typeClassName = ""


            valid = resultDefinition.M_class.validate(result)

            if resType == "number" then
               typeClassName = MNumber.M_className
            elseif resType == "string" then
               typeClassName = MString.M_className
            elseif resType == "boolean" then
               typeClassName = MBoolean.M_className
            elseif resType == "table" then
               typeClassName = MTable.M_className
            elseif resType == "userdata" then
               typeClassName = MUserdata.M_className
            end

            if not valid then
               error("In '" .. object.M_className .. ":" .. methodName .. "()' call, #" .. tostring(i) .. " result has wrong type - " .. typeClassName .. " instead of " .. resultDefinition.M_className, 2)
            end
         else
            if not result:instanceOf(resultDefinition.M_class) then
               error("In '" .. object.M_className .. ":" .. methodName .. "()' call, #" .. tostring(i) .. " result has wrong type - " .. result.M_className .. " instead of " .. resultDefinition.M_className, 2)
            end
         end
      end
      
      if openProtected then
         object.M_protectedOpen = object.M_protectedOpen - 1
      end

      return unpack(results)
   end

   return caller   
end

local function createMetamethod(name)
   local metamethod = function(...)
      local self = arg[1]

      return self[name](unpack(arg))
   end

   return metamethod
end

local MMetaObjectSkeleton = {
   __add = createMetamethod("__add"),
   __sub = createMetamethod("__sub"),
   __mul = createMetamethod("__mul"),
   __div = createMetamethod("__div"),
   __mod = createMetamethod("__mod"),
   __pow = createMetamethod("__pow"),
   __concat = createMetamethod("__concat"),
   __eq = createMetamethod("__eq"),
   __lt = createMetamethod("__lt"),
   __le = createMetamethod("__le"),
   __index = function(self, name)
      --- Object members getter.
      --- Performs scope widening for protected lookups.

      --mDebug("MMetaObjectSkeleton __index: " .. tostring(name))

      function createClassCallWrapper(class, methodName)
         function wrapper(self, ...)
            -- Checking for 'self' as arg[1]
            if self == nil or type(self) ~= "table" or self.M_type ~= "object" then
               error("Method '" .. class.M_className .. ":" .. methodName .. "()' called with '.' instead of ':'", 2)
            end
            return class[methodName](unpack(arg))
         end

         return wrapper
      end

      -- instanceOf
      if name == "instanceOf" then
         return createClassCallWrapper(self.M_class, name)
      end

      local response = findMemberForObject(self, name)

      if (response.scope == "protected" and self.M_protectedOpen > 0) or response.scope == "public" then
         if response.collector and response.collector.M_collectorType == "method" and response.collector.M_virtual and type(response.member) ~= "function" then
            error("Call to undefined virtual method '" .. self.M_className .. ":" .. name .. "()'.", 2)
         elseif response.collector and response.collector.M_collectorType == "method" then
            return MCreateMethodCaller(self, name, response.member, response.collector, true)
         else
            return response.member
         end
      end

      error("Class member '" .. self.M_className .. "." .. name .. "' is not accessible or not defined.", 2)
   end,
   __newindex = function(self, name, value)
      --- Object members setter.
      --- Checks members assignment.
      --print("MMetaObjectSkeleton __newindex: " .. tostring(name) .. " -- " .. tostring(value))

      local response = findMemberForObject(self, name)

      if response.collector and response.collector.M_collectorType == "class" then
         if response.scope == "public" then
            if response.collector.M_className == "MNumber" or response.collector.M_className == "MString" or response.collector.M_className == "MBoolean" or response.collector.M_className == "MTable" or response.collector.M_className == "MUserdata" then -- Standard type
               if not response.collector.M_class.validate(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "' : " .. tostring(value), 2)
               end
            else
               if value ~= nil and not response.collector.M_class.instanceOf(value) then
                  error("Bad value for '" .. self.M_className .. "." .. name .. "'. Should be '" .. response.collector.M_className .."' object.", 2)
               end               
            end

            self.M_defPublic[name] = {value = value}

            return
         elseif response.scope == "protected" and self.M_protectedOpen > 0 then
               if response.collector.M_className == "MNumber" or response.collector.M_className == "MString" or response.collector.M_className == "MBoolean" or response.collector.M_className == "MTable" or response.collector.M_className == "MUserdata" then
                  if not response.collector.M_class.validate(value) then
                     error("Bad value for '" .. self.M_className .. "." .. name .. "' : " .. tostring(value), 2)
                  end
               else
                  if value ~= nil and not response.collector.M_class.instanceOf(value) then
                     error("Bad value for '" .. self.M_className .. "." .. name .. "'. Should be '" .. response.collector.M_className .."' object.", 2)
                  end               
               end

               self.M_defProtected[name] = {value = value}

            return
         end
      end

      error("Class member '" .. self.M_className .. "." .. name .. "' is not accessible or not defined.", 2)
   end
}

local MMetaObject = {
   MMethod = MMethod,
   MMethodVirtual = MMethodVirtual,
   MMetaObjectSkeleton = MMetaObjectSkeleton,
   findMemberForClass = findMemberForClass
}

return MMetaObject
