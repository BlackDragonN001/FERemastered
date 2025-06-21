--[[
    Battlezone 2 ScriptUtils Function Definitions for Lua Language Server
    Written by AI_Unit
    Version 1.0

    All functions are defined as per the original game engine's ScriptUtils API.
    This file is intended to be used with a Lua Language Server for code completion and type checking.
    Note: This file does not include the actual game logic or implementation details.
    It only provides function signatures and type definitions.
    
    Usage:
    1. Load this file in your Lua Language Server.
    2. Use the provided function signatures for code completion and type checking.
    3. Refer to the original game documentation for detailed usage of each function.
    4. This file is not executable on its own and requires the Battlezone 2 game engine to function.
    5. This file is a reference and does not include any game assets or resources.
    6. The functions are designed to be used in a Lua scripting environment.
    7. The types defined here are aliases for the ScriptUtils functions used in the game engine.
--]]

---@alias Team integer
---@alias Handle userdata
---@alias Path string|Vector|Handle
---@alias Position Vector|Matrix|Handle|string

---@class Vector
---@field x number
---@field y number
---@field z number

---@class Matrix
---@field right Vector
---@field up Vector
---@field front Vector
---@field position Vector

---@class Quaternion
---@field s number
---@field x number
---@field y number
---@field z number
---@field w number
---@field q Vector
---@field qx number
---@field qy number
---@field qz number
---@field qw number

function InitialSetup() end

function Start() end

function Load() end

function Save() end

function Update() end

function PostRun() end

---@param h Handle
function AddObject(h) end

---@param h any
function RemoveObject(h) end

---@param h Handle
function DeleteObject(h) end

---@param ID integer
---@param Team integer
---@param IsNewPlayer boolean
function AddPlayer(ID, Team, IsNewPlayer) end

---@param ID integer
function DeletePlayer(ID) end

function WantBotKillMessages() end

---@param DeadObjectHandle Handle
---@param KillersHandle Handle
function ObjectKilled(DeadObjectHandle, KillersHandle) end

---@param DeadObjectHandle Handle
---@param KillersHandle Handle
function ObjectSniped(DeadObjectHandle, KillersHandle) end

---@param ShooterHandle Handle
---@param VictimHandle Handle
---@param OrdnanceTeam integer
---@param OrdnanceODF string
function PreOrdnanceHit(ShooterHandle, VictimHandle, OrdnanceTeam, OrdnanceODF) end

---@param CurWorld integer
---@param PilotHandle Handle
---@param EmptyCraftHandle Handle
function PreGetIn(CurWorld, PilotHandle, EmptyCraftHandle) end

---@param CurWorld integer
---@param ShooterHandle Handle
---@param VictimHandle Handle
---@param OrdnanceTeam integer
---@param OrdnanceODF string
function PreSnipe(CurWorld, ShooterHandle, VictimHandle, OrdnanceTeam, OrdnanceODF) end

---@param CurWorld integer
---@param Me Handle
---@param PowerUpHandle Handle
function PrePickupPowerup(CurWorld, Me, PowerUpHandle) end

---@param Craft Handle
---@param PreviousTarget Handle
---@param CurrentTarget Handle
function PostTargetChangedCallback(Craft, PreviousTarget, CurrentTarget) end

---@param Team integer
function GetNextRandomVehicleODF(Team) end

---@param CRC integer
function ProcessCommand(CRC) end

---@param Seed integer
function SetRandomSeed(Seed) end

---@param Max number
function GetRandomFloat(Max) end

---@param Min number
---@param Max number
function GetRandomFloat(Min, Max) end

---@param V Vector
function FrontToRadian(V) end

---@param V Vector
function FrontToDegrees(V) end

---@param A Vector
---@param B Vector
function GetFacingDirection(A, B) end

---@param A Vector
---@param B Vector
function GetFacingDirection2D(A, B) end

---@param X number
---@param Y number
---@param Z number
function SetVector(X, Y, Z) end

---@param V Vector
function IsNullVector(V) end

---@param A Vector
---@param B Vector
function DotProduct(A, B) end

---@param A Vector
---@param B Vector
function CrossProduct(A, B) end

---@param V Vector
function Normalize(V) end

---@param M Matrix
---@param V Vector
function Vector_Transform(M, V) end

---@param M Matrix
---@param Pos_x number
---@param Pos_y number
---@param Pos_z number
function Vector_Transform(M, Pos_x, Pos_y, Pos_z) end

---@param M Matrix
---@param V Vector
---@overload fun(M: Matrix, Pos_x: number, Pos_y: number, Pos_z: number)
function Vector_TransformInv(M, V) end

---@param M Matrix
---@param V Vector
---@overload fun(M: Matrix, Pos_x: number, Pos_y: number, Pos_z: number)
function Vector_Rotate(M, V) end

---@param M Matrix
---@param V Vector
---@overload fun(M: Matrix, Pos_x: number, Pos_y: number, Pos_z: number)
function Vector_RotateInv(M, V) end

---@param A Vector
---@param B Vector
---@param Mult number
function Add_Mult_Vectors(A, B, Mult) end

---@param X number
---@param Y number
---@param Z number
function SetVector(X, Y, Z) end

---@param V Vector
function Length(V) end

---@param V Vector
function LengthSquared(V) end

---@param A Vector
---@param B Vector
function Distance2D(A, B) end

---@param A Vector
---@param B Vector
function Distance2DSquared(A, B) end

