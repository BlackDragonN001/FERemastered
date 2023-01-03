
function InitAIPLua(team)
    AIPUtil.print(team, "Running AIP Lua Condition Script for CPU Team: " .. team);
end

function validate(conditions)
  msg = ''
  go = true
  for k, v in pairs(conditions) do
    msg = msg .. k .. ':' .. tostring(v) .. ' '
    go = go and v
  end

  if (go) then
      return true, ": " .. msg .. ". Proceeding...";
  else
      return false, ": " .. msg .. ". Halting plan.";
  end
end

function validatePlan4(team, time)
  return validate({
     HAS_20_scrap = AIPUtil.GetScrap(team, true) >= 20
    ,LACKS_3_VIRTUAL_CLASS_SCAVENGER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SCAVENGER", "sameteam", true) < 3
    ,HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
    ,HAS_1_biometal_OR_HAS_1_resource = AIPUtil.CountUnits(team, "biometal", "friendly", true) >= 1 or AIPUtil.CountUnits(team, "resource", "friendly", true) >= 1
  })
end
function validatePlan5(team, time)
  return validate({
     HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
    ,HAS_1_biometal = AIPUtil.CountUnits(team, "biometal", "friendly", true) >= 1
  })
end
function validatePlan6(team, time)
  return validate({
     HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
    ,HAS_1_biometal = AIPUtil.CountUnits(team, "biometal", "friendly", true) >= 1
  })
end
function validatePlan7(team, time)
  return validate({
     HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
    ,HAS_1_resource = AIPUtil.CountUnits(team, "resource", "friendly", true) >= 1
  })
end
function validatePlan8(team, time)
  return validate({
     HAS_40_scrap = AIPUtil.GetScrap(team, true) >= 40
    ,HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
  })
end
function validatePlan10(team, time)
  return validate({
     HAS_1_VIRTUAL_CLASS_RECYCLERBUILDING = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_RECYCLERBUILDING", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_SUPPLYDEPOT = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", "sameteam", true) >= 1
  })
end
function validatePlan13(team, time)
  return validate({
     HAS_50_scrap = AIPUtil.GetScrap(team, true) >= 50
  })
end
function validatePlan14(team, time)
  return validate({
     HAS_50_scrap = AIPUtil.GetScrap(team, true) >= 50
  })
end
function validatePlan15(team, time)
  return validate({
     HAS_30_scrap = AIPUtil.GetScrap(team, true) >= 30
    ,LACKS_1_power = AIPUtil.GetPower(team, true) < 1
  })
end
function validatePlan16(team, time)
  return validate({
     HAS_30_scrap = AIPUtil.GetScrap(team, true) >= 30
    ,LACKS_1_power = AIPUtil.GetPower(team, true) < 1
  })
end
function validatePlan18(team, time)
  return validate({
     HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_EXTRACTOR = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true) >= 1
    ,LACKS_1_VIRTUAL_CLASS_EXTRACTOR_UPGRADED = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR_UPGRADED", "sameteam", true) < 1
  })
end
function validatePlan19(team, time)
  return validate({
     LACKS_1_VIRTUAL_CLASS_FACTORY = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", "sameteam", true) < 1
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_55_scrap = AIPUtil.GetScrap(team, true) >= 55
    ,HAS_1_power = AIPUtil.GetPower(team, true) >= 1
  })
end
function validatePlan21(team, time)
  return validate({
     HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_power = AIPUtil.GetPower(team, true) >= 1
  })
end
function validatePlan24(team, time)
  return validate({
     HAS_50_scrap = AIPUtil.GetScrap(team, true) >= 50
  })
end
function validatePlan25(team, time)
  return validate({
     HAS_50_scrap = AIPUtil.GetScrap(team, true) >= 50
  })
end
function validatePlan26(team, time)
  return validate({
     HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_2_VIRTUAL_CLASS_EXTRACTOR = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true) >= 2
    ,LACKS_2_VIRTUAL_CLASS_EXTRACTOR_UPGRADED = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR_UPGRADED", "sameteam", true) < 2
  })
end
function validatePlan27(team, time)
  return validate({
     HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_FACTORY = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
  })
end
function validatePlan30(team, time)
  return validate({
     HAS_80_scrap = AIPUtil.GetScrap(team, true) >= 80
    ,HAS_1_ebarmo = AIPUtil.CountUnits(team, "ebarmo", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
  })
end
function validatePlan33(team, time)
  return validate({
     HAS_30_scrap = AIPUtil.GetScrap(team, true) >= 30
    ,LACKS_1_power = AIPUtil.GetPower(team, true) < 1
  })
end
function validatePlan34(team, time)
  return validate({
     HAS_50_scrap = AIPUtil.GetScrap(team, true) >= 50
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_FACTORY = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY", "sameteam", true) >= 1
  })
end
function validatePlan36(team, time)
  return validate({
     HAS_70_scrap = AIPUtil.GetScrap(team, true) >= 70
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
  })
end
function validatePlan37(team, time)
  return validate({
     HAS_70_scrap = AIPUtil.GetScrap(team, true) >= 70
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
  })
end
function validatePlan39(team, time)
  return validate({
     HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_EXTRACTOR = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR", "sameteam", true) >= 1
    ,LACKS_1_VIRTUAL_CLASS_EXTRACTOR_UPGRADED = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_EXTRACTOR_UPGRADED", "sameteam", true) < 1
  })
end
function validatePlan40(team, time)
  return validate({
     HAS_60_scrap = AIPUtil.GetScrap(team, true) >= 60
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_FACTORY_U = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_FACTORY_U", "sameteam", true) >= 1
  })
end
function validatePlan43(team, time)
  return validate({
     HAS_30_scrap = AIPUtil.GetScrap(team, true) >= 30
    ,LACKS_1_power = AIPUtil.GetPower(team, true) < 1
  })
end
function validatePlan44(team, time)
  return validate({
     HAS_80_scrap = AIPUtil.GetScrap(team, true) >= 80
    ,HAS_1_VIRTUAL_CLASS_CONSTRUCTIONRIG = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_CONSTRUCTIONRIG", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_COMMBUNKER = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_COMMBUNKER", "sameteam", true) >= 1
    ,HAS_1_VIRTUAL_CLASS_SUPPLYDEPOT = AIPUtil.CountUnits(team, "VIRTUAL_CLASS_SUPPLYDEPOT", "sameteam", true) >= 1
  })
end
