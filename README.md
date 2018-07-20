# FERemastered Change Log

## BZCC Version Changes 0.1

* Added provides, and ODF inheritance to Hadean + Cerberi Units.
* Arranged Cerberi Object Folders.
* General Hierarchy clean-up.
* Commented geometryScale out from mostly all Cerberi + Hadean units until the new models are implemented.
* Added needPilot = 0 to all Cerberi CPU Object Variants to prevent odd behaivour. 

### [cvscav.odf] 
* Changed DeployClass = "ibscav" to DeployClass = "cbscav"
* Changed cvscav to use proper unit icons, vehicles, speeds.
* Set cvscav02.odf to inherit from cvscav.odf
* Changed accelThrust from 50.0 to 5.0
* Added needPilot = 0 flag.

### [cvcons.odf]
* Added ODF inheritance to cvcons02.odf and cvcons03.odf (it now inherits from cvcons.odf except for the mesh/animations/unit icons.).
* Fixed broken [buildItems] menu in cvcons (added buildItem3 = "cbcbun" [was "cbjamm"] and buildItem4 = "cbarmo")

### [cbrecy.odf]
* Removed requirement for Power Node (?!)
* Changed Service Pod from item9 to item7
* cbrecy02 and cbrecy03 now inherit from cbrecy, but they use different meshes.
* Added baseName = "cbrecy"

### [cvrecy.odf]
* cvrecy03 inherits from cvrecy02.
* Changed accelThrust from 50.0 to 5.0
* Added alphaSteer = 0.5

### [cbagen.odf]
* Changed scrapValue = 3 to scrapValue = 10
* Added baseName = "cbagen"

### [cbarmo.odf]
* Changed scrapValue = 3 to scrapValue = 5
* Removed empty armory groups.
* Added baseName = "cbarmo"

### [cbcbun.odf]
* Changed scrapValue = 3 to scrapValue = 8
* Changed detectRange = 900 to detectRange = 300 due to being overpowered.
* Changed rangeScan = 2500 to rangeScan = 400 due to being overpowered.
* Added baseName = "cbcbun"

### [cbfact.odf]
* Set cbfact02 and cbfact03 to inherit from cbfact but meshes are different.
* Added baseName = "cbfact"

### [cbgtow.odf]
* Added baseName = "cbgtow"

### [cbjamm.odf]
* Added baseName = "cbjamm"

### [cbpgen.odf]
* Added baseName = "cbpgen"

### [cbscav.odf]
* Added baseName = "cbscav"

### [cbscup.odf]
* Added ambient sounds.
* Added baseName = "cbscup"

### [cbtcen.odf]
* Added baseName = "cbtcen"

[cbsbay.odf]
* Added baseName = "cbsbay"

### [cvatank.odf]
* Changed cvatank to use normal Dread values (copied from cvatank02).
* Changed cvatank02 from the main Dread ODF to an inherited version of cvatank.

### [cvdcar.odf]
* Added baseName = "cvdcar"

### [cvgorg.odf]
* Added baseName = "cvgorg"

### [cvhatank.odf]
* Changed cvhatankP to inherit from cvhatank.
* Fiddled with the Dominators speed. Reduced: omegaSpin to 0.1 [was 0.2] and omegaTurn to 0.5 [was 1.0] to see if it corrects "skidding" behaviour. 
* Added needPilot = 1 flag.

### [cvrbomb.odf]
* Changed cvrbombP to inherit from cvrbomb.

### [cvscout.odf]
* Changed scrapValue = 30 to scrapValue = 5 (too much scrap dropped) [Reverted].
* cvscoutP now inherits from cvscout.

### [cvserv.odf]
* Changed the original cvserv ODF values from Scion values to normal Cerberi values.
* cvserv02 will now inherit from cvserv.
* Changed cockpit model in cvserv from fvserv_cockpit.xsi to ivserv_cockpit.xsi.
* Added geometryScale = 0.3 to cvserv.

### [cvtalon.odf]
* cvtalon02P now inherits from cvtalon02.

### [cvtank.odf]
* cvtankP now inherits from cvtank.
* We may need to review the voices for this unit, I think there may be some missing voice references. 
* Replaced missing voice cues with Sabre tank voices.

### [cvturr.odf]
* For some reason, cvturr is using a lot of Scion values. Spawning it in game created a modified Scion Guardian. This has been changed.
* cvturr02 now inherits from cvturr.
* Added DeployableClass

### [cvwalk.odf]
* Unsure what fvcerbw is used for, so that has been left alone.
* cvwalkP now inherits from cvwalk.

### [cvwraith.odf]
* Added baseName = "cvwraith"