---@param A Vector
---@param B Vector
---@overload fun(A: Handle, B: Handle)
function Distance3D(A, B) end

---@param A Vector
---@param B Vector
---@overload fun(A: Handle, B: Handle)
function Distance3DSquared(A, B) end

---@param Right Vector
---@param Up Vector
---@param Front Vector
---@param Position Vector
function SetMatrix(Right, Up, Front, Position) end

---@param Right_x number
---@param Right_y number
---@param Right_z number
---@param Up_x number
---@param Up_y number
---@param Up_z number
---@param Front_x number
---@param Front_y number
---@param Front_z number
---@param Posit_x number
---@param Posit_y number
---@param Posit_z number
function SetMatrix(Right_x, Right_y, Right_z, Up_x, Up_y, Up_z, Front_x, Front_y, Front_z, Posit_x, Posit_y, Posit_z) end

---@param Angle number
---@param Position Vector
function BuildAxisRotationMatrix(Angle, Position) end

---@param Angle number
---@param Axis_x number
---@param Axis_y number
---@param Axis_z number
function BuildAxisRotationMatrix(Angle, Axis_x, Axis_y, Axis_z) end

---@param Pitch number
---@param Yaw number
---@param Roll number
---@param Pos Vector
function BuildPositionRotationMatrix(Pitch, Yaw, Roll, Pos) end

---@param Pitch number
---@param Yaw number
---@param Roll number
---@param Pos_X number
---@param Pos_y number
---@param Pos_z number
function BuildPositionRotationMatrix(Pitch, Yaw, Roll, Pos_X, Pos_y, Pos_z) end

---@param Axis Vector
---@param Heading Vector
function BuildOrthogonalMatrix(Axis, Heading) end

---@param Position Vector
---@param Direction Vector
function BuildDirectionalMatrix(Position, Direction) end

---@param Angle number
---@param Position Vector
function Build_Yaw_Matrix(Angle, Position) end

---@param Angle number
---@param Pos_x number
---@param Pos_y number
---@param Pos_z number
function Build_Yaw_Matrix(Angle, Pos_x, Pos_y, Pos_z) end

---@param M Matrix
function Matrix_Inverse(M) end

---@param S number
---@param X number
---@param Y number
---@param Z number
function SetQuaternion(S, X, Y, Z) end

---@param q Quaternion
function Normalize_Quaternion(q) end

---@param M Matrix
function Matrix_to_QuatPos(M) end

---@param M Matrix
function Matrix_to_Quaternion(M) end

---@param Q Quaternion
---@param Pos Vector
function QuatPos_to_Matrix(Q, Pos) end

