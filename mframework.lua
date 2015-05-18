-- MFramework

-- Utilities
local MUtil = require('mutil')

local mDebug = MUtil.mDebug
local mDebugTable = MUtil.mDebugTable
local mFlushDebug = MUtil.mFlushDebug

-- Base types
local MTypes = require('mtypes')

local MObject = MTypes.MObject
local MString = MTypes.MString
local MNumber = MTypes.MNumber
local MBoolean = MTypes.MBoolean
local MTable = MTypes.MTable
local MUserdata = MTypes.MUserdata

-- Meta object
local MMetaObject = require('mmetaobject')

local MMethod = MMetaObject.MMethod
local MMethodVirtual = MMetaObject.MMethodVirtual

-- Meta class
local MMetaClass = require('mmetaclass')

local MClass = MMetaClass.MClass

-- Export

local function export()
   _G.mDebug = mDebug
   _G.mDebugTable = mDebugTable
   _G.mFlushDebug = mFlushDebug
   _G.MObject = MObject
   _G.MString = MString
   _G.MNumber = MNumber
   _G.MBoolean = MBoolean
   _G.MTable = MTable
   _G.MUserdata = MUserdata
   _G.MMethod = MMethod
   _G.MMethodVirtual = MMethodVirtual
   _G.MClass  = MClass
end

export()
