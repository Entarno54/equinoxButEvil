import std/[os, logging, posix]

const
  BINDER_DRIVERS = ["anbox-binder", "puddlejumper", "bonder", "binder", "binderfs/anbox-binder"]
  VNDBINDER_DRIVERS = ["anbox-vndbinder", "vndpuddlejumper", "vndbonder", "vndbinder"]
  HWBINDER_DRIVERS = ["anbox-hwbinder", "hwpuddlejumper", "hwbonder", "hwbinder"]

type Drivers* = object
  binder*, vndbinder*, hwbinder*: string

proc devExists*(file: string): bool =
  var sb: Stat

  if stat(file, sb) == 0.cint:
    if S_ISCHR(sb.stMode):
      debug "drivers: character device found: " & file
      return true
    else:
      warn "drivers: path exists but is NOT a character device: " & file
  else:
    debug "drivers: device does not exist: " & file

  return false

proc setupBinderNodes*(): Drivers =
  var hasBinder = false
  for node in BINDER_DRIVERS:
    if devExists("/dev" / node):
      debug "drivers: found binder driver: " & node
      hasBinder = true
      result.binder = node

  if not hasBinder:
    raise newException(Defect, "Cannot find binder node \"binder\"")

  var hasVndbinder = false
  for node in VNDBINDER_DRIVERS:
    if devExists("/dev" / node):
      debug "drivers: found VND binder driver: " & node
      hasVndbinder = true
      result.vndbinder = node

  if not hasVndbinder:
    raise newException(Defect, "Cannot find VND Binder node")

  var hasHwbinder = false
  for node in HWBINDER_DRIVERS:
    if devExists("/dev" / node):
      debug "drivers: found HW binder driver: " & node
      hasHwbinder = true
      result.hwbinder = node

  if not hasHwbinder:
    raise newException(Defect, "Cannot find HW Binder node")