---@param Q Quaternion
---@param Pos_x number
---@param Pos_y number
---@param Pos_z number
function QuatPos_to_Matrix(Q, Pos_x, Pos_y, Pos_z) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function Attack(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function Service(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
---@overload fun(Me: Handle, Pos: Matrix, Priority: integer)
---@overload fun(Me: Handle, Pos: Vector, Priority: integer)
---@overload fun(Me: Handle, Path: string, Point: integer, Priority: integer)
function Goto(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
---@overload fun(Me: Handle, Pos: Matrix, Priority: integer)
---@overload fun(Me: Handle, Pos: Vector, Priority: integer)
---@overload fun(Me: Handle, Path: string, Point: integer, Priority: integer)
function Mine(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function Follow(Me, Him, Priority) end

---@param Me Handle
---@param Priority integer? 1
function Defend(Me, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function Defend2(Me, Him, Priority) end

---@param Me Handle
---@param Priority integer? 1
function Stop(Me, Priority) end

---@param Me Handle
---@param Path string
---@param Priority integer? 1
function Patrol(Me, Path, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
---@overload fun(Me: Handle, Pos: Matrix, Priority: integer)
---@overload fun(Me: Handle, Pos: Vector, Priority: integer)
---@overload fun(Me: Handle, Path: string, Point: integer, Priority: integer)
function Retreat(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function GetIn(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function Pickup(Me, Him, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
---@overload fun(Me: Handle, Pos: Matrix, Priority: integer)
---@overload fun(Me: Handle, Pos: Vector, Priority: integer)
---@overload fun(Me: Handle, Path: string, Point: integer, Priority: integer)
function Dropoff(Me, Him, Priority) end

---@param Me Handle
---@param ODF string
---@param Priority integer? 1
function Build(Me, ODF, Priority) end

---@param Me Handle
---@param Him Handle
---@param Priority integer? 1
function LookAt(Me, Him, Priority) end

---@param Team integer
---@param Him Handle
---@param Priority integer? 1
function AllLookAt(Team, Him, Priority) end

---@param Me Handle
---@param Handle any
---@param DoAim boolean
function FireAt(Me, Handle, DoAim) end

---@param H Handle
---@param Command integer
---@param Priority integer
---@param Who Handle
---@param Where Vector
---@param Param integer | string
---@overload fun(H: Handle, Command: integer, Priority: integer, Who: Handle, Where: Matrix, Param: integer | string)
---@overload fun(H: Handle, Command: integer, Priority: integer, Who: Handle, Where: Handle, Param: integer | string)
---@overload fun(H: Handle, Command: integer, Priority: integer, Who: Handle, Where: string, Param: integer | string)
function SetCommand(H, Command, Priority, Who, Where, Param) end

---@param H Handle
function GetCurrentCommand(H) end

---@param H Handle
function GetCurrentWho(H) end

---@param H Handle
function GetCurrentCommandWhere(H) end

---@param FileName string
function AudioMessage(FileName) end

---@param AudioID integer
function IsAudioMessageDone(AudioID) end

---@param AudioID integer
function StopAudioMessage(AudioID) end

---@param FileName string
function PreloadAudioMessage(FileName) end

---@param FileName string
function PurgeAudioMessage(FileName) end

---@param FileName string
function PreloadMusicMessage(FileName) end

---@param FileName string
function PurgeMusicMessage(FileName) end

---@param GroupName string
function LoadJukeFile(GroupName) end

---@param Intensity integer
function SetMusicIntensity(Intensity) end

---@param Filename string
---@param Handle Handle? 0
function StartSoundEffect(Filename, Handle) end

---@param Filename string
---@param Handle Handle? 0
function FindSoundEffect(Filename, Handle) end

---@param AudioHandle integer
function StopSoundEffect(AudioHandle) end

---@param Filename string
---@param Pos Vector
---@param AudioCategory integer
---@param Loop boolean
---@overload fun(Filename: string, Pos: Matrix, AudioCategory: integer, Loop: boolean)
---@overload fun(Filename: string, X: number, Y: number, Z: number, AudioCategory: integer, Loop: boolean)
---@overload fun(Filename: string, Pos: Handle, AudioCategory: integer, Loop: boolean)
function StartAudio3D(Filename, Pos, AudioCategory, Loop) end

---@param Filename string
---@param Volume number
---@param Pan number
---@param Rate number
---@param Loop boolean
---@param IsMusic boolean
function StartAudio2D(Filename, Volume, Pan, Rate, Loop, IsMusic) end

---@param AudioHandle integer
function IsAudioPlaying(AudioHandle) end

---@param AudioHandle integer
function StopAudio(AudioHandle) end

---@param AudioHandle integer
function PauseAudio(AudioHandle) end

---@param AudioHandle integer
function ResumeAudio(AudioHandle) end

---@param AudioHandle integer
---@param Volume number
---@param AdjustByVolumes boolean
function SetVolume(AudioHandle, Volume, AdjustByVolumes) end

---@param AudioHandle integer
---@param Pan number
function SetPan(AudioHandle, Pan) end

---@param AudioHandle integer
---@param Rate number
function SetRate(AudioHandle, Rate) end

---@param AudioHandle integer
function GetAudioFileDuration(AudioHandle) end

---@param AudioHandle integer
function IsPlayingLooped(AudioHandle) end

---@param Team integer?
function GetPlayerHandle(Team) end

---@param h Handle
---@param Team integer
function SetAsUser(h, Team) end

---@param Team integer
function GetRaceOfTeam(Team) end

---@param Team integer
---@param Value integer
function AddScrap(Team, Value) end

---@param Team integer
---@param Value integer
function SetScrap(Team, Value) end

---@param Team integer
---@param Value integer
function AddMaxScrap(Team, Value) end

---@param Team integer
---@param Value integer
function SetMaxScrap(Team, Value) end

---@param Team integer
function GetScrap(Team) end

---@param Team integer
function GetMaxScrap(Team) end

---@param Team integer
---@param Value integer
function AddPower(Team, Value) end

---@param Team integer
---@param Value integer
function SetPower(Team, Value) end

---@param Team integer
function GetPower(Team) end

---@param Team integer
function GetMaxPower(Team) end

---@param Team integer
---@param Value integer
function AddMaxPower(Team, Value) end

---@param Team integer
---@param Value integer
function SetMaxPower(Team, Value) end

function GetFirstEmptyGroup() end

---@param Team integer
function GetFirstEmptyGroup(Team) end

function DefaultAllies() end

function TeamplayAllies() end

---@param a Team
---@param b Team
function Ally(a, b) end

---@param a Team
---@param b Team
function UnAlly(a, b) end

---@param a Team
---@param b Team
function IsTeamAllied(a, b) end

---@param a Handle
---@param b Handle
function IsAlly(a, b) end

---@param Team integer
function GetPlan(Team) end

---@param FileName string
---@param Team Team
function SetAIP(FileName, Team) end

function ClearTeamColors() end

function DefaultTeamColors() end

function TeamplayTeamColors() end

---@param Team integer
---@param Color Vector
function SetTeamColor(Team, Color) end

---@param Team integer
---@param Red integer
---@param Green integer
---@param Blue integer
function SetTeamColor(Team, Red, Green, Blue) end

---@param Team integer
function ClearTeamColor(Team) end

---@param TeamColorType integer
function SetFFATeamColors(TeamColorType) end

---@param TeamColorType integer
function SetTeamStratColors(TeamColorType) end

---@param TeamColorType integer
---@param Team integer
function GetFFATeamColor(TeamColorType, Team) end

---@param TeamColorType integer
---@param Team integer
function GetFFATeamColorVector(TeamColorType, Team) end

---@param TeamColorType integer
---@param TeamGroup integer
function GetTeamStratColor(TeamColorType, TeamGroup) end

---@param team any
function WhichTeamGroup(team) end

---@param TeamColorType integer
---@param Team integer
function GetTeamStratColorVector(TeamColorType, Team) end

function SwapTeamStratColors() end

function GetTeamColorsAreFFA() end

function SetTeamStratColors() end

function SetFFATeamColors() end

---@param TeamColorType integer
function SetTeamColors(TeamColorType) end

function SetTeamColors() end

---@param TeamColorType integer
---@param Team integer
function GetTeamStratIndividualColor(TeamColorType, Team) end

---@param TeamColorType integer
---@param Team integer
function GetTeamStratIndividualColorVector(TeamColorType, Team) end

---@param Team integer
---@param Name string
function SetTeamNameForStat(Team, Name) end

---@param h Handle
function GetTransform(h) end

---@param h Handle
function GetTransform2(h) end

function DeleteObject() end

---@param h Handle
---@param Pos Matrix
function SetTransform(h, Pos) end

---@param h Handle
---@param h2 Handle
function SetTransform(h, h2) end

---@param h Handle
---@param Path string
function SetTransform(h, Path) end

---@param h Handle
function GetTeamNum(h) end

---@param h Handle
---@param Team integer
function SetTeamNum(h, Team) end

---@param h Handle
function GetPerceivedTeam(h) end

---@param h Handle
---@param Team integer
function SetPerceivedTeam(h, Team) end

---@param h Handle
function GetHealth(h) end

---@param h Handle
function GetCurHealth(h) end

---@param h Handle
---@param Value number
function SetCurHealth(h, Value) end

---@param h Handle
function GetMaxHealth(h) end

---@param h Handle
---@param Value number
function SetMaxHealth(h, Value) end

---@param h Handle
---@param Value number
function AddHealth(h, Value) end

---@param h Handle
function GetAmmo(h) end

---@param h Handle
function GetCurAmmo(h) end

---@param h Handle
---@param Value number
function SetCurAmmo(h, Value) end

---@param h Handle
function GetMaxAmmo(h) end

---@param h Handle
---@param Value number
function SetMaxAmmo(h, Value) end

---@param h Handle
---@param Value number
function AddAmmo(h, Value) end

---@param h Handle
---@param Slot integer
function GetCurLocalAmmo(h, Slot) end

---@param h Handle
---@param Value number
---@param Slot integer
function SetCurLocalAmmo(h, Value, Slot) end

---@param h Handle
---@param Slot integer
function GetMaxLocalAmmo(h, Slot) end

---@param h Handle
---@param Value number
---@param Slot integer
function AddLocalAmmo(h, Value, Slot) end

---@param h Handle
function GetVelocity(h) end

---@param h Handle
---@param velocity Vector
function SetVelocity(h, velocity) end

---@param h Handle
function GetWhoShotMe(h) end

---@param h Handle
function GetLastEnemyShot(h) end

---@param h Handle
function GetLastFriendShot(h) end

---@param h Handle
function GetIndependence(h) end

---@param h Handle
---@param Independence integer
function SetIndependence(h, Independence) end

---@param h Handle
function GetWeaponMask(h) end

---@param h Handle
---@param Mask number
function SetWeaponMask(h, Mask) end

function GetUserTarget() end

---@param Team integer
function GetUserTarget(Team) end

---@param h Handle
function SetUserTarget(h) end

---@param Team integer
---@param h Handle
function SetUserTarget(Team, h) end

---@param h Handle
function GetTarget(h) end

---@param h Handle
---@param Target Handle
function SetTarget(h, Target) end

---@param h Handle
function GetSkill(h) end

---@param h Handle
---@param Skill integer
function SetSkill(h, Skill) end

---@param h Handle
function GetScavengerCurScrap(h) end

---@param h Handle
---@param Value integer
function SetScavengerCurScrap(h, Value) end

---@param h Handle
function GetScavengerMaxScrap(h) end

---@param h Handle
---@param Value integer
function SetScavengerMaxScrap(h, Value) end

---@param h Handle
function GetGroup(h) end

---@param Team integer
---@param Group integer
---@param ObjectInfoType integer
function GetGroup(Team, Group, ObjectInfoType) end

---@param Team integer
---@param Group integer
function GetGroupCount(Team, Group) end

---@param h Handle
---@param GroupIndex integer
function SetGroup(h, GroupIndex) end

---@param h Handle
function SetBestGroup(h) end

---@param h Handle
function GetOwner(h) end

---@param h Handle
---@param owner Handle
function SetOwner(h, owner) end

---@param h Handle
function GetPilotClass(h) end

---@param h Handle
function GetPilotOdf(h) end

---@param h Handle
---@param PilotClass string
function SetPilotClass(h, PilotClass) end

---@param h Handle
function GetLabel(h) end

---@param h Handle
---@param Label string
function SetLabel(h, Label) end

---@param BaseObj Handle
---@param Slot integer
function GetTap(BaseObj, Slot) end

---@param BaseObj Handle
---@param Slot integer
---@param h Handle
function SetTap(BaseObj, Slot, h) end

---@param h Handle
function GetOmega(h) end

---@param h Handle
---@param Omega Vector
function SetOmega(h, Omega) end

---@param h Handle
function GetCanSnipe(h) end

---@param h Handle
---@param CanSnipe integer -1
function SetCanSnipe(h, CanSnipe) end

---@param h Handle
function GetEjectRatio(h) end

---@param h Handle
---@param Ratio number
function SetEjectRatio(h, Ratio) end

---@param ODF string
---@param Team integer
---@param Position Handle
---@param Point integer 0
---@overload fun(ODF: string, Team: integer, Position: Matrix)
---@overload fun(ODF: string, Team: integer, Position: Vector)
---@overload fun(ODF: string, Team: integer, Position: string)
function BuildObject(ODF, Team, Position, Point) end

---@param h Handle
function RemoveObject(h) end

---@param h Handle
---@overload fun(Path: string, Point: integer)
function GetPosition(h) end

---@param h Handle
function GetPosition2(h) end

---@param h Handle
---@param pos Vector
---@overload fun(h: Handle, h: Handle)
---@overload fun(h: Handle, Path: string, Point: integer)
function SetPosition(h, pos) end

---@param h Handle
function IsPlayer(h) end

---@param h Handle
function GetNearestObject(h) end

---@param h Handle
---@overload fun(Path: string, Point: integer)
function GetNearestVehicle(h) end

---@param h Handle
function GetNearestBuilding(h) end

---@param h Handle
---@overload fun(h: Handle, ignorePilots: boolean, ignoreScavs: boolean, maxDist : integer)
function GetNearestEnemy(h) end

---@param h Handle
function GetRace(h) end

---@param h Handle
function IsAround(h) end

---@param h Handle
function IsAlive(h) end

---@param h Handle
function IsAliveAndPilot(h) end

---@param h Handle
function IsNotDeadAndPilot(h) end

---@param h Handle
function IsFlying(h) end

---@param h Handle
function IsPowered(h) end

---@param h Handle
---@overload fun(h: Handle, MaxHeight: number)
function InBuilding(h) end

---@param h Handle
function AtTerminal(h) end

---@param h Handle
function GetFront(h) end

---@param h Handle
function GetLookFront(h) end

---@param me Handle
---@param Amount number
---@overload fun(me: Handle, him: Handle, Amount: number)
function Damage(me, Amount) end

---@param h Handle
function AddPilotByHandle(h) end

---@param h Handle
function IsDeployed(h) end

---@param h Handle
function HoppedOutOf(h) end

---@param h Handle
---@param Weapon string
---@overload fun(h: Handle, Weapon: string, Slot: integer)
function GiveWeapon(h, Weapon) end

---@param me Handle
---@overload fun(me: Handle, him: Handle)
function IsFollowing(me) end

---@param h Handle
function WhoFollowing(h) end

---@param h Handle
function KillPilot(h) end

---@param h Handle
function RemovePilot(h) end

---@param h Handle
---@param Type integer
function SetAvoidType(h, Type) end

---@param me Handle
---@param him Handle
function Annoy(me, him) end

---@param h Handle
function ClearThrust(h) end

---@param h Handle
---@param Verbose boolean
function SetVerbose(h, Verbose) end

---@param h Handle
function ClearIdleAnims(h) end

---@param h Handle
---@param Name string
function AddIdleAnim(h, Name) end

---@param h Handle
function IsIdle(h) end

---@param h Handle
function CountThreats(h) end

---@param Group integer
---@param Count integer
---@param ODF string
---@param Team integer
---@param Path string
---@overload fun(Group: integer, Count: integer, ODF: string, Team: integer, Start: Handle, Finish: Handle)
function SpawnBirds(Group, Count, ODF, Team, Path) end

---@param Group integer
function RemoveBirds(Group) end

---@param h Handle
function SetRandomHeadingAngle(h) end

---@param h Handle
---@param Degrees number
function SetAngle(h, Degrees) end

---@param Cargo Handle
function GetTug(Cargo) end

---@param Tug Handle
function HasCargo(Tug) end

---@param SequenceNumber integer
---@overload fun(Label: string)
function GetHandle(SequenceNumber) end

---@param Slot integer
---@overload fun(Team: integer, Slot: string)
function GetObjectByTeamSlot(Slot) end

function GetAllGameObjectHandles() end

---@param h Handle
function WhoIsTargeting(h) end

---@param h Handle
function IsPerson(h) end

---@param h Handle
function IsBuilding(h) end

---@param h Handle
function IsPowerup(h) end

---@param h Handle
function IsCraftButNotPerson(h) end

---@param h Handle
function IsCraftOrPerson(h) end

---@param h Handle
---@param ODF string
function IsOdf(h, ODF) end

---@param h Handle
function MakeInert(h) end

---@param h Handle
function Deploy(h) end

---@param h Handle
function EjectPilot(h) end

---@param h Handle
function HopOut(h) end

---@param h Handle
---@param Controls table
function SetControls(h, Controls) end

---@param h Handle
function SetNoScrapFlagByHandle(h) end

---@param h Handle
function ClearNoScrapFlagByHandle(h) end

---@param h Handle
---@param Amount number
function SelfDamage(h, Amount) end

---@param h Handle
function ResetTeamSlot(h) end

---@param h Handle
function GetCategoryTypeOverride(h) end

---@param h Handle
function GetCategoryType(h) end

---@param h Handle
function GetRemainingLifespan(h) end

---@param h Handle
function GetLifeSpan(h) end

---@param h Handle
---@param Time number
function SetLifespan(h, Time) end

---@param h Handle
---@param IgnoreSpawnpoints boolean
---@param MaxDist number
function GetNearestPowerup(h, IgnoreSpawnpoints, MaxDist) end

---@param h Handle
---@param skipFriendlies boolean
---@param MaxDist number
function GetNearestPerson(h, skipFriendlies, MaxDist) end

---@param h1 Handle
---@param h2 Handle
---@param Distance number
function IsWithin(h1, h2, Distance) end

---@param h Handle
---@param Distance number
---@param Team integer
---@param ODF string
function CountUnitsNearObject(h, Distance, Team, ODF) end

---@param h Handle
function GetCfg(h) end

---@param h Handle
function GetOdf(h) end

---@param h Handle
function GetBase(h) end

---@param h Handle
function GetClassSig(h) end

---@param h Handle
function GetClassLabel(h) end

---@param h Handle
---@param Slot integer 0
function GetWeaponConfig(h, Slot) end

---@param h Handle
---@param Slot integer 0
function GetWeaponODF(h, Slot) end

---@param h Handle
---@param Slot integer 0
function GetWeaponGOClass(h, Slot) end

---@param h1 Handle
---@param h2 Handle
function GetTeamRelationship(h1, h2) end

---@param h Handle
function HasPilot(h) end

---@param h Handle
function GetBaseScrapCost(h) end

---@param h Handle
function GetActualScrapCost(h) end

---@param h Handle
---@param LastMatrix Matrix
---@param CurMatrix Matrix
function SetLastCurrentPosition(h, LastMatrix, CurMatrix) end

---@param h Handle
---@param TruePos Vector
---@param LastPos Vector
---@overload fun(h: Handle, TrueMat: Matrix, LastMat: Matrix, SetPosition: boolean)
function SetintegererpolablePosition(h, TruePos, LastPos) end

---@param h Handle
function CanBuild(h) end

---@param h Handle
function IsBusy(h) end

---@param h Handle
function GetBuildClass(h) end

---@param h Handle
---@param Index integer
function GetQueuedItem(h, Index) end

---@param h Handle
---@param Mask integer
function MaskEmitter(h, Mask) end

---@param h Handle
function GetEmitterMask(h) end

---@param h Handle
---@param Slot integer
function StartEmitter(h, Slot) end

---@param h Handle
---@param Slot integer
function StopEmitter(h, Slot) end

---@param h Handle
---@param Slot integer
function IsEmitterOn(h, Slot) end

---@param h Handle
---@param Name string
---@param Type integer
function SetAnimation(h, Name, Type) end

---@param h Handle
function StartAnimation(h) end

---@param h Handle
---@param Name string
function GetAnimationFrame(h, Name) end

---@param h Handle
function PauseAnimation(h) end

---@param h Handle
---@param Direction integer
function ResumeAnimation(h, Direction) end

---@param h Handle
function GetAnimationDirection(h) end

---@param h Handle
---@param TurnSpeed number
---@param Time number
---@overload fun(h: Handle, TurnSpeed: number, MoveSpeed: number, Dest: Vector)
function Move(h, TurnSpeed, Time) end

---@param h Handle
---@param ODF string nil
---@param Team integer -1
---@param HeightOffset number 0.0
---@param Empty integer -1
---@param restoreWeapons boolean true
---@param Group integer -1
---@param CanSnipe integer -1
---@param KeepCmd boolean true
---@param NewCmd integer -1
---@param NewPriority 0
---@param NewWho Handle
---@param NewWhere Vector
function ReplaceObject(h, ODF, Team, HeightOffset, Empty, restoreWeapons, Group, CanSnipe, KeepCmd, NewCmd, NewPriority,
                       NewWho, NewWhere) end

---@param h Handle
function CanCommand(h) end

function GetCameraPosition() end

---@param pos Vector
---@param dir Vector
function SetCameraPosition(pos, dir) end

function ResetCameraPosition() end

function CameraReady() end

---@param Path string
---@param Height integer
---@param Speed integer
---@param Target Handle
function CameraPath(Path, Height, Speed, Target) end

---@param Path string
---@param Height integer
---@param Speed integer
function CameraPathDir(Path, Height, Speed) end

---@param me Handle
---@param him Handle
---@param PosA Vector
---@param PosB Vector
---@param Speed number
function CameraPos(me, him, PosA, PosB, Speed) end

function PanDone() end

---@param Object Handle
---@param Offset Vector
---@param Target Handle
---@overload fun(Object: Handle, X: number, Y: number, Z: number, Target: Handle)
function CameraObject(Object, Offset, Target) end

---@param me Handle
---@param offset Vector
function CameraOf(me, offset) end

function CameraFinish() end

function CameraCancelled() end

function FreeCamera() end

function FreeFinish() end

---@param name string
function PlayMovie(name) end

function StopMovie() end

function PlayMove() end

---@param Name string
---@overload fun(Name: string, UpdateCam: boolean)
function PlayRecording(Name) end

---@param Name string
function PlaybackVehicle(Name) end

---@param Time number
---@param Warn number? -2147483647
---@param Alert number? -2147483647
function StartCockpitTimer(Time, Warn, Alert) end

---@param Time number
---@param Warn number
---@param Alert number
function StartCockpitTimerUp(Time, Warn, Alert) end

function StopCockpitTimer() end

function HideCockpitTimer() end

function GetCockpitTimer() end

---@param h Handle
function SetObjectiveOn(h) end

---@param h Handle
function SetObjectiveOff(h) end

---@param h Handle
function GetObjectiveName(h) end

---@param h Handle
---@param Name string
function SetObjectiveName(h, Name) end

function ClearObjectives() end

---@param Text string
---@param Color integer
---@param Time integer? 10
---@overload fun(Text: string, Color: string, Time: integer?)
function AddObjective(Text, Color, Time) end

---@param h Handle
function GetPlayerName(h) end

---@param VarName string
function GetVarItemStr(VarName) end

---@param VarName string
function GetVarItemInt(VarName) end

---@param Team integer
---@param Index integer
function GetCVarItemInt(Team, Index) end

---@param Team integer
---@param Index integer
function GetCVarItemStr(Team, Index) end

---@param FileName string
---@overload fun(FileName: string, MenuScale: boolean)
function IFace_Exec(FileName) end

---@param Name string
function IFace_Activate(Name) end

---@param Name string
function IFace_Deactivate(Name) end

---@param command string
function IFace_CreateCommand(command) end

---@param Name string
---@param Value string
function IFace_CreateString(Name, Value) end

---@param Name string
---@param Value string
function IFace_SetString(Name, Value) end

---@param Name string
function IFace_GetString(Name) end

---@param Name string
---@param Value integer
function IFace_CreateInteger(Name, Value) end

---@param Name string
---@param Value string
function IFace_SetInteger(Name, Value) end

---@param Name string
function IFace_GetInteger(Name) end

---@param Name string
---@param Min integer
---@param Max integer
function IFace_SetIntegerRange(Name, Min, Max) end

---@param Name string
---@param Value number
function IFace_CreateFloat(Name, Value) end

---@param Name string
---@param Value string
function IFace_SetFloat(Name, Value) end

---@param Name string
function IFace_GetFloat(Name) end

---@param Name string
function IFace_ClearListBox(Name) end

---@param Name string
---@param Value string
function IFace_AddTextItem(Name, Value) end

---@param Name string
function IFace_GetSelectedItem(Name) end

---@param Cmd string
---@param SquelchOutput boolean true
function IFace_ConsoleCmd(Cmd, SquelchOutput) end

function IFace_EnterMenuMode() end

function IFace_ExitMenuMode() end

---@param Name string
---@param Value string
function Network_SetString(Name, Value) end

---@param Name string
---@param Value integer
function Network_Setintegereger(Name, Value) end

function GetInstantMyForce() end

function GetInstantCompForce() end

function GetInstantDifficulty() end

function GetInstantGoal() end

function GetInstantType() end

function GetInstantFlag() end

function GetInstantMySide() end

function GetCurWorld() end

function IsNetworkOn() end

function ImServer() end

function ImDedicatedServer() end

function IsTeamplayOn() end

function CountPlayers() end

---@param Team integer
function CountAllies(Team) end

---@param Team integer
function WhichTeamGroup(Team) end

---@param Team integer
function GetCommanderTeam(Team) end

---@param Team integer
function GetFirstAlliedTeam(Team) end

---@param Team integer
function GetLastAlliedTeam(Team) end

---@param Team integer
function GetTeamplayRanges(Team) end

---@param Team integer
---@param RandomizeType integer
function GetPlayerODF(Team, RandomizeType) end

---@param h Handle
---@param ODF string
---@param Team integer
---@param MinRadius number
---@param MaxRadius number
function BuildEmptyCraftNear(h, ODF, Team, MinRadius, MaxRadius) end

function GetSafestSpawnpoint() end

---@param Team integer
function GetSpawnpoint(Team) end

---@param Team integer
function GetSpawnpointHandle(Team) end

---@param Team integer -1
function GetRandomSpawnpoint(Team) end

---@param Team integer? 0
function GetAllSpawnpoints(Team) end

---@param Text string
function SetTimerBox(Text) end

---@param Text string
function AddToMessagesBox(Text) end

---@param Text string
---@param Color integer
function AddToMessagesBox(Text, Color) end

---@param h Handle
function GetDeaths(h) end

---@param h Handle
function GetKills(h) end

---@param h Handle
function GetScore(h) end

---@param h Handle
---@param Value integer
function SetDeaths(h, Value) end

---@param h Handle
function SetKills(h) end

---@param h Handle
function SetScore(h) end

---@param h Handle
---@param Value integer
function AddDeaths(h, Value) end

---@param h Handle
function AddKills(h) end

---@param h Handle
function AddScore(h) end

function GetLocalPlayerDPID() end

---@param flag Handle
---@param holder Handle
function FlagSteal(flag, holder) end

---@param flag Handle
---@param holder Handle
function FlagRecover(flag, holder) end

---@param flag Handle
---@param holder Handle
function FlagScore(flag, holder) end

---@param Amount integer
---@param holder Handle
function MoneyScore(Amount, holder) end

function NoteGameoverByTimelimit() end

---@param h Handle
function NoteGameoverByKillLimit(h) end

---@param h Handle
function NoteGameoverByScore(h) end

---@param h Handle
function NoteGameoverByLastWithBase(h) end

---@param TeamGroup integer
function NoteGameoverByLastTeamWithBase(TeamGroup) end

function NoteGameoverByNoBases() end

---@param Message string
function NoteGameoverWithCustomMessage(Message) end

---@param Time number
function DoGameover(Time) end

---@param TeamGroup integer
---@param Race string
function SetMPTeamRace(TeamGroup, Race) end

---@param h Handle
---@param Reason string
---@param Ban boolean false
function KickPlayer(h, Reason, Ban) end

---@param NetworkListType integer
---@param Index integer
function GetNetworkListItem(NetworkListType, Index) end

---@param NetworkListType integer
function GetNetworkListCount(NetworkListType) end

---@param Time number
---@param Debrief string
function FailMission(Time, Debrief) end

---@param Time number
---@param Debrief string
function SucceedMission(Time, Debrief) end

function ChangeSide() end

---@param h Handle
---@overload fun(ODF: string)
function IsInfo(h) end

---@param h Handle
function IsSelected(h) end

---@param Ratio number
---@param Rate number
---@param Color string
---@overload fun(Ratio: number, Rate: number, Color: integer)
function SetColorFade(Ratio, Rate, Color) end

function StopCheats() end

function GetLocalUserInspectHandle() end

function GetLocalUserSelectHandle() end

---@param string any
function Print(string) end

---@param string any
function PrintConsoleMessage(string) end

---@param string any
function CalcCRC(string) end

---@param Red integer
---@param Green integer
---@param Blue integer
function Make_RGB(Red, Green, Blue) end

---@param Red integer
---@param Green integer
---@param Blue integer
---@param Alpha integer
function Make_RGBA(Red, Green, Blue, Alpha) end

---@param Key string
---@overload fun(Prefix: string, Key: string)
function TranslateString(Key) end

function PlayerEjected() end

function ObjectKilled() end

function ObjectSniped() end

---@param autoGroup boolean false
function SetAutoGroupUnits(autoGroup) end

function EnableHighTPS() end

function GetTPS() end

function GetMapTRNFilename() end

function GetMissionFilename() end

function GetTime() end

---@param h1 Handle
---@param h2 Handle
---@overload fun(h1: Handle, Pos: Matrix)
---@overload fun(h1: Handle, Pos: Vector)
---@overload fun(h1: Handle, Path: string, Point: integer)
function GetDistance(h1, h2) end

function GetAiPaths() end

---@param Path string
---@param Type integer
function SetPathType(Path, Type) end

---@param Path string
function SetPathOneWay(Path) end

---@param Path string
function SetPathRoundTrip(Path) end

---@param Path string
function SetPathLoop(Path) end

---@param Path string
function GetPathPointegers(Path) end

---@param Path string
---@param Pos Vector
---@overload fun(Path: string, Pos: Matrix)
---@overload fun(Path: string, h: Handle)
function IsInsideArea(Path, Pos) end

---@param Path string
---@param Pos Vector
---@overload fun(Path: string, Pos: Matrix)
---@overload fun(Path: string, h: Handle)
function GetWindingNumber(Path, Pos) end

---@param Magnitude number
function StartEarthQuake(Magnitude) end

---@param Magnitude number
function UpdateEarthQuake(Magnitude) end

function StopEarthquake() end

---@param Gravity number 12.5
function SetGravity(Gravity) end

---@param ODF string
function PreloadODF(ODF) end

---@param Pos Matrix
---@overload fun(Pos: Vector)
---@overload fun(Pos: Handle)
---@overload fun(Pos: string, Point: integer)
---@overload fun(X: number, Z: number)
function TerrainFindFloor(Pos) end

---@param Pos Vector
---@overload fun(Pos: Matrix)
---@overload fun(Pos: Handle)
---@overload fun(Pos: string, Point: integer)
---@overload fun(X: number, Z: number)
function TerrainIsWater(Pos) end

---@param Pos Vector
---@param UseWater boolean false
---@overload fun(Pos: Matrix, UseWater: boolean)
---@overload fun(Pos: Handle, UseWater: boolean)
---@overload fun(Path: string, Point: integer, UseWater: boolean)
---@overload fun(X: number, Z: number)
function GetTerrainHeightAndNormal(Pos, UseWater) end

---@param Path string
---@overload fun(h1: Handle, h2: Handle, Radius: number)
function CalcCliffs(Path) end

---@param Pos Matrix
---@param MinRadius number
---@param MaxRadius number
---@overload fun(Pos: Vector, MinRadius: number, MaxRadius: number)
---@overload fun(Pos: Handle, MinRadius: number, MaxRadius: number)
---@overload fun(Path: string, Pointeger: integer, MinRadius: number, MaxRadius: number)
function GetPositionNear(Pos, MinRadius, MaxRadius) end

---@param Pos Vector
---@param Radius number
---@param Angle number
function GetCircularPos(Pos, Radius, Angle) end

function GetLocalPlayerTeamNumber() end

---@param ODF string
function DoesODFExist(ODF) end

function DoesFileExist() end

---@param filename string
function DoesFileExist(filename) end

function PetWatchdogThread() end

---@param Seconds number
function SecondsToTurns(Seconds) end

---@param Turns integer
function TurnsToSeconds(Turns) end

function GetTimeStep() end

---@param TauntType integer
function DoTaunt(TauntType) end

---@param Name string
function SetTauntCPUTeamName(Name) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number? 0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFHexInt(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number? 0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFInt(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number? 0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFLong(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number 0.0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFFloat(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number? 0.0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFDouble(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue boolean? false
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: boolean)
function GetODFBoolean(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue string? ''
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: string)
function GetODFChar(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue string? ''
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: string)
function GetODFString(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue number? 0.0
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: number)
function GetODFColor(File, Block, Name, DefaultValue) end

---@param File string
---@param Block string
---@param Name string
---@param DefaultValue Vector? (0, 0, 0)
---@overload fun(h: Handle, Block: string, Name: string, DefaultValue: Vector)
function GetODFVector(File, Block, Name, DefaultValue) end

---@param Filename string
function LoadFile(Filename) end

---@param Filename string
---@param Text string
---@param Append any
function WriteToFile(Filename, Text, Append) end
