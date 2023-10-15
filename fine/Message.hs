module Message (message) where

import Hello (hello)
import Reykjavik (reykjavik)

message :: String
message = hello ++ " " ++ reykjavik ++ "!"
