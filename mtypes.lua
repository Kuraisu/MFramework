-- MTypes

-- MObject base class
local MObject = {
   M_type = "class",
   M_className = "MObject",
   M_parents = {MObject}
}
MObject.__call = function(self)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MObject",
      M_class = MObject
          }
end

MObject.instanceOf = function(class)
   if type(class) == "table" and class.M_type == "object" and type(class.M_className) == "string" and type(class.M_class) == "table" then
      return true
   end   
   return false   
end

--[[
MObject.validate = function(value)
   if type(value) == "table" and value.M_type == "class" and type(value.M_className) == "string" and type(value.M_class) == "table" then
      return true
   end   
   return false
end
--]]

MObject.MObject = function()
end

setmetatable(MObject, MObject)

-- MString base class
local MString = {
   M_type = "class",
   M_className = "MString",
   M_parents = {MObject}
}
MString.__call = function(self, value)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MString",
      M_class = MString,
      M_value = value
          }
end

MString.validate = function(value)
   if type(value) == "string" or value == nil then
      return true
   end   
   return false
end

setmetatable(MString, MString)

-- MNumber base class
local MNumber = {
   M_type = "class",
   M_className = "MNumber",
   M_parents = {MObject}
}
MNumber.__call = function(self, value)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MNumber",
      M_class = MNumber,
      M_value = value
          }
end

MNumber.validate = function(value)
   if type(value) == "number" or value == nil then
      return true
   end   
   return false
end

setmetatable(MNumber, MNumber)

-- MBoolean base class
local MBoolean = {
   M_type = "class",
   M_className = "MBoolean",
   M_parents = {MObject}
}
MBoolean.__call = function(self, value)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MBoolean",
      M_class = MBoolean,
      M_value = value
          }
end

MBoolean.validate = function(value)
   if type(value) == "boolean" or value == nil then
      return true
   end   
   return false
end

setmetatable(MBoolean, MBoolean)

-- MTable base class
local MTable = {
   M_type = "class",
   M_className = "MTable",
   M_parents = {MObject}
}
MTable.__call = function(self, value)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MTable",
      M_class = MTable,
      M_value = value
          }
end

MTable.validate = function(value)
   if type(value) == "table" or value == nil then
      return true
   end   
   return false
end

setmetatable(MTable, MTable)

-- MUserdata base class
local MUserdata = {
   M_type = "class",
   M_className = "MUserdata",
   M_parents = {MObject}
}
MUserdata.__call = function(self, value)
   return {
      M_type = "collector",
      M_collectorType = "class",
      M_className = "MUserdata",
      M_class = MUserdata,
      M_value = value
          }
end

MUserdata.validate = function(value)
   if type(value) == "userdata" or value == nil then
      return true
   end   
   return false
end

setmetatable(MUserdata, MUserdata)

local MTypes = {
   MObject = MObject,
   MString = MString,
   MNumber = MNumber,
   MBoolean = MBoolean,
   MTable = MTable,
   MUserdata = MUserdata
}

return MTypes
