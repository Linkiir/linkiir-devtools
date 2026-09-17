-- ---------------------------------------------------------------------------
-- Data Simulator (LKTOOL_DATA_SIMULATOR)
--
-- A Source Custom node that emits synthetic HL7 v2, C-CDA, FHIR or X12
-- messages on every poll interval and pushes them downstream onto the queue.
-- Pick the message type from the Message Type dropdown.
--
-- Use it to build and load-test an interface before a live feed exists: point
-- a transform at it, run it, and watch real traffic shapes flow through.
--
-- Everything it emits is synthetic - invented names, addresses and payers - so
-- the output carries no PHI and needs no de-identification.
--
-- Templates live in samples.lua. Adding a message type means adding one entry
-- there and one option to the Message Type dropdown; this file does not change.
-- ---------------------------------------------------------------------------

local Samples = require 'samples'

local Cfg = linkiir.config.node()

local MessageType = Cfg['Message Type'] or 'HL7 v2.5.1 ADT^A01 (Admit)'
local PerInterval = tonumber(Cfg['Messages Per Interval']) or 1
local Topic       = Cfg['Topic']
local Randomize   = Cfg['Randomize Content']
local Seed        = tonumber(Cfg['Random Seed']) or 0
local LiveMode    = Cfg['Live Mode']

if Randomize == nil then Randomize = true end
if LiveMode == nil then LiveMode = true end
if Topic == '' then Topic = nil end

-- Seeded once per script VM. Seed 0 varies on every start; any other value
-- pins the sequence, which is what a repeatable regression test needs.
if Seed > 0 then
   math.randomseed(Seed)
else
   math.randomseed(tonumber(linkiir.sys.guid(128):sub(1, 8), 16))
end
math.random()  -- the first draw after a seed correlates with it; discard

-- Rotates through the patient list so repeated messages describe a stable
-- population instead of a stream of strangers.
local Cursor = 0
local function nextPatient()
   local Pool = Samples.Patients
   if Randomize then
      return Pool[math.random(#Pool)]
   end
   Cursor = (Cursor % #Pool) + 1
   return Pool[Cursor]
end

-- Counters for the X12 envelope. Interchange and group control numbers have to
-- advance per message, or a receiver rejects the second one as a duplicate.
local Envelope = 0

local function tokens(Patient)
   Envelope = Envelope + 1
   local Now = os.time()
   return {
      TS         = os.date('%Y%m%d%H%M%S', Now),
      CDATS      = os.date('%Y%m%d%H%M%S', Now) .. '+0000',
      ISO        = os.date('!%Y-%m-%dT%H:%M:%SZ', Now),
      DATE       = os.date('%Y%m%d', Now),
      DATE6      = os.date('%y%m%d', Now),
      TIME       = os.date('%H%M', Now),
      YEARSTART  = os.date('%Y', Now) .. '0101',
      CTRL       = os.date('%Y%m%d%H%M%S', Now) .. string.format('%05d', math.random(0, 99999)),
      TRACE      = string.format('TRN%09d', math.random(1, 999999999)),
      ISACTRL    = string.format('%09d', Envelope),
      GSCTRL     = tostring(Envelope),
      UUID       = linkiir.sys.guid(128),
      -- Vitals vary even when the patient does not, so a downstream chart has
      -- something to plot.
      WEIGHT     = tostring(math.random(110, 240)),
      HEIGHT     = tostring(math.random(60, 76)),
      MRN        = Patient.mrn,
      ACCOUNT    = Patient.account,
      MEMBER     = Patient.member,
      FAMILY     = Patient.family,
      GIVEN      = Patient.given,
      GENDER     = Patient.gender,
      GENDERWORD = Patient.genderWord,
      DOB        = Patient.dob,
      DOBDASH    = Patient.dobDash,
      STREET     = Patient.street,
      CITY       = Patient.city,
      STATE      = Patient.state,
      ZIP        = Patient.zip,
      PHONE      = Patient.phone,
   }
end

-- Substitutes {{TOKEN}} placeholders. An unknown token is left untouched rather
-- than blanked, so a typo in a template shows up in the output as {{TYPO}}
-- instead of vanishing silently.
local function fill(Text, Values)
   return (Text:gsub('{{(%w+)}}', function(Key)
      local V = Values[Key]
      if V == nil then return nil end
      return tostring(V)
   end))
end

-- X12 SE01 is the number of segments in the transaction set, counting ST and
-- SE themselves. Computed from the filled segment list rather than written into
-- the template, because a hardcoded count silently goes wrong the moment anyone
-- adds or removes a segment - and a mismatch is one of the first things a
-- trading partner's validator rejects.
local function setSegmentCount(Parts)
   local StAt, SeAt
   for i, Segment in ipairs(Parts) do
      if not StAt and Segment:match('^ST%*') then StAt = i end
      if Segment:match('^SE%*') then SeAt = i end
   end
   if not StAt or not SeAt then return end
   local Count = SeAt - StAt + 1
   Parts[SeAt] = Parts[SeAt]:gsub('{{SEGCOUNT}}', tostring(Count))
end

local function build(Template, Values)
   if Template.segs then
      local Parts = {}
      for i, Segment in ipairs(Template.segs) do
         Parts[i] = fill(Segment, Values)
      end
      if Template.x12 then setSegmentCount(Parts) end
      return table.concat(Parts, Template.sep) .. (Template.tail or '')
   end
   return fill(Template.body, Values)
end

function main()
   local Template = Samples.Templates[MessageType]
   if not Template then
      linkiir.log.error(
         "Data Simulator: unknown Message Type '" .. tostring(MessageType) ..
         "'. Check the node's Message Type field against the list in samples.lua.")
      return
   end

   local Count = math.max(1, math.min(PerInterval, 1000))
   local Sent = 0

   for _ = 1, Count do
      local Patient = nextPatient()
      local Message = build(Template, tokens(Patient))

      local Ok, Result = pcall(linkiir.flow.push, {
         data  = Message,
         topic = Topic,
         live  = LiveMode,
         metadata = {
            simulator = 'LKTOOL_DATA_SIMULATOR',
            message_type = MessageType,
            format = Template.ext,
            mrn = Patient.mrn,
         },
      })

      if Ok then
         Sent = Sent + 1
      else
         -- Report and stop: if the queue is refusing writes, the remaining
         -- messages in this interval will fail the same way, and repeating the
         -- same error N times buries it.
         linkiir.log.error('Data Simulator: push failed after ' .. Sent ..
                           ' of ' .. Count .. ' - ' .. tostring(Result))
         return
      end
   end

   if not LiveMode then
      linkiir.log.info('Data Simulator: simulated ' .. Sent .. ' x ' ..
                       MessageType .. ' (Live Mode off - nothing was queued)')
   else
      linkiir.log.debug('Data Simulator: queued ' .. Sent .. ' x ' .. MessageType)
   end
end
