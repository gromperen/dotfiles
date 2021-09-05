import XMonad

import System.IO
import System.Exit

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce ( spawnOnce )

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName

import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import Data.Maybe (maybeToList)
import Control.Monad ( join, when )

myBrowser = "chromium"

myTerminal = "st"

myLauncher = "dmenu_run"

myWorkspaces = map (\x -> "[" ++ x ++ "]") ["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix"]
-- myWorkspaces	= map show [1..9]

-- myWorkspaces = ["1:web","2:code","3:media"] ++ map show [4..9]



-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"
-- myWorkspaces    = ["\63083", "\63288", "\63306", "\61723", "\63107", "\63601", "\63391", "\61713", "\61884"]


addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]



myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, xK_Return),
        spawn $ XMonad.terminal conf)

    , ((modMask, xK_w),
        spawn myBrowser)

    , ((modMask, xK_f),
        sendMessage $ Toggle FULL)

    , ((modMask, xK_q),
        kill)

    -- , ((modMask .|. shiftMask, xK_q),
    --  io (exitWith ExitSuccess))

    , ((modMask .|. shiftMask, xK_q),
        restart "xmonad" True)

    , ((modMask, xK_BackSpace),
        spawn "sysact")

    , ((modMask, xK_d),
        spawn myLauncher)

    , ((modMask, xK_space),
        sendMessage NextLayout)

    , ((modMask, xK_h),
        sendMessage Shrink)

    -- Expand the master area.
    , ((modMask, xK_l),
        sendMessage Expand)

    , ((modMask, xK_f),
        sendMessage (Toggle FULL))

    -- Mute volume
    , ((0, xF86XK_AudioMute),
        spawn "pamixer -t")

    -- Decrease volume.
    , ((0, xF86XK_AudioLowerVolume),
        spawn "pamixer -d 3")

    -- Increase volume.
    , ((0, xF86XK_AudioRaiseVolume),
        spawn "pamixer -i 3")

    , ((0, xF86XK_MonBrightnessUp),
        spawn "xbacklight -inc 10")

    , ((0, xF86XK_MonBrightnessDown),
        spawn "xbacklight -dec 10")


    ]

    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


layouts = gaps [(U, 42), (R, 8), (L, 8), (D, 8)] $ avoidStruts (
    ThreeColMid 1 (3/100) (1/2) |||
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)



myLayout = smartBorders
            $ mkToggle (NOBORDERS ?? FULL ?? EOT)
            $ layouts


myManageHook = fullscreenManageHook <+> manageDocks <+> composeAll
    [ resource =? "desktop_window" --> doIgnore
    , isFullscreen --> doFullFloat
    ]

myStartupHook = do
    spawnOnce "dunst"
    setWMName "LG3D"


defaults = def {
    modMask     = mod4Mask,
    terminal    = myTerminal,
    keys        = myKeys,
    workspaces  = myWorkspaces,

    manageHook  = manageDocks <+> myManageHook,
    startupHook = myStartupHook >> addEWMHFullscreen,
    layoutHook  = myLayout,
    handleEventHook = docksEventHook
}

main :: IO ()
main = do
    xmproc <- spawnPipe ("xmobar ~/.config/xmobar/xmobarrc")
    xmonad . fullscreenSupport . docks $ ewmh defaults {
        logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppSep = "   "
      }
    }
