require 'busted.runner' ()
require 'time-split.util.formatting'
local say = require("say")

local function is_within_sixty(state, arguments)
  return math.abs(arguments[1] - arguments[2]) < 60
end

say:set("assertion.is_within_sixty.positive", "Expected %s \nto be within 60 from: %s")
say:set("assertion.is_within_sixty.negative", "Expected %s \nto not be within 60 from: %s")
assert:register("assertion", "is_within_sixty", is_within_sixty, "assertion.is_within_sixty.positive",
  "assertion.is_within_sixty.negative")

describe("tick to timestamp", function()

  it("should provide correct response for some given ticks", function()
    assert.are.same("00:00:01", tick_to_timestamp(60))
    assert.are.same("00:01:00", tick_to_timestamp(3600))
    assert.are.same("01:00:00", tick_to_timestamp(216000))
    assert.are.same("01:01:01", tick_to_timestamp(219660))
    assert.are.same("99:59:59", tick_to_timestamp(21599940))
  end)

  it("should truncate when told and it's necessary", function()
    assert.are.same("01", tick_to_timestamp(60, true))
    assert.are.same("01:00", tick_to_timestamp(3600, true))
    assert.are.same("01:00:00", tick_to_timestamp(216000, true))
  end)

  it("should handle round-trips", function()
    for _ = 0, 100, 1 do
      local number = math.random(0, 21599940)
      -- Ticks smaller than 1 second is ignored, we only verify that
      -- returned value is within 60 ticks appart
      assert.is_within_sixty(number, timestamp_to_tick(tick_to_timestamp(number)))
    end
  end)

end)
