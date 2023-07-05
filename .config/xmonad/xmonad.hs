import XMonad
import XMonad.Config (def)
import XMonad.Util.EZConfig (additionalKeysP)

main :: IO ()
main = xmonad $ def {
    -- -----------------
    --  Variables
    -- -----------------
    terminal = "kitty",
    modMask = mod4Mask,
    altMask = mod1Mask
  } `additionalKeysP` [
    -- -----------------
    --  Keybindings
    -- -----------------
    -- XMonad
    ("M-S-q",       spawn "xmonad --recompile && xmonad --restart"),
    -- Programs
    ("M-b",         spawn "firefox"),
    ("M-S-b",       spawn "firefox --private-window"),
    ("M-e",         spawn "thunar"),
    ("M-<Return>",  spawn "kitty"),
    ("M-S-<Space>", spawn "rofi -show drun"),
    ("M-S-<Tab>",   spawn "rofi -show window")
  ]